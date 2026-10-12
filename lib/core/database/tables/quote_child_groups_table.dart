import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'quotes_table.dart';

/// Los niños de una cotización no pagan todos lo mismo (ej. 3 de 8 años a
/// 7 y uno de 2 años a 5, ver docs/DECISIONS.md): cada grupo es "cuántos
/// niños" que comparten tarifa. La tarifa por noche vive en
/// `QuoteChildRates`, porque también varía con feriados y fines de semana.
class QuoteChildGroups extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get quoteId => text().references(Quotes, #id)();
  IntColumn get count => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
