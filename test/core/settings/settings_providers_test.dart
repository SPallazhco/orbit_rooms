import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    return db.close();
  });

  test('currencyProvider empieza en USD por defecto y se actualiza solo tras '
      'guardar una nueva moneda', () async {
    // No se usa `.future` (ver docs/DECISIONS.md).
    container.listen(currencyProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    expect(container.read(currencyProvider).value, 'USD');

    await container.read(appSettingsRepositoryProvider).setCurrency('COP');
    await Future<void>.delayed(Duration.zero);

    expect(container.read(currencyProvider).value, 'COP');
  });

  test('holidaysProvider se actualiza solo al agregar y al quitar un feriado, '
      'ordenado por fecha', () async {
    container.listen(holidaysProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    expect(container.read(holidaysProvider).value, isEmpty);

    final repository = container.read(holidayRepositoryProvider);
    await repository.add(
      date: DateTime(2026, 11, 3),
      name: 'Independencia de Cuenca',
    );
    final newYearId = await repository.add(date: DateTime(2026, 1, 1));
    await Future<void>.delayed(Duration.zero);

    final holidays = container.read(holidaysProvider).value!;
    expect(holidays, hasLength(2));
    expect(holidays.first.date, DateTime(2026, 1, 1));
    expect(holidays.last.name, 'Independencia de Cuenca');

    await repository.remove(newYearId);
    await Future<void>.delayed(Duration.zero);

    final afterRemove = container.read(holidaysProvider).value!;
    expect(afterRemove, hasLength(1));
    expect(afterRemove.single.name, 'Independencia de Cuenca');
  });
}
