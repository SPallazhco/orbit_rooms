import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/features/guests/guests_providers.dart';

void main() {
  test(
    'guestsProvider se actualiza solo después de crear un huésped',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      // No se usa `.future`: es poco confiable con providers respaldados
      // por `.watch()` de Drift (ver docs/DECISIONS.md). Se usa
      // `container.listen` + `.value`, igual que la UI real (`ref.watch`).
      container.listen(guestsProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      final initial = container.read(guestsProvider).value;
      expect(initial, isEmpty);

      await container
          .read(guestRepositoryProvider)
          .create(fullName: 'Ana Pérez');

      await Future<void>.delayed(Duration.zero);
      final updated = container.read(guestsProvider).value;

      expect(updated, hasLength(1));
      expect(updated!.single.fullName, 'Ana Pérez');
    },
  );
}
