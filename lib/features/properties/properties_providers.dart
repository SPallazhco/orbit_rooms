import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';

import 'data/property_repository.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>(
  (ref) => PropertyRepository(ref.watch(appDatabaseProvider)),
);

/// Estado reactivo: la UI que use esto (paso 10) recibe loading/error/data
/// automáticamente vía `AsyncValue`, y se actualiza sola después de crear,
/// editar o desactivar una propiedad — no hace falta invalidar nada a mano.
final activePropertiesProvider = StreamProvider<List<Property>>(
  (ref) => ref.watch(propertyRepositoryProvider).watchActive(),
);
