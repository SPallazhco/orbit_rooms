import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class Properties extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get ownerName => text().nullable()();
  TextColumn get ownerContact => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
