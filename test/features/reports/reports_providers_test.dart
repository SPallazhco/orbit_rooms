import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/features/reports/reports_providers.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';
import 'package:orbit_rooms/features/reservations/data/vehicle_repository.dart';

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

  test('garageReportProvider trae solo los vehículos de reservas activas ese '
      'día, con huésped/celular/casa+habitación/placa', () async {
    const propertyId = 'property-a';
    const roomTypeId = 'room-type';
    const roomId = 'room-a';
    const activeGuestId = 'guest-active';
    const otherGuestId = 'guest-other';

    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(
            id: Value(propertyId),
            name: 'Hospedaje Shejina',
          ),
        );
    await db
        .into(db.roomTypes)
        .insert(RoomTypesCompanion.insert(id: Value(roomTypeId), name: 'Tipo'));
    await db
        .into(db.rooms)
        .insert(
          RoomsCompanion.insert(
            id: Value(roomId),
            propertyId: propertyId,
            roomTypeId: roomTypeId,
            name: 'Habitacion 1',
            capacity: 4,
            ratePerPersonWeekdayCents: 1200,
            ratePerPersonWeekendCents: 1500,
            ratePerPersonHolidayCents: 2000,
          ),
        );
    await db
        .into(db.guests)
        .insert(
          GuestsCompanion.insert(
            id: Value(activeGuestId),
            fullName: 'Maria Torres',
            phone: const Value('0999999999'),
          ),
        );
    await db
        .into(db.guests)
        .insert(
          GuestsCompanion.insert(
            id: Value(otherGuestId),
            fullName: 'Huesped Pasado',
          ),
        );

    final reservationRepository = ReservationRepository(db);

    // Reserva activa el día del reporte: su vehículo sí debe aparecer.
    final activeReservationId = await reservationRepository
        .createGroupReservation(
          guestId: activeGuestId,
          checkInDate: DateTime(2026, 6, 10),
          checkOutDate: DateTime(2026, 6, 12),
          roomAssignments: [
            RoomAssignmentInput(roomId: roomId, guestsCount: 2),
          ],
        );
    await db
        .into(db.vehicles)
        .insert(
          VehiclesCompanion.insert(
            id: const Value('vehicle-active'),
            reservationId: activeReservationId,
            plate: 'ABC123',
          ),
        );

    // Reserva ya terminada antes del día del reporte: su vehículo no
    // debe aparecer.
    final pastReservationId = await reservationRepository
        .createGroupReservation(
          guestId: otherGuestId,
          checkInDate: DateTime(2026, 6, 1),
          checkOutDate: DateTime(2026, 6, 3),
          roomAssignments: [
            RoomAssignmentInput(roomId: roomId, guestsCount: 1),
          ],
        );
    await db
        .into(db.vehicles)
        .insert(
          VehiclesCompanion.insert(
            id: const Value('vehicle-past'),
            reservationId: pastReservationId,
            plate: 'xyz789',
          ),
        );

    final day = DateTime(2026, 6, 11);
    container.listen(garageReportProvider(day), (_, _) {});
    await _pump();

    final entries = container.read(garageReportProvider(day)).value!;

    expect(entries.length, 1);
    expect(entries.single.guestName, 'Maria Torres');
    expect(entries.single.guestPhone, '0999999999');
    expect(entries.single.propertyName, 'Hospedaje Shejina');
    expect(entries.single.roomNames, 'Habitacion 1');
    expect(entries.single.plate, 'ABC123');
  });

  test('commissionReportProvider calcula la comisión noche por noche, resta '
      'el garaje cuando hay auto, ignora reservas canceladas y filtra por '
      'propiedad', () async {
    const propertyId = 'casa-norma';
    const otherPropertyId = 'casa-simon';
    const roomTypeId = 'room-type';
    const guestId = 'guest-1';

    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(id: Value(propertyId), name: 'Norma'),
        );
    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(id: Value(otherPropertyId), name: 'Simón'),
        );
    await db
        .into(db.roomTypes)
        .insert(RoomTypesCompanion.insert(id: Value(roomTypeId), name: 'Tipo'));
    await db
        .into(db.guests)
        .insert(GuestsCompanion.insert(id: Value(guestId), fullName: 'Carlos'));

    Future<String> addRoom(String id, String name, String forProperty) async {
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: Value(id),
              propertyId: forProperty,
              roomTypeId: roomTypeId,
              name: name,
              capacity: 4,
              ratePerPersonWeekdayCents: 1200,
              ratePerPersonWeekendCents: 1200,
              ratePerPersonHolidayCents: 1200,
            ),
          );
      return id;
    }

    await addRoom('room-1', 'Habitacion 1', propertyId);
    await addRoom('room-2', 'Habitacion 2', propertyId);
    await addRoom('room-3', 'Habitacion 3', propertyId);
    await addRoom('room-other', 'Habitacion otra casa', otherPropertyId);

    final reservationRepository = ReservationRepository(db);
    final vehicleRepository = VehicleRepository(db);

    // room-1: 3 huéspedes a $12, sin auto -> tramo $12 (>1) -> $9.
    await reservationRepository.createGroupReservation(
      guestId: guestId,
      checkInDate: DateTime(2026, 6, 1), // lunes
      checkOutDate: DateTime(2026, 6, 2),
      roomAssignments: [RoomAssignmentInput(roomId: 'room-1', guestsCount: 3)],
    );

    // room-2: 2 huéspedes a $12, con un auto de $3.50 de garaje ->
    // ingreso neto $20.50 -> tramo "$10" -> $5.
    final room2ReservationId = await reservationRepository
        .createGroupReservation(
          guestId: guestId,
          checkInDate: DateTime(2026, 6, 1),
          checkOutDate: DateTime(2026, 6, 2),
          roomAssignments: [
            RoomAssignmentInput(roomId: 'room-2', guestsCount: 2),
          ],
        );
    await vehicleRepository.create(
      reservationId: room2ReservationId,
      plate: 'ABC123',
      garageFeeCents: 350,
    );

    // room-3: cancelada -> no debe contarse.
    final room3ReservationId = await reservationRepository
        .createGroupReservation(
          guestId: guestId,
          checkInDate: DateTime(2026, 6, 1),
          checkOutDate: DateTime(2026, 6, 2),
          roomAssignments: [
            RoomAssignmentInput(roomId: 'room-3', guestsCount: 1),
          ],
        );
    await reservationRepository.updateStatus(
      room3ReservationId,
      ReservationStatus.cancelled,
    );

    // Otra propiedad -> no debe contarse en el reporte de "casa-norma".
    await reservationRepository.createGroupReservation(
      guestId: guestId,
      checkInDate: DateTime(2026, 6, 1),
      checkOutDate: DateTime(2026, 6, 2),
      roomAssignments: [
        RoomAssignmentInput(roomId: 'room-other', guestsCount: 5),
      ],
    );

    final params = (
      propertyId: propertyId,
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 1),
    );
    container.listen(commissionReportProvider(params), (_, _) {});
    await _pump();

    final entries = container.read(commissionReportProvider(params)).value!;

    expect(entries.length, 2);
    final byRoom = {for (final e in entries) e.roomName: e};
    expect(byRoom['Habitacion 1']!.commissionCents, 900);
    expect(byRoom['Habitacion 2']!.commissionCents, 500);
    expect(byRoom['Habitacion 2']!.garageFeeCents, 350);
    expect(byRoom.containsKey('Habitacion 3'), false);
  });
}
