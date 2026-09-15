import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';

import 'data/guest_repository.dart';

final guestRepositoryProvider = Provider<GuestRepository>(
  (ref) => GuestRepository(ref.watch(appDatabaseProvider)),
);

/// Estado reactivo, mismo patrón que `activePropertiesProvider`.
final guestsProvider = StreamProvider<List<Guest>>(
  (ref) => ref.watch(guestRepositoryProvider).watchAll(),
);
