import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'properties_table.dart';
import 'room_types_table.dart';

class Rooms extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get propertyId => text().references(Properties, #id)();
  TextColumn get roomTypeId => text().references(RoomTypes, #id)();
  TextColumn get name => text()();
  IntColumn get capacity => integer()();

  /// Tarifa por persona, en centavos, lunes a jueves.
  IntColumn get ratePerPersonWeekdayCents => integer()();

  /// Tarifa por persona, en centavos, viernes a domingo.
  IntColumn get ratePerPersonWeekendCents => integer()();

  /// Tarifa por persona, en centavos, en fechas cargadas como feriado
  /// (tabla `Holidays`). Tiene prioridad sobre entre-semana/fin-de-semana.
  IntColumn get ratePerPersonHolidayCents => integer()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
