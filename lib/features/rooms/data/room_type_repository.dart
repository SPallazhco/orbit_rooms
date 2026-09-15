import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

/// Los tipos de habitación los crea y reutiliza el propio usuario — no es
/// una lista fija de la app (ver docs/DECISIONS.md).
class RoomTypeRepository {
  RoomTypeRepository(this._db);

  final AppDatabase _db;

  Future<List<RoomType>> getAll() => _db.select(_db.roomTypes).get();

  Future<String> create(String name) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.roomTypes)
        .insert(RoomTypesCompanion.insert(id: Value(id), name: name));
    return id;
  }
}
