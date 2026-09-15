import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

class PropertyRepository {
  PropertyRepository(this._db);

  final AppDatabase _db;

  Future<List<Property>> getActive() =>
      (_db.select(_db.properties)..where((p) => p.isActive.equals(true))).get();

  /// Igual que [getActive], pero reactivo: emite una lista nueva cada vez
  /// que cambia algo en `Properties` (Drift lo da gratis con `.watch()`),
  /// sin necesidad de invalidar el provider a mano después de un
  /// create/update/deactivate.
  Stream<List<Property>> watchActive() => (_db.select(
    _db.properties,
  )..where((p) => p.isActive.equals(true))).watch();

  Future<String> create({
    required String name,
    String? address,
    String? ownerName,
    String? ownerContact,
    bool isPrimary = false,
  }) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.properties)
        .insert(
          PropertiesCompanion.insert(
            id: Value(id),
            name: name,
            address: Value(address),
            ownerName: Value(ownerName),
            ownerContact: Value(ownerContact),
            isPrimary: Value(isPrimary),
          ),
        );
    return id;
  }

  Future<void> update(Property property) =>
      _db.update(_db.properties).replace(property);

  Future<void> deactivate(String id) =>
      (_db.update(_db.properties)..where((p) => p.id.equals(id))).write(
        const PropertiesCompanion(isActive: Value(false)),
      );
}
