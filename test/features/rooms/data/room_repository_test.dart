import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/rooms/data/room_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late RoomRepository repository;
  late String propertyId;
  late String roomTypeId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = RoomRepository(db);

    propertyId = const Uuid().v4();
    roomTypeId = const Uuid().v4();
    await db
        .into(db.properties)
        .insert(
          PropertiesCompanion.insert(
            id: Value(propertyId),
            name: 'Hostal Central',
          ),
        );
    await db
        .into(db.roomTypes)
        .insert(RoomTypesCompanion.insert(id: Value(roomTypeId), name: 'Tipo'));
  });

  tearDown(() => db.close());

  test(
    'watchAllActive emite el nombre de la propiedad y se actualiza solo al crear/desactivar',
    () async {
      final emissions = <int>[];
      final subscription = repository.watchAllActive().listen(
        (rooms) => emissions.add(rooms.length),
      );
      addTearDown(subscription.cancel);

      await Future<void>.delayed(Duration.zero);

      final roomId = await repository.create(
        propertyId: propertyId,
        roomTypeId: roomTypeId,
        name: 'Cuarto 1',
        capacity: 4,
        ratePerPersonWeekdayCents: 1200,
        ratePerPersonWeekendCents: 1500,
        ratePerPersonHolidayCents: 2000,
      );
      await Future<void>.delayed(Duration.zero);

      final withRoom = await repository.watchAllActive().first;
      expect(withRoom, hasLength(1));
      expect(withRoom.single.propertyName, 'Hostal Central');
      expect(withRoom.single.room.name, 'Cuarto 1');

      await repository.deactivate(roomId);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, [0, 1, 0]);
    },
  );

  test('update reemplaza los campos (ej. tarifa) y watchAllActive refleja el '
      'cambio solo', () async {
    final roomId = await repository.create(
      propertyId: propertyId,
      roomTypeId: roomTypeId,
      name: 'Cuarto 1',
      capacity: 4,
      ratePerPersonWeekdayCents: 1200,
      ratePerPersonWeekendCents: 1500,
      ratePerPersonHolidayCents: 2000,
    );

    final emissions = <int>[];
    final subscription = repository.watchAllActive().listen(
      (rooms) => emissions.add(rooms.single.room.ratePerPersonWeekdayCents),
    );
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);

    final current = await repository.getById(roomId);
    await repository.update(
      current.copyWith(
        name: 'Cuarto 1 Renovado',
        ratePerPersonWeekdayCents: 1400,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final updated = await repository.getById(roomId);
    expect(updated.name, 'Cuarto 1 Renovado');
    expect(updated.ratePerPersonWeekdayCents, 1400);
    expect(emissions.last, 1400);
  });
}
