import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/features/reports/reports_providers.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';

/// `reportDataProvider` combina 3 `StreamProvider`s: cada uno necesita su
/// propia vuelta del event loop para emitir su primer valor tras un cambio
/// (mismo gotcha que `dashboardDataProvider`/`roomOccupancyProvider`, ver
/// docs/DECISIONS.md).
Future<void> _pump() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    return db.close();
  });

  test('reportDataProvider suma noches-habitación ocupadas e ingresos dentro '
      'del rango, ignorando lo que cae fuera', () async {
    const propertyId = 'property-a';
    const roomTypeId = 'room-type';
    const guestId = 'guest-1';
    const roomAId = 'room-a';
    const roomBId = 'room-b';

    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(id: Value(propertyId), name: 'Hostal'),
        );
    await db
        .into(db.roomTypes)
        .insert(RoomTypesCompanion.insert(id: Value(roomTypeId), name: 'Tipo'));
    await db
        .into(db.guests)
        .insert(
          GuestsCompanion.insert(id: Value(guestId), fullName: 'Ana Pérez'),
        );
    for (final roomId in [roomAId, roomBId]) {
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: Value(roomId),
              propertyId: propertyId,
              roomTypeId: roomTypeId,
              name: 'Cuarto $roomId',
              capacity: 4,
              ratePerPersonWeekdayCents: 1200,
              ratePerPersonWeekendCents: 1500,
              ratePerPersonHolidayCents: 2000,
            ),
          );
    }

    final reservationRepository = ReservationRepository(db);

    // roomA ocupada 3 noches dentro del rango del reporte (1-4 jun).
    final insideReservationId = await reservationRepository
        .createGroupReservation(
          guestId: guestId,
          checkInDate: DateTime(2026, 6, 1),
          checkOutDate: DateTime(2026, 6, 4),
          roomAssignments: [
            RoomAssignmentInput(roomId: roomAId, guestsCount: 2),
          ],
        );

    // roomB ocupada fuera del rango del reporte: no debe contarse.
    await reservationRepository.createGroupReservation(
      guestId: guestId,
      checkInDate: DateTime(2026, 7, 1),
      checkOutDate: DateTime(2026, 7, 3),
      roomAssignments: [RoomAssignmentInput(roomId: roomBId, guestsCount: 2)],
    );

    final range = (start: DateTime(2026, 6, 1), end: DateTime(2026, 6, 4));
    container.listen(reportDataProvider(range), (_, _) {});
    await _pump();

    // `paidAt` se inserta a mano (no vía `addPayment`, que usa
    // `DateTime.now()`) para poder controlar si cae dentro o fuera del
    // rango del reporte.
    await db
        .into(db.payments)
        .insert(
          PaymentsCompanion.insert(
            id: const Value('payment-inside'),
            reservationId: insideReservationId,
            amountCents: 5000,
            method: PaymentMethod.cash,
            paidAt: Value(DateTime(2026, 6, 2)),
          ),
        );
    // Pago fuera del rango: no debe sumarse a los ingresos del reporte.
    await db
        .into(db.payments)
        .insert(
          PaymentsCompanion.insert(
            id: const Value('payment-outside'),
            reservationId: insideReservationId,
            amountCents: 9999,
            method: PaymentMethod.cash,
            paidAt: Value(DateTime(2026, 8, 1)),
          ),
        );
    await _pump();

    final report = container.read(reportDataProvider(range)).value!;
    // 4 días (1,2,3,4 de junio) x 2 habitaciones = 8 noches-habitación
    // disponibles; roomA ocupada las noches del 1, 2 y 3 (checkout el 4).
    expect(report.totalRoomNights, 8);
    expect(report.occupiedRoomNights, 3);
    expect(report.incomeCents, 5000);
  });
}
