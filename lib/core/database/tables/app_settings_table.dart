import 'package:drift/drift.dart';

class AppSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('app_settings'))();
  TextColumn get currency => text().withDefault(const Constant('USD'))();

  @override
  Set<Column> get primaryKey => {id};
}
