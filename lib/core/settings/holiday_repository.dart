import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

/// Fechas de feriado cargadas a mano por la administradora (PRD 5.9). Sin
/// integración a un calendario externo — ver docs/DECISIONS.md.
class HolidayRepository {
  HolidayRepository(this._db);

  final AppDatabase _db;

  Future<List<Holiday>> getAll() => _db.select(_db.holidays).get();

  Future<String> add({required DateTime date, String? name}) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.holidays)
        .insert(
          HolidaysCompanion.insert(
            id: Value(id),
            date: date,
            name: Value(name),
          ),
        );
    return id;
  }

  Future<void> remove(String id) =>
      (_db.delete(_db.holidays)..where((h) => h.id.equals(id))).go();
}
