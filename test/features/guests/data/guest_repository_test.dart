import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/guests/data/guest_repository.dart';

void main() {
  late AppDatabase db;
  late GuestRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = GuestRepository(db);
  });

  tearDown(() => db.close());

  test('watchAll emite una lista nueva sola al crear y al borrar', () async {
    final emissions = <int>[];
    final subscription = repository.watchAll().listen(
      (guests) => emissions.add(guests.length),
    );
    addTearDown(subscription.cancel);

    await Future<void>.delayed(Duration.zero);

    final id = await repository.create(fullName: 'Ana Pérez');
    await Future<void>.delayed(Duration.zero);

    await repository.delete(id);
    await Future<void>.delayed(Duration.zero);

    expect(emissions, [0, 1, 0]);
  });

  test('search encuentra por nombre o por documento', () async {
    await repository.create(fullName: 'Ana Pérez', documentId: '0102030405');
    await repository.create(fullName: 'Luis Torres', documentId: '0607080910');

    final byName = await repository.search('ana');
    final byDocument = await repository.search('0607');

    expect(byName, hasLength(1));
    expect(byName.single.fullName, 'Ana Pérez');
    expect(byDocument, hasLength(1));
    expect(byDocument.single.fullName, 'Luis Torres');
  });

  test(
    'update reemplaza los campos y watchAll refleja el cambio solo',
    () async {
      final id = await repository.create(fullName: 'Ana Pérez');

      final emissions = <String>[];
      final subscription = repository.watchAll().listen(
        (guests) => emissions.add(guests.single.fullName),
      );
      addTearDown(subscription.cancel);
      await Future<void>.delayed(Duration.zero);

      final current = await repository.getById(id);
      await repository.update(
        current.copyWith(
          fullName: 'Ana Pérez de Gómez',
          phone: const Value('0991234567'),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final updated = await repository.getById(id);
      expect(updated.fullName, 'Ana Pérez de Gómez');
      expect(updated.phone, '0991234567');
      expect(emissions.last, 'Ana Pérez de Gómez');
    },
  );
}
