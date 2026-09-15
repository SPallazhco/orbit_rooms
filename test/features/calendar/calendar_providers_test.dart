import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/features/calendar/calendar_providers.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';

/// `roomOccupancyProvider` combina 3 `StreamProvider`s: cada uno necesita su
/// propia vuelta del event loop para emitir su primer valor tras un cambio
/// (mismo gotcha que `dashboardDataProvider`, ver docs/DECISIONS.md).
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

  test('roomOccupancyProvider agrupa por propiedad y marca ocupada solo la '
      'habitación y el rango de fechas de una reserva activa', () async {
    final propertyAId = 'property-a';
    final propertyBId = 'property-b';
    final roomTypeId = 'room-type';
    final guestId = 'guest-1';
    final roomAId = 'room-a';
    final roomBId = 'room-b';
    final roomOtherPropertyId = 'room-c';

    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(id: Value(propertyAId), name: 'Hostal A'),
        );
    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(id: Value(propertyBId), name: 'Hostal B'),
        );
    await db
        .into(db.roomTypes)
        .insert(RoomTypesCompanion.insert(id: Value(roomTypeId), name: 'Tipo'));
    await db
        .into(db.guests)
        .insert(
          GuestsCompanion.insert(id: Value(guestId), fullName: 'Ana Pérez'),
        );
    for (final entry in [
      (roomAId, propertyAId),
      (roomBId, propertyAId),
      (roomOtherPropertyId, propertyBId),
    ]) {
      await db
          .into(db.rooms)
          .insert(
            RoomsCompanion.insert(
              id: Value(entry.$1),
              propertyId: entry.$2,
              roomTypeId: roomTypeId,
              name: 'Cuarto ${entry.$1}',
              capacity: 4,
              ratePerPersonWeekdayCents: 1200,
              ratePerPersonWeekendCents: 1500,
              ratePerPersonHolidayCents: 2000,
            ),
          );
    }

    final reservationRepository = ReservationRepository(db);
    final reservationId = await reservationRepository.createGroupReservation(
      guestId: guestId,
      checkInDate: DateTime(2026, 6, 2),
      checkOutDate: DateTime(2026, 6, 4),
      roomAssignments: [RoomAssignmentInput(roomId: roomAId, guestsCount: 2)],
    );

    container.listen(roomOccupancyProvider(propertyAId), (_, _) {});
    await _pump();

    final occupancy = container.read(roomOccupancyProvider(propertyAId)).value!;
    expect(occupancy, hasLength(2));

    final roomA = occupancy.firstWhere((o) => o.room.id == roomAId);
    expect(roomA.stays, hasLength(1));
    expect(roomA.stays.single.reservationId, reservationId);
    expect(roomA.stays.single.guestName, 'Ana Pérez');

    final roomB = occupancy.firstWhere((o) => o.room.id == roomBId);
    expect(roomB.stays, isEmpty);

    // La habitación de la otra propiedad no debe aparecer acá.
    expect(occupancy.any((o) => o.room.id == roomOtherPropertyId), false);
  });
}
