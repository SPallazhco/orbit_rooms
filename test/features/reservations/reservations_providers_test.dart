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
  test(
    'el grafo de providers resuelve de punta a punta sobre una BD en memoria',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final guestId = const Uuid().v4();
      final roomId = const Uuid().v4();
      await db
          .into(db.properties)
          .insert(PropertiesCompanion.insert(name: 'Hostal'));
      final propertyId = (await db.select(db.properties).getSingle()).id;
      await db
          .into(db.roomTypes)
          .insert(RoomTypesCompanion.insert(name: 'Tipo'));
      final roomTypeId = (await db.select(db.roomTypes).getSingle()).id;
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

      // Resuelve el caso de uso a través de toda la cadena de providers
      // (appDatabaseProvider -> reservationRepositoryProvider ->
      // createReservationUseCaseProvider), no se construye a mano.
      final createReservation = container.read(
        createReservationUseCaseProvider,
      );
      final reservationId = await createReservation(
        guestId: guestId,
        checkInDate: DateTime(2026, 6, 1),
        checkOutDate: DateTime(2026, 6, 2),
        roomAssignments: [RoomAssignmentInput(roomId: roomId, guestsCount: 2)],
      );

      final registerPayment = container.read(registerPaymentUseCaseProvider);
      await registerPayment(
        reservationId: reservationId,
        amountCents: 2400,
        method: PaymentMethod.cash,
      );

      final payments = await container
          .read(paymentRepositoryProvider)
          .getForReservation(reservationId);

      expect(payments, hasLength(1));
      expect(payments.single.amountCents, 2400);
    },
  );
}
