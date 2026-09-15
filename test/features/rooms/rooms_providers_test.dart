import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';
import 'package:uuid/uuid.dart';

void main() {
  test(
    'activeRoomsProvider se actualiza solo después de crear una habitación',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final propertyId = const Uuid().v4();
      final roomTypeId = const Uuid().v4();
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
            RoomTypesCompanion.insert(id: Value(roomTypeId), name: 'Tipo'),
          );

      // No se usa `.future`: es poco confiable con providers respaldados
      // por `.watch()` de Drift, con o sin join (ver docs/DECISIONS.md).
      // `ref.watch` + `AsyncValue` (lo que usa la UI real) no tiene ese
      // problema, así que el test se escribe igual que lo consume la app.
      container.listen(activeRoomsProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      final initial = container.read(activeRoomsProvider).value;
      expect(initial, isEmpty);

      await container
          .read(roomRepositoryProvider)
          .create(
            propertyId: propertyId,
            roomTypeId: roomTypeId,
            name: 'Cuarto 1',
            capacity: 4,
            ratePerPersonWeekdayCents: 1200,
            ratePerPersonWeekendCents: 1500,
            ratePerPersonHolidayCents: 2000,
          );

      await Future<void>.delayed(Duration.zero);
      final updated = container.read(activeRoomsProvider).value;

      expect(updated, hasLength(1));
      expect(updated!.single.propertyName, 'Hostal Central');
      expect(updated.single.room.name, 'Cuarto 1');
    },
  );
}
