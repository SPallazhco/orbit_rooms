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
            childrenCount: 1,
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
    },
  );
}
