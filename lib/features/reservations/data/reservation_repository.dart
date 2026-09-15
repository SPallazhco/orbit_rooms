import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/domain/reservation_availability.dart';
import 'package:orbit_rooms/features/reservations/domain/reservation_pricing.dart';
import 'package:uuid/uuid.dart';

/// Una habitación asignada dentro de una reserva de grupo, con cuántas
/// personas del grupo van ahí (PRD 5.4).
class RoomAssignmentInput {
  const RoomAssignmentInput({required this.roomId, required this.guestsCount});

  final String roomId;
  final int guestsCount;
}

class ReservationRepository {
  ReservationRepository(this._db);

  final AppDatabase _db;

  /// Trae las estadías activas (no canceladas) de una habitación. Solo
  /// lee de la base de datos — la definición de "se solapan" es una regla
  /// pura (`dateRangesOverlap`) que vive en el dominio, no acá.
  Future<List<({DateTime checkInDate, DateTime checkOutDate})>>
  _getActiveBookings(String roomId) async {
    final query =
        _db.select(_db.reservationRooms).join([
            innerJoin(
              _db.reservations,
              _db.reservations.id.equalsExp(_db.reservationRooms.reservationId),
            ),
          ])
          ..where(_db.reservationRooms.roomId.equals(roomId))
          ..where(
            _db.reservations.status
                .equalsValue(ReservationStatus.cancelled)
                .not(),
          );

    final rows = await query.get();
    return rows.map((row) {
      final reservation = row.readTable(_db.reservations);
      return (
        checkInDate: reservation.checkInDate,
        checkOutDate: reservation.checkOutDate,
      );
    }).toList();
  }

  /// Regla de negocio no negociable (PRD 5.4): una habitación no puede
  /// tener dos reservas activas con fechas solapadas (PRD 5.10 —
  /// `dateRangesOverlap` define qué cuenta como solapamiento).
  Future<bool> isRoomAvailable({
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) async {
    final activeBookings = await _getActiveBookings(roomId);
    return activeBookings.every(
      (booking) => !dateRangesOverlap(
        aCheckIn: booking.checkInDate,
        aCheckOut: booking.checkOutDate,
        bCheckIn: checkInDate,
        bCheckOut: checkOutDate,
      ),
    );
  }

  /// Crea una reserva de grupo con una o varias habitaciones asignadas
  /// (PRD 5.4). El precio total queda calculado automáticamente, pero es
  /// editable después con [overrideTotalPrice] (ej. descuento de niños).
  Future<String> createGroupReservation({
    required String guestId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required List<RoomAssignmentInput> roomAssignments,
  }) async {
    if (!checkOutDate.isAfter(checkInDate)) {
      throw ArgumentError('checkOutDate debe ser posterior a checkInDate');
    }
    if (roomAssignments.isEmpty) {
      throw ArgumentError('La reserva necesita al menos una habitación');
    }

    return _db.transaction(() async {
      final holidayDates = (await _db.select(_db.holidays).get())
          .map((h) => h.date)
          .toSet();
      final subtotalsCents = <String, int>{};

      for (final assignment in roomAssignments) {
        final available = await isRoomAvailable(
          roomId: assignment.roomId,
          checkInDate: checkInDate,
          checkOutDate: checkOutDate,
        );
        if (!available) {
          throw StateError(
            'La habitación ${assignment.roomId} ya tiene una reserva activa '
            'en esas fechas',
          );
        }

        final room = await (_db.select(
          _db.rooms,
        )..where((r) => r.id.equals(assignment.roomId))).getSingle();

        subtotalsCents[assignment.roomId] = calculateSubtotalCents(
          ratePerPersonWeekdayCents: room.ratePerPersonWeekdayCents,
          ratePerPersonWeekendCents: room.ratePerPersonWeekendCents,
          ratePerPersonHolidayCents: room.ratePerPersonHolidayCents,
          checkInDate: checkInDate,
          checkOutDate: checkOutDate,
          guestsCount: assignment.guestsCount,
          holidayDates: holidayDates,
        );
      }

      final reservationId = const Uuid().v4();
      final totalPriceCents = subtotalsCents.values.fold(
        0,
        (sum, subtotal) => sum + subtotal,
      );

      await _db
          .into(_db.reservations)
          .insert(
            ReservationsCompanion.insert(
              id: Value(reservationId),
              guestId: guestId,
              checkInDate: checkInDate,
              checkOutDate: checkOutDate,
              totalPriceCents: totalPriceCents,
            ),
          );

      for (final assignment in roomAssignments) {
        await _db
            .into(_db.reservationRooms)
            .insert(
              ReservationRoomsCompanion.insert(
                id: Value(const Uuid().v4()),
                reservationId: reservationId,
                roomId: assignment.roomId,
                guestsCount: assignment.guestsCount,
                subtotalCents: subtotalsCents[assignment.roomId]!,
              ),
            );
      }

      return reservationId;
    });
  }

  Future<List<ReservationRoom>> getRoomsForReservation(String reservationId) =>
      (_db.select(
        _db.reservationRooms,
      )..where((rr) => rr.reservationId.equals(reservationId))).get();

  Future<Reservation> getById(String id) =>
      (_db.select(_db.reservations)..where((r) => r.id.equals(id))).getSingle();

  /// Todas las reservas, con el nombre del huésped principal ya resuelto.
  /// Reactivo, mismo patrón que `PropertyRepository.watchActive()`.
  Stream<List<({Reservation reservation, String guestName})>> watchAll() {
    final query = _db.select(_db.reservations).join([
      innerJoin(_db.guests, _db.guests.id.equalsExp(_db.reservations.guestId)),
    ])..orderBy([OrderingTerm.desc(_db.reservations.checkInDate)]);

    return query.watch().map(
      (rows) => rows.map((row) {
        final reservation = row.readTable(_db.reservations);
        final guest = row.readTable(_db.guests);
        return (reservation: reservation, guestName: guest.fullName);
      }).toList(),
    );
  }

  /// Historial de reservas de un huésped puntual (PRD 5.3), más recientes
  /// primero. Reactivo, mismo patrón que [watchAll].
  Stream<List<Reservation>> watchByGuest(String guestId) =>
      (_db.select(_db.reservations)
            ..where((r) => r.guestId.equals(guestId))
            ..orderBy([(r) => OrderingTerm.desc(r.checkInDate)]))
          .watch();

  /// Todas las líneas de habitación asignada, con las fechas/estado de su
  /// reserva — para calcular la ocupación actual en el Dashboard (PRD 5.7).
  /// Reactivo, mismo patrón que [watchAll].
  Stream<List<({ReservationRoom line, Reservation reservation})>>
  watchAllRoomAssignments() {
    final query = _db.select(_db.reservationRooms).join([
      innerJoin(
        _db.reservations,
        _db.reservations.id.equalsExp(_db.reservationRooms.reservationId),
      ),
    ]);

    return query.watch().map(
      (rows) => rows.map((row) {
        final line = row.readTable(_db.reservationRooms);
        final reservation = row.readTable(_db.reservations);
        return (line: line, reservation: reservation);
      }).toList(),
    );
  }

  Future<void> updateStatus(String reservationId, ReservationStatus status) =>
      (_db.update(_db.reservations)..where((r) => r.id.equals(reservationId)))
          .write(ReservationsCompanion(status: Value(status)));

  /// Ajuste manual del precio final (ej. descuento de niños, auto extra,
  /// multa — ninguno sigue una fórmula fija, ver docs/DECISIONS.md).
  Future<void> overrideTotalPrice(String reservationId, int totalPriceCents) =>
      (_db.update(
        _db.reservations,
      )..where((r) => r.id.equals(reservationId))).write(
        ReservationsCompanion(totalPriceCents: Value(totalPriceCents)),
      );

  /// Pedidos especiales o motivo de un ajuste manual al precio (PRD 5.4).
  Future<void> updateNotes(String reservationId, String? notes) =>
      (_db.update(_db.reservations)..where((r) => r.id.equals(reservationId)))
          .write(ReservationsCompanion(notes: Value(notes)));
}
