import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Fechas de feriado, cargadas a mano por la administradora (sin
/// integración a un calendario externo — ver docs/DECISIONS.md). Afectan
/// el precio de cualquier habitación de cualquier propiedad ese día.
class Holidays extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  DateTimeColumn get date => dateTime()();
  TextColumn get name => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {date},
  ];
}
