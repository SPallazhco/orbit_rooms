import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v3.dart' as v3;

/// La v3→v4 mueve datos reales (cuántos niños y cuánto pagan por noche) de
/// dos columnas de `quotes`/`quote_day_lines` a las tablas de grupos y
/// tarifas: el test genérico de `migration_test.dart` solo valida el
/// esquema, no que las cotizaciones existentes conserven sus tarifas.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('las cotizaciones con niños pasan a un solo grupo que conserva la '
      'tarifa de cada noche; las que no tenían niños no crean grupo', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(3);
    final oldDb = v3.DatabaseAtV3(schema.newConnection());

    await oldDb.customStatement(
      "INSERT INTO properties (id, name) VALUES ('p1', 'Hostal')",
    );
    await oldDb.customStatement(
      "INSERT INTO room_types (id, name) VALUES ('t1', 'Tipo')",
    );
    await oldDb.customStatement('''
      INSERT INTO rooms (id, property_id, room_type_id, name, capacity,
        rate_per_person_weekday_cents, rate_per_person_weekend_cents,
        rate_per_person_holiday_cents)
      VALUES ('r1', 'p1', 't1', 'Cuarto 1', 4, 1200, 1500, 2000)
    ''');
    for (final (id, children) in [('q-con-ninos', 4), ('q-sin-ninos', 0)]) {
      await oldDb.customStatement('''
        INSERT INTO quotes (id, property_id, room_id, check_in_date,
          check_out_date, adults_count, children_count, deposit_cents)
        VALUES ('$id', 'p1', 'r1', 1780531200, 1780704000, 2, $children, 1000)
      ''');
      await oldDb.customStatement('''
        INSERT INTO quote_day_lines (id, quote_id, date, adults_rate_cents,
          children_rate_cents)
        VALUES ('$id-d1', '$id', 1780531200, 1200, 700),
               ('$id-d2', '$id', 1780617600, 1500, 500)
      ''');
    }
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);

    final groups = await db.select(db.quoteChildGroups).get();
    expect(groups, hasLength(1));
    expect(groups.single.quoteId, 'q-con-ninos');
    expect(groups.single.count, 4);

    final rates = await (db.select(
      db.quoteChildRates,
    )..orderBy([(r) => OrderingTerm.asc(r.date)])).get();
    expect(rates.map((r) => r.groupId).toSet(), {groups.single.id});
    expect(rates.map((r) => r.rateCents), [700, 500]);

    final lines = await db.select(db.quoteDayLines).get();
    expect(lines.map((l) => l.adultsRateCents), containsAll([1200, 1500]));
    await db.close();
  });
}
