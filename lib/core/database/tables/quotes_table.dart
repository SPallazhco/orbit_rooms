import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'properties_table.dart';
import 'reservations_table.dart';
import 'rooms_table.dart';

/// Antes de que exista un huésped o una reserva, la administradora arma y
/// envía una cotización por WhatsApp — a veces sin saber ni el nombre de
/// quien pregunta (ver docs/DECISIONS.md, caso real Hospedaje Shejiná).
enum QuoteStatus { pending, reserved, rejected }

class Quotes extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get propertyId => text().references(Properties, #id)();
  TextColumn get roomId => text().references(Rooms, #id)();

  /// Texto libre, no una `Guest`: al cotizar puede no haber ni nombre
  /// todavía.
  TextColumn get guestName => text().nullable()();
  TextColumn get guestContact => text().nullable()();

  DateTimeColumn get checkInDate => dateTime()();
  DateTimeColumn get checkOutDate => dateTime()();

  IntColumn get adultsCount => integer()();
  IntColumn get childrenCount => integer().withDefault(const Constant(0))();

  /// Sugerido como la mitad del total al crear la cotización, editable
  /// después — no hay una regla fija de anticipo.
  IntColumn get depositCents => integer()();

  /// Texto libre: pedidos especiales o qué incluye la cotización (ej.
  /// "incluye desayuno y garaje") — se reutiliza al compartir la imagen,
  /// sin agregar un campo de amenities aparte.
  TextColumn get notes => text().nullable()();

  TextColumn get status =>
      textEnum<QuoteStatus>().withDefault(Constant(QuoteStatus.pending.name))();

  /// Se completa al convertir la cotización en una reserva real.
  TextColumn get reservationId =>
      text().nullable().references(Reservations, #id)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
