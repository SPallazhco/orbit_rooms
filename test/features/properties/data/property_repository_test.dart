import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/properties/data/property_repository.dart';

void main() {
  late AppDatabase db;
  late PropertyRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = PropertyRepository(db);
  });

  tearDown(() => db.close());

  test(
    'watchActive emite una lista nueva sola cuando se crea o desactiva una propiedad',
    () async {
      final emissions = <int>[];
      final subscription = repository.watchActive().listen(
        (properties) => emissions.add(properties.length),
      );
      addTearDown(subscription.cancel);

      // Deja que la primera emisión (lista vacía) llegue antes de escribir.
      await Future<void>.delayed(Duration.zero);

      final id = await repository.create(name: 'Hostal Central');
      await Future<void>.delayed(Duration.zero);

      await repository.deactivate(id);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, [0, 1, 0]);
    },
  );

  test('watchActive no incluye propiedades desactivadas', () async {
    final id = await repository.create(name: 'Hostal Central');
    await repository.deactivate(id);

    final properties = await repository.watchActive().first;

    expect(properties, isEmpty);
  });
}
