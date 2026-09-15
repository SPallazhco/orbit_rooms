import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/features/properties/properties_providers.dart';

void main() {
  test('activePropertiesProvider refleja loading -> data, y se actualiza solo '
      'después de crear una propiedad', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final states = <AsyncValue<List<Property>>>[];
    container.listen<AsyncValue<List<Property>>>(
      activePropertiesProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );

    // No se usa `.future`: es poco confiable con providers respaldados por
    // `.watch()` de Drift (ver docs/DECISIONS.md) — se lee `.value` tras
    // dejar pasar un tick, igual que la UI real (`ref.watch`).
    await Future<void>.delayed(Duration.zero);
    final initial = container.read(activePropertiesProvider).value;
    expect(initial, isEmpty);

    await container
        .read(propertyRepositoryProvider)
        .create(name: 'Hostal Central');

    // El provider se actualiza solo, sin invalidar nada a mano.
    await Future<void>.delayed(Duration.zero);
    final updated = container.read(activePropertiesProvider).value;
    expect(updated, hasLength(1));
    expect(updated!.single.name, 'Hostal Central');

    expect(states.any((s) => s.isLoading), isTrue);
  });
}
