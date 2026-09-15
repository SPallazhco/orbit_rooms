import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('inserta y lee una propiedad con sus habitaciones', () async {
    const propertyId = 'property-1';
    const roomTypeId = 'room-type-1';
    const roomId = 'room-1';

    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(
            id: Value(propertyId),
            name: 'Hostal Central',
          ),
        );
    await db
        .into(db.roomTypes)
        .insert(
          RoomTypesCompanion.insert(
            id: Value(roomTypeId),
            name: 'Dormitorio compartido',
          ),
        );
    await db
        .into(db.rooms)
        .insert(
          RoomsCompanion.insert(
            id: Value(roomId),
            propertyId: propertyId,
            roomTypeId: roomTypeId,
            name: 'Cuarto 1',
            capacity: 4,
            ratePerPersonWeekdayCents: 1200,
            ratePerPersonWeekendCents: 1500,
            ratePerPersonHolidayCents: 2000,
          ),
        );

    final rooms = await db.select(db.rooms).get();

    expect(rooms, hasLength(1));
    expect(rooms.single.id, roomId);
    expect(rooms.single.ratePerPersonWeekendCents, 1500);
    expect(rooms.single.isActive, isTrue);
  });

  test(
    'una reserva de grupo puede aceptar varios pagos, incluido un reembolso',
    () async {
      final guestId = const Uuid().v4();
      final reservationId = const Uuid().v4();

      await db
          .into(db.guests)
          .insert(
            GuestsCompanion.insert(
              id: Value(guestId),
              fullName: 'Familia Pérez',
            ),
          );

      await db
          .into(db.reservations)
          .insert(
            ReservationsCompanion.insert(
              id: Value(reservationId),
              guestId: guestId,
              checkInDate: DateTime(2026, 6, 1),
              checkOutDate: DateTime(2026, 6, 3),
              totalPriceCents: 4800,
            ),
          );

      final reservation = await (db.select(
        db.reservations,
      )..where((r) => r.id.equals(reservationId))).getSingle();

      expect(reservation.status, ReservationStatus.pending);

      await db
          .into(db.payments)
          .insert(
            PaymentsCompanion.insert(
              reservationId: reservationId,
              amountCents: 4800,
              method: PaymentMethod.cash,
            ),
          );
      await db
          .into(db.payments)
          .insert(
            PaymentsCompanion.insert(
              reservationId: reservationId,
              amountCents: -1000,
              method: PaymentMethod.cash,
            ),
          );

      final payments = await (db.select(
        db.payments,
      )..where((p) => p.reservationId.equals(reservationId))).get();

      final balance = payments.fold<int>(0, (sum, p) => sum + p.amountCents);

      expect(payments, hasLength(2));
      expect(balance, 3800);
    },
  );
}
