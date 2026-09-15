import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'reservations_table.dart';

enum PaymentMethod { cash, transfer, card, other }

class Payments extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get reservationId => text().references(Reservations, #id)();

  /// Monto en centavos. Puede ser negativo: un reembolso es un pago más
  /// con monto negativo, no una entidad separada.
  IntColumn get amountCents => integer()();

  TextColumn get method => textEnum<PaymentMethod>()();
  DateTimeColumn get paidAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
