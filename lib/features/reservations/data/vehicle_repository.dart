import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

class VehicleRepository {
  VehicleRepository(this._db);

  final AppDatabase _db;

  Future<List<Vehicle>> getForReservation(String reservationId) => (_db.select(
    _db.vehicles,
  )..where((v) => v.reservationId.equals(reservationId))).get();

  /// Reactivo, para el reporte de garaje (PRD 9): todos los vehículos de
  /// todas las reservas, cruzado luego con la reserva activa ese día en el
  /// provider derivado (`garageReportProvider`), no acá.
  Stream<List<Vehicle>> watchAll() => _db.select(_db.vehicles).watch();

  Future<String> create({
    required String reservationId,
    required String plate,
    int? garageFeeCents,
  }) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.vehicles)
        .insert(
          VehiclesCompanion.insert(
            id: Value(id),
            reservationId: reservationId,
            plate: plate.trim().toUpperCase(),
            garageFeeCents: Value(garageFeeCents),
          ),
        );
    return id;
  }

  /// Comisión de garaje (PRD 9): "a conveniencia" de la administradora, sin
  /// fórmula fija — se edita a mano después de registrar el auto.
  Future<void> updateGarageFee(String id, int? garageFeeCents) =>
      (_db.update(_db.vehicles)..where((v) => v.id.equals(id))).write(
        VehiclesCompanion(garageFeeCents: Value(garageFeeCents)),
      );

  Future<void> delete(String id) =>
      (_db.delete(_db.vehicles)..where((v) => v.id.equals(id))).go();
}
