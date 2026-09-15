import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/features/dashboard/dashboard_providers.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:uuid/uuid.dart';

/// `dashboardDataProvider` combina 4 `StreamProvider`s: cada uno necesita su
/// propia vuelta del event loop para emitir su primer valor tras un cambio.
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

  test('dashboardDataProvider combina ocupación, check-ins/outs de hoy e '
      'ingresos a partir de los providers reactivos existentes', () async {
    final propertyId = const Uuid().v4();
    final roomTypeId = const Uuid().v4();
    final guestId = const Uuid().v4();
    final roomAId = const Uuid().v4();
    final roomBId = const Uuid().v4();

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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final reservationRepository = ReservationRepository(db);

    // Ocupa roomA desde hoy hasta dentro de 2 días: cuenta como ocupada y
    // como check-in de hoy.
    final checkInTodayReservationId = await reservationRepository
        .createGroupReservation(
          guestId: guestId,
          checkInDate: today,
          checkOutDate: today.add(const Duration(days: 2)),
          roomAssignments: [
            RoomAssignmentInput(roomId: roomAId, guestsCount: 2),
          ],
        );

    // roomB estuvo ocupada los últimos 2 días y hace check-out hoy: no
    // cuenta como ocupada actualmente, pero sí como check-out de hoy.
    await reservationRepository.createGroupReservation(
      guestId: guestId,
      checkInDate: today.subtract(const Duration(days: 2)),
      checkOutDate: today,
      roomAssignments: [RoomAssignmentInput(roomId: roomBId, guestsCount: 2)],
    );

    // Se registra este listen para simular lo que hace la UI real
    // (`ref.watch`) y mantener vivos los `StreamProvider`s subyacentes.
    container.listen(dashboardDataProvider, (_, _) {});
    await _pump();

    await container
        .read(registerPaymentUseCaseProvider)
        .call(
          reservationId: checkInTodayReservationId,
          amountCents: 3000,
          method: PaymentMethod.cash,
        );
    await _pump();

    final data = container.read(dashboardDataProvider).value!;
    expect(data.occupiedRoomsCount, 1);
    expect(data.totalActiveRoomsCount, 2);
    expect(data.todayCheckIns, hasLength(1));
    expect(data.todayCheckIns.single.reservation.id, checkInTodayReservationId);
    expect(data.todayCheckOuts, hasLength(1));
    expect(data.incomeTodayCents, 3000);
    expect(data.incomeMonthCents, 3000);
  });
}
