import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/features/quotes/quotes_providers.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late String propertyId;
  late String roomId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );

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

  tearDown(() {
    container.dispose();
    return db.close();
  });

  test(
    'quotesProvider y quoteDayLinesProvider reflejan una cotización creada',
    () async {
      // No se usa `.future` (ver docs/DECISIONS.md).
      container.listen(quotesProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      expect(container.read(quotesProvider).value, isEmpty);

      final quoteId = await container
          .read(quoteRepositoryProvider)
          .create(
            propertyId: propertyId,
            roomId: roomId,
            checkInDate: DateTime(2026, 6, 4),
            checkOutDate: DateTime(2026, 6, 6),
            adultsCount: 3,
            childGroups: [
              (count: 3, rateCents: 700),
              (count: 1, rateCents: 500),
            ],
            guestName: 'Ana',
          );
      await Future<void>.delayed(Duration.zero);

      final quotes = container.read(quotesProvider).value;
      expect(quotes, hasLength(1));
      expect(quotes!.single.quote.guestName, 'Ana');
      expect(quotes.single.roomName, 'Cuarto 1');

      container.listen(quoteDayLinesProvider(quoteId), (_, _) {});
      await Future<void>.delayed(Duration.zero);
      final dayLines = container.read(quoteDayLinesProvider(quoteId)).value;
      expect(dayLines, hasLength(2));

      final key = (quoteId: quoteId, adultsCount: 3);
      container.listen(quoteBreakdownProvider(key), (_, _) {});
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      final breakdown = container.read(quoteBreakdownProvider(key)).value!;
      expect(breakdown.childrenCount, 4);
      expect(breakdown.nights, hasLength(2));
      // (1200+1500)*3 + (3*700 + 1*500)*2 = 8100 + 5200
      expect(breakdown.totalCents, 13300);
      expect(breakdown.hasUnpricedChildren, false);
    },
  );

  test('reminderInboxProvider muestra solo cotizaciones pendientes con '
      'check-in dentro de la ventana (3 días por defecto), separa las ya '
      'recordadas y se vacía al reservar o rechazar', () async {
    final repository = container.read(quoteRepositoryProvider);
    final today = DateTime.now();
    DateTime inDays(int days) =>
        DateTime(today.year, today.month, today.day + days);

    Future<String> quote(String name, int checkInDays) => repository.create(
      propertyId: propertyId,
      roomId: roomId,
      checkInDate: inDays(checkInDays),
      checkOutDate: inDays(checkInDays + 1),
      adultsCount: 2,
      guestName: name,
    );

    await quote('Fuera de ventana', 10);
    await quote('Ya pasó', -1);
    final hoy = await quote('Hoy', 0);
    final en3 = await quote('En tres días', 3);
    final recordada = await quote('Recordada', 2);
    final rechazada = await quote('Rechazada', 1);
    await repository.markReminderSent(recordada, DateTime.now());
    await repository.updateStatus(rechazada, QuoteStatus.rejected);

    container.listen(reminderInboxProvider, (_, _) {});
    for (var i = 0; i < 8; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    var inbox = container.read(reminderInboxProvider).value!;
    expect(inbox.toRemind.map((r) => r.quote.guestName), [
      'Hoy',
      'En tres días',
    ]);
    expect(inbox.toRemind.map((r) => r.daysLeft), [0, 3]);
    expect(inbox.reminded.map((r) => r.quote.guestName), ['Recordada']);

    await repository.updateStatus(hoy, QuoteStatus.reserved);
    await repository.updateStatus(en3, QuoteStatus.rejected);
    for (var i = 0; i < 8; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    inbox = container.read(reminderInboxProvider).value!;
    expect(inbox.toRemind, isEmpty);
    expect(inbox.reminded, hasLength(1));
  });
}
