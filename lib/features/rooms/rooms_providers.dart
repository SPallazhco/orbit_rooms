import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';

import 'data/room_repository.dart';
import 'data/room_type_repository.dart';

final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => RoomRepository(ref.watch(appDatabaseProvider)),
);

final roomTypeRepositoryProvider = Provider<RoomTypeRepository>(
  (ref) => RoomTypeRepository(ref.watch(appDatabaseProvider)),
);

/// Estado reactivo, mismo patrón que `activePropertiesProvider`: se
/// actualiza solo después de crear/desactivar una habitación.
final activeRoomsProvider =
    StreamProvider<List<({Room room, String propertyName})>>(
      (ref) => ref.watch(roomRepositoryProvider).watchAllActive(),
    );
