import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/data/vehicle_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late VehicleRepository repository;
  late String reservationId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = VehicleRepository(db);

    final guestId = const Uuid().v4();
    reservationId = const Uuid().v4();

    await db
        .into(db.guests)
        .insert(GuestsCompanion.insert(id: Value(guestId), fullName: 'Ana'));
    await db
        .into(db.reservations)
        .insert(
          ReservationsCompanion.insert(
            id: Value(reservationId),
            guestId: guestId,
            checkInDate: DateTime(2026, 6, 1),
            checkOutDate: DateTime(2026, 6, 3),
            totalPriceCents: 2400,
          ),
        );
  });

  tearDown(() => db.close());

  test(
    'un huésped puede declarar más de un vehículo, y la placa se normaliza',
    () async {
      await repository.create(reservationId: reservationId, plate: 'abc123');
      await repository.create(reservationId: reservationId, plate: 'XYZ-999');

      final vehicles = await repository.getForReservation(reservationId);

      expect(vehicles, hasLength(2));
      expect(vehicles.map((v) => v.plate), containsAll(['ABC123', 'XYZ-999']));
    },
  );

  test('borrar un vehículo lo saca de la lista', () async {
    final id = await repository.create(
      reservationId: reservationId,
      plate: 'ABC123',
    );

    await repository.delete(id);

    expect(await repository.getForReservation(reservationId), isEmpty);
  });
}
