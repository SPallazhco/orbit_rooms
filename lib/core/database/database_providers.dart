import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';

/// Única instancia real de [AppDatabase] para toda la app. Todo lo demás
/// (repositories, casos de uso) depende de este provider en vez de crear su
/// propia conexión.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.connect();
  ref.onDispose(db.close);
  return db;
});
