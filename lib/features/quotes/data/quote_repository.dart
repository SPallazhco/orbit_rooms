import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/domain/reservation_pricing.dart';
import 'package:uuid/uuid.dart';

class QuoteRepository {
  QuoteRepository(this._db);

  final AppDatabase _db;

  /// Arma una línea por noche con la tarifa de la habitación (entre
  /// semana/fin de semana/feriado — misma regla que
  /// `ReservationRepository.createGroupReservation`), la de niños en 0
  /// (la administradora la decide caso a caso, sin default real, ver
  /// docs/DECISIONS.md). El depósito sugerido es la mitad del total,
  /// editable después.
  Future<String> create({
    required String propertyId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int adultsCount,
    int childrenCount = 0,
    String? guestName,
    String? guestContact,
    String? notes,
  }) async {
    final room = await (_db.select(
      _db.rooms,
    )..where((r) => r.id.equals(roomId))).getSingle();
    final holidayDates = (await _db.select(_db.holidays).get())
        .map((h) => h.date)
        .toSet();

    final dayRates = dayRatesForStay(
      ratePerPersonWeekdayCents: room.ratePerPersonWeekdayCents,
      ratePerPersonWeekendCents: room.ratePerPersonWeekendCents,
      ratePerPersonHolidayCents: room.ratePerPersonHolidayCents,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      holidayDates: holidayDates,
    );

    final totalCents = dayRates.fold(
      0,
      (sum, day) => sum + day.rateCents * adultsCount,
    );

    final quoteId = const Uuid().v4();
    await _db.transaction(() async {
      await _db
          .into(_db.quotes)
          .insert(
            QuotesCompanion.insert(
              id: Value(quoteId),
              propertyId: propertyId,
              roomId: roomId,
              checkInDate: checkInDate,
              checkOutDate: checkOutDate,
              adultsCount: adultsCount,
              childrenCount: Value(childrenCount),
              depositCents: (totalCents / 2).round(),
              guestName: Value(guestName),
              guestContact: Value(guestContact),
              notes: Value(notes),
            ),
          );

      for (final day in dayRates) {
        await _db
            .into(_db.quoteDayLines)
            .insert(
              QuoteDayLinesCompanion.insert(
                id: Value(const Uuid().v4()),
                quoteId: quoteId,
                date: day.date,
                adultsRateCents: day.rateCents,
              ),
            );
      }
    });

    return quoteId;
  }

  Future<Quote> getById(String id) =>
      (_db.select(_db.quotes)..where((q) => q.id.equals(id))).getSingle();

  /// Reactivo, mismo patrón que `ReservationRepository.watchAll()`: se
  /// actualiza solo al crear/editar/cambiar de estado una cotización.
  Stream<List<({Quote quote, String propertyName, String roomName})>>
  watchAll() {
    final query = _db.select(_db.quotes).join([
      innerJoin(
        _db.properties,
        _db.properties.id.equalsExp(_db.quotes.propertyId),
      ),
      innerJoin(_db.rooms, _db.rooms.id.equalsExp(_db.quotes.roomId)),
    ])..orderBy([OrderingTerm.asc(_db.quotes.checkInDate)]);

    return query.watch().map(
      (rows) => rows.map((row) {
        final quote = row.readTable(_db.quotes);
        final property = row.readTable(_db.properties);
        final room = row.readTable(_db.rooms);
        return (quote: quote, propertyName: property.name, roomName: room.name);
      }).toList(),
    );
  }

  Stream<List<QuoteDayLine>> watchDayLines(String quoteId) =>
      (_db.select(_db.quoteDayLines)
            ..where((l) => l.quoteId.equals(quoteId))
            ..orderBy([(l) => OrderingTerm.asc(l.date)]))
          .watch();

  Future<void> updateDayLine(
    String id, {
    required int adultsRateCents,
    required int childrenRateCents,
  }) => (_db.update(_db.quoteDayLines)..where((l) => l.id.equals(id))).write(
    QuoteDayLinesCompanion(
      adultsRateCents: Value(adultsRateCents),
      childrenRateCents: Value(childrenRateCents),
    ),
  );

  Future<void> updateGuestInfo(
    String id, {
    String? guestName,
    String? guestContact,
    String? notes,
  }) => (_db.update(_db.quotes)..where((q) => q.id.equals(id))).write(
    QuotesCompanion(
      guestName: Value(guestName),
      guestContact: Value(guestContact),
      notes: Value(notes),
    ),
  );

  Future<void> updateCounts(
    String id, {
    required int adultsCount,
    required int childrenCount,
  }) => (_db.update(_db.quotes)..where((q) => q.id.equals(id))).write(
    QuotesCompanion(
      adultsCount: Value(adultsCount),
      childrenCount: Value(childrenCount),
    ),
  );

  Future<void> updateDeposit(String id, int depositCents) =>
      (_db.update(_db.quotes)..where((q) => q.id.equals(id))).write(
        QuotesCompanion(depositCents: Value(depositCents)),
      );

  Future<void> updateStatus(String id, QuoteStatus status) =>
      (_db.update(_db.quotes)..where((q) => q.id.equals(id))).write(
        QuotesCompanion(status: Value(status)),
      );

  Future<void> markReserved(String id, String reservationId) =>
      (_db.update(_db.quotes)..where((q) => q.id.equals(id))).write(
        QuotesCompanion(
          status: const Value(QuoteStatus.reserved),
          reservationId: Value(reservationId),
        ),
      );

  /// Función pura (no toca la base de datos): el total no se guarda como
  /// columna para no desincronizarse si se edita una línea después.
  int totalCentsFor(
    List<QuoteDayLine> dayLines, {
    required int adultsCount,
    required int childrenCount,
  }) => dayLines.fold(
    0,
    (sum, line) =>
        sum +
        line.adultsRateCents * adultsCount +
        line.childrenRateCents * childrenCount,
  );
}
