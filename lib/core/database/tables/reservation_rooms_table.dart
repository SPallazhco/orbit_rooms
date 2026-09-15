import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'reservations_table.dart';
import 'rooms_table.dart';

/// Línea dentro de una [Reservations]: qué habitación se asignó dentro del
/// grupo y cuántas personas del grupo se alojan ahí. Una reserva de una
/// sola habitación tiene exactamente una fila acá.
class ReservationRooms extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get reservationId => text().references(Reservations, #id)();
  TextColumn get roomId => text().references(Rooms, #id)();
  IntColumn get guestsCount => integer()();

  /// Subtotal de esta línea, en centavos, calculado al momento de crear la
  /// reserva (tarifa vigente x personas x noches). Se guarda para no
  /// depender de que la tarifa de la habitación no cambie después.
  IntColumn get subtotalCents => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
