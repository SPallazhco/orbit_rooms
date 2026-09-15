import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/settings/holiday_repository.dart';

void main() {
  late AppDatabase db;
  late HolidayRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = HolidayRepository(db);
  });

  tearDown(() => db.close());

  test('agrega y lista feriados', () async {
    await repository.add(
      date: DateTime(2026, 11, 3),
      name: 'Independencia de Cuenca',
    );
    await repository.add(date: DateTime(2026, 1, 1));

    final holidays = await repository.getAll();

    expect(holidays, hasLength(2));
    expect(holidays.map((h) => h.name), contains('Independencia de Cuenca'));
  });

  test('elimina un feriado', () async {
    final id = await repository.add(date: DateTime(2026, 1, 1));

    await repository.remove(id);

    expect(await repository.getAll(), isEmpty);
  });
}
