import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'reservations_table.dart';

/// Vehículos declarados para una reserva (PRD 5.4): el hospedaje incluye
/// garaje, y cada auto debe quedar atado a la reserva (y por lo tanto al
/// huésped, vía `Reservation.guestId`) para el reporte diario al dueño del
/// parqueadero y para poder contactar al huésped si hay un problema (mal
/// estacionado, etc.). Un huésped puede declarar más de un vehículo.
class Vehicles extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get reservationId => text().references(Reservations, #id)();
  TextColumn get plate => text()();

  /// Cuánto se resta del ingreso de esa noche por tener este auto ahí, en
  /// el reporte de comisión de una casa administrada (PRD 9) — decidido a
  /// mano por la administradora ("a conveniencia", sin fórmula fija).
  /// `null` = no hay descuento de garaje (mismo efecto que no tener auto).
  IntColumn get garageFeeCents => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
