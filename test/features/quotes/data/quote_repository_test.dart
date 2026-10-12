import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/quotes/data/quote_repository.dart';
import 'package:orbit_rooms/features/quotes/domain/quote_pricing.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late QuoteRepository repository;
  late String propertyId;
  late String roomId;

  // 2026-06-04 = jueves (entre semana), 05/06/06 = viernes/sábado (fin de
  // semana).
  final checkIn = DateTime(2026, 6, 4);
  final checkOut = DateTime(2026, 6, 6);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = QuoteRepository(db);

    propertyId = const Uuid().v4();
    final roomTypeId = const Uuid().v4();
    roomId = const Uuid().v4();

    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(id: Value(propertyId), name: 'Hostal'),
        );
    await db
        .into(db.roomTypes)
        .insert(RoomTypesCompanion.insert(id: Value(roomTypeId), name: 'Tipo'));
    await db
        .into(db.rooms)
        .insert(
          RoomsCompanion.insert(
            id: Value(roomId),
            propertyId: propertyId,
            roomTypeId: roomTypeId,
            name: 'Cuarto 1',
            capacity: 4,
            ratePerPersonWeekdayCents: 1200,
            ratePerPersonWeekendCents: 1500,
            ratePerPersonHolidayCents: 2000,
          ),
        );
  });

  tearDown(() => db.close());

  test('create arma una línea por noche con la tarifa de la habitación, un '
      'grupo de niños por tarifa repetido en cada noche, y un depósito '
      'sugerido de la mitad del total', () async {
    final quoteId = await repository.create(
      propertyId: propertyId,
      roomId: roomId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adultsCount: 3,
      childGroups: [(count: 3, rateCents: 700), (count: 1, rateCents: 500)],
      guestName: 'Ana',
    );

    final dayLines = await repository.watchDayLines(quoteId).first;
    // jueves (1200) + viernes (1500) = dos noches.
    expect(dayLines, hasLength(2));
    expect(dayLines[0].adultsRateCents, 1200);
    expect(dayLines[1].adultsRateCents, 1500);

    final groups = await repository.watchChildGroups(quoteId).first;
    expect(groups.map((g) => g.count), [3, 1]);
    final rates = await repository.watchChildRates(quoteId).first;
    expect(rates, hasLength(4));
    expect(
      rates.where((r) => r.groupId == groups[0].id).map((r) => r.rateCents),
      [700, 700],
    );
    expect(
      rates.where((r) => r.groupId == groups[1].id).map((r) => r.rateCents),
      [500, 500],
    );

    final quote = await repository.getById(quoteId);
    expect(quote.status, QuoteStatus.pending);
    expect(quote.adultsCount, 3);
    // adultos (1200+1500)*3 = 8100 + niños (3*700 + 1*500)*2 noches = 5200
    // → total 13300; depósito sugerido = mitad.
    expect(quote.depositCents, 6650);
  });

  test('sin niños no se crea ningún grupo', () async {
    final quoteId = await repository.create(
      propertyId: propertyId,
      roomId: roomId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adultsCount: 2,
    );

    expect(await repository.watchChildGroups(quoteId).first, isEmpty);
    expect(await repository.watchChildRates(quoteId).first, isEmpty);
  });

  test('watchAll se actualiza solo al crear una cotización y trae nombre de '
      'propiedad y habitación', () async {
    final emissions = <int>[];
    final subscription = repository.watchAll().listen(
      (quotes) => emissions.add(quotes.length),
    );
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);

    await repository.create(
      propertyId: propertyId,
      roomId: roomId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adultsCount: 2,
    );
    await Future<void>.delayed(Duration.zero);

    final withQuote = await repository.watchAll().first;
    expect(withQuote, hasLength(1));
    expect(withQuote.single.propertyName, 'Hostal');
    expect(withQuote.single.roomName, 'Cuarto 1');

    expect(emissions, [0, 1]);
  });

  test('updateNight edita una noche puntual (adulto y cada grupo de niños) '
      'sin tocar las demás', () async {
    final quoteId = await repository.create(
      propertyId: propertyId,
      roomId: roomId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adultsCount: 3,
      childGroups: [(count: 3, rateCents: 700), (count: 1, rateCents: 500)],
    );
    final dayLines = await repository.watchDayLines(quoteId).first;
    final groups = await repository.watchChildGroups(quoteId).first;

    await repository.updateNight(
      dayLines[1],
      adultsRateCents: 1800,
      childRatesByGroupId: {groups[0].id: 900, groups[1].id: 600},
    );

    final updatedLines = await repository.watchDayLines(quoteId).first;
    expect(updatedLines.map((l) => l.adultsRateCents), [1200, 1800]);

    final breakdown = buildQuoteBreakdown(
      adultsCount: 3,
      dayLines: updatedLines,
      groups: groups,
      rates: await repository.watchChildRates(quoteId).first,
    );
    expect(breakdown.nights[0].children.map((c) => c.rateCents), [700, 500]);
    expect(breakdown.nights[1].children.map((c) => c.rateCents), [900, 600]);
    // noche 1: 1200*3 + 3*700 + 1*500 = 6200
    // noche 2: 1800*3 + 3*900 + 1*600 = 8700
    expect(breakdown.totalCents, 14900);
  });

  test('updateNight con applyChildRatesToAllNights copia las tarifas de niños '
      'a todas las noches pero no la de adulto', () async {
    final quoteId = await repository.create(
      propertyId: propertyId,
      roomId: roomId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adultsCount: 2,
      childGroups: [(count: 2, rateCents: 0)],
    );
    final dayLines = await repository.watchDayLines(quoteId).first;
    final groups = await repository.watchChildGroups(quoteId).first;

    await repository.updateNight(
      dayLines[0],
      adultsRateCents: dayLines[0].adultsRateCents,
      childRatesByGroupId: {groups.single.id: 800},
      applyChildRatesToAllNights: true,
    );

    final rates = await repository.watchChildRates(quoteId).first;
    expect(rates.map((r) => r.rateCents), [800, 800]);
    final lines = await repository.watchDayLines(quoteId).first;
    expect(lines.map((l) => l.adultsRateCents), [1200, 1500]);
  });

  test(
    'updateStatus cambia el estado y markReserved lo liga a una reserva',
    () async {
      final quoteId = await repository.create(
        propertyId: propertyId,
        roomId: roomId,
        checkInDate: checkIn,
        checkOutDate: checkOut,
        adultsCount: 2,
      );

      await repository.updateStatus(quoteId, QuoteStatus.rejected);
      expect((await repository.getById(quoteId)).status, QuoteStatus.rejected);

      // `reservationId` es una FK real: hace falta una `Reservation` real
      // (y su `Guest`) para poder ligarla, `PRAGMA foreign_keys = ON`
      // rechazaría un id inventado.
      final guestId = const Uuid().v4();
      await db
          .into(db.guests)
          .insert(
            GuestsCompanion.insert(id: Value(guestId), fullName: 'Ana Pérez'),
          );
      final reservationId = const Uuid().v4();
      await db
          .into(db.reservations)
          .insert(
            ReservationsCompanion.insert(
              id: Value(reservationId),
              guestId: guestId,
              checkInDate: checkIn,
              checkOutDate: checkOut,
              totalPriceCents: 8100,
            ),
          );

      await repository.markReserved(quoteId, reservationId);
      final quote = await repository.getById(quoteId);
      expect(quote.status, QuoteStatus.reserved);
      expect(quote.reservationId, reservationId);
    },
  );
}
