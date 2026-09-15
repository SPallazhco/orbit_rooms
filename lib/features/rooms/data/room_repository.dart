import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

class RoomRepository {
  RoomRepository(this._db);

  final AppDatabase _db;

  Future<List<Room>> getActiveByProperty(String propertyId) =>
      (_db.select(_db.rooms)..where(
            (r) => r.propertyId.equals(propertyId) & r.isActive.equals(true),
          ))
          .get();

  Future<Room> getById(String id) =>
      (_db.select(_db.rooms)..where((r) => r.id.equals(id))).getSingle();

  /// Todas las habitaciones activas de todas las propiedades, con el
  /// nombre de la propiedad ya resuelto (para agrupar en la UI sin una
  /// consulta aparte). Reactivo: se actualiza solo con `.watch()` de
  /// Drift, igual que `PropertyRepository.watchActive()`.
  Stream<List<({Room room, String propertyName})>> watchAllActive() {
    final query = _db.select(_db.rooms).join([
      innerJoin(
        _db.properties,
        _db.properties.id.equalsExp(_db.rooms.propertyId),
      ),
    ])..where(_db.rooms.isActive.equals(true));

    return query.watch().map(
      (rows) => rows.map((row) {
        final room = row.readTable(_db.rooms);
        final property = row.readTable(_db.properties);
        return (room: room, propertyName: property.name);
      }).toList(),
    );
  }

  /// La capacidad es orientativa, no un límite que la app haga cumplir (ver
  /// docs/DECISIONS.md).
  Future<String> create({
    required String propertyId,
    required String roomTypeId,
    required String name,
    required int capacity,
    required int ratePerPersonWeekdayCents,
    required int ratePerPersonWeekendCents,
    required int ratePerPersonHolidayCents,
  }) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.rooms)
        .insert(
          RoomsCompanion.insert(
            id: Value(id),
            propertyId: propertyId,
            roomTypeId: roomTypeId,
            name: name,
            capacity: capacity,
            ratePerPersonWeekdayCents: ratePerPersonWeekdayCents,
            ratePerPersonWeekendCents: ratePerPersonWeekendCents,
            ratePerPersonHolidayCents: ratePerPersonHolidayCents,
          ),
        );
    return id;
  }

  Future<void> update(Room room) => _db.update(_db.rooms).replace(room);

  Future<void> deactivate(String id) =>
      (_db.update(_db.rooms)..where((r) => r.id.equals(id))).write(
        const RoomsCompanion(isActive: Value(false)),
      );
}
