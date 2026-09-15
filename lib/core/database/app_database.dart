import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'tables/app_settings_table.dart';
import 'tables/guests_table.dart';
import 'tables/payments_table.dart';
import 'tables/properties_table.dart';
import 'tables/reservation_rooms_table.dart';
import 'tables/reservations_table.dart';
import 'tables/room_types_table.dart';
import 'tables/rooms_table.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
