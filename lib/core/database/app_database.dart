import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables/app_settings_table.dart';
import 'tables/guests_table.dart';
import 'tables/holidays_table.dart';
import 'tables/payments_table.dart';
import 'tables/properties_table.dart';
import 'tables/reservation_rooms_table.dart';
import 'tables/reservations_table.dart';
import 'tables/room_types_table.dart';
import 'tables/rooms_table.dart';
import 'tables/vehicles_table.dart';

export 'tables/payments_table.dart' show PaymentMethod;
export 'tables/reservations_table.dart' show ReservationStatus;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Properties,
    RoomTypes,
    Rooms,
    Guests,
    Reservations,
    ReservationRooms,
    Payments,
    AppSettings,
    Holidays,
    Vehicles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Instancia real de la app: abre (o crea) el archivo `.sqlite` en el
  /// almacenamiento del dispositivo.
  factory AppDatabase.connect() => AppDatabase(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'orbit_rooms.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
