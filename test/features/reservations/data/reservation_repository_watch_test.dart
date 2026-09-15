import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late ReservationRepository repository;
  late String guestId;
  late String roomId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = ReservationRepository(db);

    final propertyId = const Uuid().v4();
    final roomTypeId = const Uuid().v4();
    guestId = const Uuid().v4();
    roomId = const Uuid().v4();

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
  });

  tearDown(() => db.close());

  test(
    'watchAll emite el nombre del huésped y se actualiza solo al crear una reserva',
    () async {
      final emissions = <int>[];
      final subscription = repository.watchAll().listen(
        (reservations) => emissions.add(reservations.length),
      );
      addTearDown(subscription.cancel);

      await Future<void>.delayed(Duration.zero);

      await repository.createGroupReservation(
        guestId: guestId,
        checkInDate: DateTime(2026, 6, 1),
        checkOutDate: DateTime(2026, 6, 3),
        roomAssignments: [RoomAssignmentInput(roomId: roomId, guestsCount: 2)],
      );
      await Future<void>.delayed(Duration.zero);

      final withReservation = await repository.watchAll().first;
      expect(withReservation, hasLength(1));
      expect(withReservation.single.guestName, 'Ana Pérez');

      expect(emissions, [0, 1]);
    },
  );

  test('watchAllRoomAssignments emite las líneas de habitación junto con su '
      'reserva y se actualiza al crear una reserva', () async {
    final emissions = <int>[];
    final subscription = repository.watchAllRoomAssignments().listen(
      (assignments) => emissions.add(assignments.length),
    );
    addTearDown(subscription.cancel);

    await Future<void>.delayed(Duration.zero);

    await repository.createGroupReservation(
      guestId: guestId,
      checkInDate: DateTime(2026, 6, 1),
      checkOutDate: DateTime(2026, 6, 3),
      roomAssignments: [RoomAssignmentInput(roomId: roomId, guestsCount: 2)],
    );
    await Future<void>.delayed(Duration.zero);

    final withAssignment = await repository.watchAllRoomAssignments().first;
    expect(withAssignment, hasLength(1));
    expect(withAssignment.single.line.roomId, roomId);
    expect(withAssignment.single.reservation.guestId, guestId);

    expect(emissions, [0, 1]);
  });
}
