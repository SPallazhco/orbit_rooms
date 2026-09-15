import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';

/// Moneda global de la instalación (PRD 5.9): un único valor para toda la
/// app, sin conversión ni moneda por propiedad.
class AppSettingsRepository {
  AppSettingsRepository(this._db);

  final AppDatabase _db;

  static const _settingsId = 'app_settings';

  Future<String> getCurrency() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.id.equals(_settingsId))).getSingleOrNull();
    return row?.currency ?? 'USD';
  }

  /// Reactivo, mismo patrón que `HolidayRepository.watchAll()`: la
  /// pantalla de Configuración refleja sola un cambio de moneda.
  Stream<String> watchCurrency() =>
      (_db.select(_db.appSettings)..where((s) => s.id.equals(_settingsId)))
          .watchSingleOrNull()
          .map((row) => row?.currency ?? 'USD');

  Future<void> setCurrency(String currencyCode) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          id: const Value(_settingsId),
          currency: Value(currencyCode),
        ),
      );
}
