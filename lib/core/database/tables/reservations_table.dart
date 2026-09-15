import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'guests_table.dart';

enum ReservationStatus { pending, confirmed, checkedIn, checkedOut, cancelled }

class Reservations extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get guestId => text().references(Guests, #id)();

  /// Fecha de calendario, sin hora (check-in es siempre a las 14:00).
  DateTimeColumn get checkInDate => dateTime()();

  /// Fecha de calendario, sin hora (check-out es siempre a las 11:00).
  DateTimeColumn get checkOutDate => dateTime()();

  TextColumn get status =>
      textEnum<ReservationStatus>().withDefault(
        Constant(ReservationStatus.pending.name),
      )();

  /// Precio final de la reserva, en centavos. Parte de un cálculo
  /// automático (tarifa x personas x noches por habitación) pero es
  /// editable a mano.
  IntColumn get totalPriceCents => integer()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
