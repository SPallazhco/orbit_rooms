import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'quote_child_groups_table.dart';

/// Tarifa por persona de un grupo de niños en una noche puntual — editable
/// a mano, igual que la de adulto en `QuoteDayLines`. `date` coincide con
/// la de la línea de esa noche.
class QuoteChildRates extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get groupId => text().references(QuoteChildGroups, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get rateCents => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {groupId, date},
  ];
}
