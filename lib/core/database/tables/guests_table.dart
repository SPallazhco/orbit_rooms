import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class Guests extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get fullName => text()();
  TextColumn get documentId => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
