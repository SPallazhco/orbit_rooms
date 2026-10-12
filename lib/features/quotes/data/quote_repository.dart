import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/domain/reservation_pricing.dart';
import 'package:uuid/uuid.dart';

typedef ChildGroupInput = ({int count, int rateCents});

class QuoteRepository {
  QuoteRepository(this._db);

  final AppDatabase _db;

  /// Arma una línea por noche con la tarifa de la habitación (entre
  /// semana/fin de semana/feriado — misma regla que
  /// `ReservationRepository.createGroupReservation`). Cada grupo de niños
  /// parte con la misma tarifa en todas las noches (la que se tipeó al
  /// cotizar), después se ajusta noche por noche — la administradora la
  /// decide caso a caso, ver docs/DECISIONS.md. El depósito sugerido es la
  /// mitad del total, editable después.
  Future<String> create({
    required String propertyId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int adultsCount,
    List<ChildGroupInput> childGroups = const [],
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

    final childrenPerNightCents = childGroups.fold(
      0,
      (sum, g) => sum + g.rateCents * g.count,
    );
    final totalCents = dayRates.fold(
      0,
      (sum, day) => sum + day.rateCents * adultsCount + childrenPerNightCents,
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

      for (var i = 0; i < childGroups.length; i++) {
        final groupId = const Uuid().v4();
        await _db
            .into(_db.quoteChildGroups)
            .insert(
              QuoteChildGroupsCompanion.insert(
                id: Value(groupId),
                quoteId: quoteId,
                count: childGroups[i].count,
                sortOrder: Value(i),
              ),
            );
        for (final day in dayRates) {
          await _db
              .into(_db.quoteChildRates)
              .insert(
                QuoteChildRatesCompanion.insert(
                  groupId: groupId,
                  date: day.date,
                  rateCents: Value(childGroups[i].rateCents),
                ),
              );
        }
      }
    });

    return quoteId;
  }

  Future<Quote> getById(String id) =>
      (_db.select(_db.quotes)..where((q) => q.id.equals(id))).getSingle();

  /// Reactivo, mismo patrón que `ReservationRepository.watchAll()`: se
  /// actualiza solo al crear/editar/cambiar de estado una cotización.
  /// `ownerName` viaja junto (no solo `propertyName`) para que la UI sepa
  /// si es la propiedad propia del usuario (`ownerName` vacío) — usado
  /// para decidir si la imagen de la cotización lleva la marca del
  /// hostal o no, ver docs/DECISIONS.md.
  Stream<
    List<
      ({Quote quote, String propertyName, String? ownerName, String roomName})
    >
  >
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
        return (
          quote: quote,
          propertyName: property.name,
          ownerName: property.ownerName,
          roomName: room.name,
        );
      }).toList(),
    );
  }

  Stream<List<QuoteDayLine>> watchDayLines(String quoteId) =>
      (_db.select(_db.quoteDayLines)
            ..where((l) => l.quoteId.equals(quoteId))
            ..orderBy([(l) => OrderingTerm.asc(l.date)]))
          .watch();

  /// Para la lista de cotizaciones: totales y conteo de niños de todas las
  /// cotizaciones de una vez (ver `quoteSummariesProvider`).
  Stream<List<QuoteDayLine>> watchAllDayLines() =>
      _db.select(_db.quoteDayLines).watch();

  Stream<List<QuoteChildGroup>> watchAllChildGroups() =>
      _db.select(_db.quoteChildGroups).watch();

  Stream<List<QuoteChildRate>> watchAllChildRates() =>
      _db.select(_db.quoteChildRates).watch();

  Stream<List<QuoteChildGroup>> watchChildGroups(String quoteId) =>
      (_db.select(_db.quoteChildGroups)
            ..where((g) => g.quoteId.equals(quoteId))
            ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]))
          .watch();

  Stream<List<QuoteChildRate>> watchChildRates(String quoteId) {
    final query = _db.select(_db.quoteChildRates).join([
      innerJoin(
        _db.quoteChildGroups,
        _db.quoteChildGroups.id.equalsExp(_db.quoteChildRates.groupId),
      ),
    ])..where(_db.quoteChildGroups.quoteId.equals(quoteId));

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(_db.quoteChildRates)).toList(),
    );
  }

  /// Edita una noche puntual: la tarifa de adulto y la de cada grupo de
  /// niños (`childRatesByGroupId`). Con [applyChildRatesToAllNights] las
  /// tarifas de niños se copian a todas las noches de la cotización — la
  /// de adulto no, porque varía sola con feriados y fines de semana.
  Future<void> updateNight(
    QuoteDayLine line, {
    required int adultsRateCents,
    required Map<String, int> childRatesByGroupId,
    bool applyChildRatesToAllNights = false,
  }) => _db.transaction(() async {
    await (_db.update(_db.quoteDayLines)..where((l) => l.id.equals(line.id)))
        .write(QuoteDayLinesCompanion(adultsRateCents: Value(adultsRateCents)));

    final dates = applyChildRatesToAllNights
        ? (await (_db.select(
            _db.quoteDayLines,
          )..where((l) => l.quoteId.equals(line.quoteId))).get()).map(
            (l) => l.date,
          )
        : [line.date];

    for (final date in dates) {
      for (final entry in childRatesByGroupId.entries) {
        await _setChildRate(entry.key, date, entry.value);
      }
    }
  });

  Future<void> _setChildRate(
    String groupId,
    DateTime date,
    int rateCents,
  ) async {
    final updated =
        await (_db.update(_db.quoteChildRates)
              ..where((r) => r.groupId.equals(groupId) & r.date.equals(date)))
            .write(QuoteChildRatesCompanion(rateCents: Value(rateCents)));
    if (updated == 0) {
      await _db
          .into(_db.quoteChildRates)
          .insert(
            QuoteChildRatesCompanion.insert(
              groupId: groupId,
              date: date,
              rateCents: Value(rateCents),
            ),
          );
    }
  }

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

  Future<void> updateDeposit(String id, int depositCents) =>
      (_db.update(_db.quotes)..where((q) => q.id.equals(id))).write(
        QuotesCompanion(depositCents: Value(depositCents)),
      );

  Future<void> markReminderSent(String id, DateTime at) =>
      (_db.update(_db.quotes)..where((q) => q.id.equals(id))).write(
        QuotesCompanion(reminderSentAt: Value(at)),
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
}
