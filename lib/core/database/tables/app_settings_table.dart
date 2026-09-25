import 'package:drift/drift.dart';

class AppSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('app_settings'))();
  TextColumn get currency => text().withDefault(const Constant('USD'))();

  /// Días de anticipación para el recordatorio de "recontactar" una
  /// cotización pendiente (PRD 5.4 extendido — ver docs/DECISIONS.md).
  IntColumn get quoteReminderDays => integer().withDefault(const Constant(3))();

  @override
  Set<Column> get primaryKey => {id};
}
