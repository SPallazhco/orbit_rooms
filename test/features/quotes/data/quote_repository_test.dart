import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/quotes/data/quote_repository.dart';
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

  test('create arma una línea por noche con la tarifa de la habitación, niños '
      'en 0, y un depósito sugerido de la mitad del total', () async {
    final quoteId = await repository.create(
      propertyId: propertyId,
      roomId: roomId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adultsCount: 3,
      childrenCount: 1,
      guestName: 'Ana',
    );

    final dayLines = await repository.watchDayLines(quoteId).first;
    // jueves (1200) + viernes (1500) = dos noches.
    expect(dayLines, hasLength(2));
    expect(dayLines[0].adultsRateCents, 1200);
    expect(dayLines[0].childrenRateCents, 0);
    expect(dayLines[1].adultsRateCents, 1500);

    final quote = await repository.getById(quoteId);
    expect(quote.status, QuoteStatus.pending);
    expect(quote.adultsCount, 3);
    expect(quote.childrenCount, 1);
    // total = (1200+1500)*3 adultos = 8100; depósito sugerido = mitad.
    expect(quote.depositCents, 4050);
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

  test('updateDayLine edita una noche puntual (ej. descuento de niño) sin '
      'tocar las demás', () async {
    final quoteId = await repository.create(
      propertyId: propertyId,
      roomId: roomId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adultsCount: 3,
      childrenCount: 1,
    );

    final dayLines = await repository.watchDayLines(quoteId).first;
    await repository.updateDayLine(
      dayLines[1].id,
      adultsRateCents: dayLines[1].adultsRateCents,
      childrenRateCents: 700,
    );

    final updated = await repository.watchDayLines(quoteId).first;
    expect(updated[0].childrenRateCents, 0);
    expect(updated[1].childrenRateCents, 700);
  });

  test('totalCentsFor suma adultos y niños por línea', () async {
    final quoteId = await repository.create(
      propertyId: propertyId,
      roomId: roomId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      adultsCount: 3,
      childrenCount: 1,
    );
    final dayLines = await repository.watchDayLines(quoteId).first;
    await repository.updateDayLine(
      dayLines[1].id,
      adultsRateCents: dayLines[1].adultsRateCents,
      childrenRateCents: 700,
    );
    final updated = await repository.watchDayLines(quoteId).first;

    final total = repository.totalCentsFor(
      updated,
      adultsCount: 3,
      childrenCount: 1,
    );

    // (1200*3 + 0*1) + (1500*3 + 700*1) = 3600 + 5200 = 8800
    expect(total, 8800);
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
