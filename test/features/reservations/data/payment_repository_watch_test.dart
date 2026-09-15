import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/data/payment_repository.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late PaymentRepository paymentRepository;
  late String reservationId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    paymentRepository = PaymentRepository(db);
    final reservationRepository = ReservationRepository(db);

    final propertyId = const Uuid().v4();
    final roomTypeId = const Uuid().v4();
    final guestId = const Uuid().v4();
    final roomId = const Uuid().v4();

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

    reservationId = await reservationRepository.createGroupReservation(
      guestId: guestId,
      checkInDate: DateTime(2026, 6, 1),
      checkOutDate: DateTime(2026, 6, 3),
      roomAssignments: [RoomAssignmentInput(roomId: roomId, guestsCount: 2)],
    );
  });

  tearDown(() => db.close());

  test('watchAll emite todos los pagos de todas las reservas y se actualiza al '
      'registrar uno nuevo', () async {
    final emissions = <int>[];
    final subscription = paymentRepository.watchAll().listen(
      (payments) => emissions.add(payments.length),
    );
    addTearDown(subscription.cancel);

    await Future<void>.delayed(Duration.zero);

    await paymentRepository.addPayment(
      reservationId: reservationId,
      amountCents: 5000,
      method: PaymentMethod.cash,
    );
    await Future<void>.delayed(Duration.zero);

    final withPayment = await paymentRepository.watchAll().first;
    expect(withPayment, hasLength(1));
    expect(withPayment.single.amountCents, 5000);

    expect(emissions, [0, 1]);
  });
}
