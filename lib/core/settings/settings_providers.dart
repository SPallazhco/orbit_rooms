import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';

import 'app_settings_repository.dart';
import 'holiday_repository.dart';

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>(
  (ref) => AppSettingsRepository(ref.watch(appDatabaseProvider)),
);

final holidayRepositoryProvider = Provider<HolidayRepository>(
  (ref) => HolidayRepository(ref.watch(appDatabaseProvider)),
);
