import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

class VehicleRepository {
  VehicleRepository(this._db);

  final AppDatabase _db;

  Future<List<Vehicle>> getForReservation(String reservationId) => (_db.select(
    _db.vehicles,
  )..where((v) => v.reservationId.equals(reservationId))).get();

  Future<String> create({
    required String reservationId,
    required String plate,
  }) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.vehicles)
        .insert(
          VehiclesCompanion.insert(
            id: Value(id),
            reservationId: reservationId,
            plate: plate.trim().toUpperCase(),
          ),
        );
    return id;
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.vehicles)..where((v) => v.id.equals(id))).go();
}
