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
import 'tables/quote_child_groups_table.dart';
import 'tables/quote_child_rates_table.dart';
import 'tables/quote_day_lines_table.dart';
import 'tables/quotes_table.dart';
import 'tables/reservation_rooms_table.dart';
import 'tables/reservations_table.dart';
import 'tables/room_types_table.dart';
import 'tables/rooms_table.dart';
import 'tables/vehicles_table.dart';
import 'app_database.steps.dart';

export 'tables/payments_table.dart' show PaymentMethod;
export 'tables/quotes_table.dart' show QuoteStatus;
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
    Quotes,
    QuoteDayLines,
    QuoteChildGroups,
    QuoteChildRates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Instancia real de la app: abre (o crea) el archivo `.sqlite` en el
  /// almacenamiento del dispositivo.
  factory AppDatabase.connect() => AppDatabase(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.createTable(schema.quotes);
        await m.createTable(schema.quoteDayLines);
        await m.addColumn(
          schema.appSettings,
          schema.appSettings.quoteReminderDays,
        );
      },
      from2To3: (m, schema) async {
        await m.addColumn(schema.vehicles, schema.vehicles.garageFeeCents);
      },
      from3To4: (m, schema) async {
        await m.createTable(schema.quoteChildGroups);
        await m.createTable(schema.quoteChildRates);
        await customStatement('''
          INSERT INTO quote_child_groups (id, quote_id, "count", sort_order)
          SELECT lower(hex(randomblob(16))), id, children_count, 0
          FROM quotes WHERE children_count > 0
        ''');
        await customStatement('''
          INSERT INTO quote_child_rates (id, group_id, date, rate_cents)
          SELECT lower(hex(randomblob(16))), g.id, l.date, l.children_rate_cents
          FROM quote_day_lines l
          JOIN quote_child_groups g ON g.quote_id = l.quote_id
        ''');
        await m.dropColumn(schema.quotes, 'children_count');
        await m.dropColumn(schema.quoteDayLines, 'children_rate_cents');
      },
      from4To5: (m, schema) async {
        await m.addColumn(schema.quotes, schema.quotes.reminderSentAt);
        await m.addColumn(
          schema.appSettings,
          schema.appSettings.reminderMessageTemplate,
        );
      },
    ),
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
