import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'quotes_table.dart';

/// Una línea por noche de una `Quote`: tarifa de adulto (precargada desde
/// la habitación, editable). Las de niños viven aparte, por grupo, en
/// `QuoteChildRates` (ver docs/DECISIONS.md).
class QuoteDayLines extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get quoteId => text().references(Quotes, #id)();
  DateTimeColumn get date => dateTime()();

  IntColumn get adultsRateCents => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {quoteId, date},
  ];
}
