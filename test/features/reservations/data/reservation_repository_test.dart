import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late ReservationRepository repository;
  late String guestId;
  late String roomAId;
  late String roomBId;

  // 2026-06-04 = jueves (entre semana), 05/06/07 = viernes/sábado/domingo
  // (fin de semana).
  final checkIn = DateTime(2026, 6, 4);
  final checkOut = DateTime(2026, 6, 7);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = ReservationRepository(db);

    // Los ids son UUID (clientDefault): se generan acá para poder usarlos
    // como FK, en vez de confiar en el rowid que devuelve insert().
    final propertyId = const Uuid().v4();
    final roomTypeId = const Uuid().v4();
    guestId = const Uuid().v4();
    roomAId = const Uuid().v4();
    roomBId = const Uuid().v4();

    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(
            id: Value(propertyId),
            name: 'Hostal Central',
          ),
        );
    await db
        .into(db.roomTypes)
        .insert(
          RoomTypesCompanion.insert(
            id: Value(roomTypeId),
            name: 'Dormitorio compartido',
          ),
        );
    await db
        .into(db.guests)
        .insert(
          GuestsCompanion.insert(id: Value(guestId), fullName: 'Familia Pérez'),
        );

    Future<void> insertRoom(String id, String name) => db
        .into(db.rooms)
        .insert(
          RoomsCompanion.insert(
            id: Value(id),
            propertyId: propertyId,
            roomTypeId: roomTypeId,
            name: name,
            capacity: 4,
            ratePerPersonWeekdayCents: 1200,
            ratePerPersonWeekendCents: 1500,
            ratePerPersonHolidayCents: 2000,
          ),
        );

    await insertRoom(roomAId, 'Cuarto A');
    await insertRoom(roomBId, 'Cuarto B');
  });

  tearDown(() => db.close());

  test(
    'calcula el precio sumando tarifa entre-semana y fin-de-semana por noche',
    () async {
      final reservationId = await repository.createGroupReservation(
        guestId: guestId,
        checkInDate: checkIn,
        checkOutDate: checkOut,
        roomAssignments: [
          RoomAssignmentInput(roomId: roomAId, guestsCount: 2),
          RoomAssignmentInput(roomId: roomBId, guestsCount: 3),
        ],
      );

      final reservation = await (db.select(
        db.reservations,
      )..where((r) => r.id.equals(reservationId))).getSingle();

      // Cuarto A: 1 noche entre semana (1200x2) + 2 noches fin de semana
      // (1500x2 cada una) = 2400 + 3000 + 3000 = 8400.
      // Cuarto B: 1200x3 + 1500x3 + 1500x3 = 3600 + 4500 + 4500 = 12600.
      expect(reservation.totalPriceCents, 8400 + 12600);
      expect(reservation.status, ReservationStatus.pending);

      final lines = await repository.getRoomsForReservation(reservationId);
      expect(lines, hasLength(2));
    },
  );

  test('no permite reservar una habitación con fechas solapadas', () async {
    await repository.createGroupReservation(
      guestId: guestId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      roomAssignments: [RoomAssignmentInput(roomId: roomAId, guestsCount: 2)],
    );

    // Se solapa: el cuarto A sigue ocupado hasta el 7 (checkout).
    expect(
      () => repository.createGroupReservation(
        guestId: guestId,
        checkInDate: DateTime(2026, 6, 6),
        checkOutDate: DateTime(2026, 6, 9),
        roomAssignments: [RoomAssignmentInput(roomId: roomAId, guestsCount: 1)],
      ),
      throwsStateError,
    );
  });

  test(
    'sí permite check-in el mismo día del check-out de otra reserva (rotación)',
    () async {
      await repository.createGroupReservation(
        guestId: guestId,
        checkInDate: checkIn,
        checkOutDate: checkOut,
        roomAssignments: [RoomAssignmentInput(roomId: roomAId, guestsCount: 2)],
      );

      // checkOut de la primera reserva es el 7; esta entra el mismo día 7.
      final secondReservationId = await repository.createGroupReservation(
        guestId: guestId,
        checkInDate: DateTime(2026, 6, 7),
        checkOutDate: DateTime(2026, 6, 9),
        roomAssignments: [RoomAssignmentInput(roomId: roomAId, guestsCount: 1)],
      );

      expect(secondReservationId, isNotEmpty);
    },
  );

  test('un feriado cargado en Holidays cobra tarifa de feriado aunque sea '
      'entre semana', () async {
    // 2026-06-01 es lunes (entre semana), pero se carga como feriado.
    await db
        .into(db.holidays)
        .insert(
          HolidaysCompanion.insert(
            date: DateTime(2026, 6, 1),
            name: const Value('Feriado de prueba'),
          ),
        );

    final reservationId = await repository.createGroupReservation(
      guestId: guestId,
      checkInDate: DateTime(2026, 6, 1),
      checkOutDate: DateTime(2026, 6, 2),
      roomAssignments: [RoomAssignmentInput(roomId: roomAId, guestsCount: 2)],
    );

    final reservation = await (db.select(
      db.reservations,
    )..where((r) => r.id.equals(reservationId))).getSingle();

    // Tarifa de feriado (2000), no la de entre semana (1200).
    expect(reservation.totalPriceCents, 2000 * 2);
  });
}
