import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';
import 'package:orbit_rooms/features/reservations/domain/usecases/create_reservation_use_case.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late CreateReservationUseCase useCase;
  late String guestId;
  late String roomId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    useCase = CreateReservationUseCase(ReservationRepository(db));

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
        .insert(GuestsCompanion.insert(id: Value(guestId), fullName: 'Ana'));
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
    'rechaza una asignación con 0 personas antes de tocar la base de datos',
    () {
      expect(
        () => useCase.call(
          guestId: guestId,
          checkInDate: DateTime(2026, 6, 1),
          checkOutDate: DateTime(2026, 6, 3),
          roomAssignments: [
            RoomAssignmentInput(roomId: roomId, guestsCount: 0),
          ],
        ),
        throwsArgumentError,
      );
    },
  );

  test('crea la reserva cuando la entrada es válida', () async {
    final reservationId = await useCase.call(
      guestId: guestId,
      checkInDate: DateTime(2026, 6, 1),
      checkOutDate: DateTime(2026, 6, 3),
      roomAssignments: [RoomAssignmentInput(roomId: roomId, guestsCount: 2)],
    );

    final reservations = await db.select(db.reservations).get();
    expect(reservations, hasLength(1));
    expect(reservations.single.id, reservationId);
  });
}
