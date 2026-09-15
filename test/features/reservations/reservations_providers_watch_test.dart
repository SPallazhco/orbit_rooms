import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late String guestId;
  late String roomId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );

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

  tearDown(() {
    container.dispose();
    return db.close();
  });

  test('reservationsProvider y reservationDetailProvider reflejan una reserva '
      'creada, y el detalle se refresca tras registrar un pago', () async {
    // No se usa `.future` (ver docs/DECISIONS.md).
    container.listen(reservationsProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    final reservationId = await container
        .read(createReservationUseCaseProvider)
        .call(
          guestId: guestId,
          checkInDate: DateTime(2026, 6, 1),
          checkOutDate: DateTime(2026, 6, 3),
          roomAssignments: [
            RoomAssignmentInput(roomId: roomId, guestsCount: 2),
          ],
        );

    await Future<void>.delayed(Duration.zero);
    final list = container.read(reservationsProvider).value;
    expect(list, hasLength(1));
    expect(list!.single.guestName, 'Ana Pérez');

    final detail = await container.read(
      reservationDetailProvider(reservationId).future,
    );
    expect(detail.guestName, 'Ana Pérez');
    expect(detail.roomAssignments, hasLength(1));
    expect(detail.roomAssignments.single.room.name, 'Cuarto 1');
    expect(detail.balanceCents, detail.reservation.totalPriceCents);

    await container
        .read(registerPaymentUseCaseProvider)
        .call(
          reservationId: reservationId,
          amountCents: detail.reservation.totalPriceCents,
          method: PaymentMethod.cash,
        );
    container.invalidate(reservationDetailProvider(reservationId));

    final updatedDetail = await container.read(
      reservationDetailProvider(reservationId).future,
    );
    expect(updatedDetail.balanceCents, 0);
    expect(updatedDetail.vehicles, isEmpty);
    expect(updatedDetail.reservation.notes, null);

    // El garaje es una fortaleza real del hospedaje (PRD 5.4): un vehículo
    // se declara desde el detalle, no al crear la reserva.
    await container
        .read(vehicleRepositoryProvider)
        .create(reservationId: reservationId, plate: 'abc123');
    await container
        .read(reservationRepositoryProvider)
        .updateNotes(reservationId, 'Desayuno a las 7');
    container.invalidate(reservationDetailProvider(reservationId));

    final finalDetail = await container.read(
      reservationDetailProvider(reservationId).future,
    );
    expect(finalDetail.vehicles, hasLength(1));
    expect(finalDetail.vehicles.single.plate, 'ABC123');
    expect(finalDetail.reservation.notes, 'Desayuno a las 7');
  });
}
