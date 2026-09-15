import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

class GuestRepository {
  GuestRepository(this._db);

  final AppDatabase _db;

  Future<List<Guest>> getAll() => _db.select(_db.guests).get();

  Future<Guest> getById(String id) =>
      (_db.select(_db.guests)..where((g) => g.id.equals(id))).getSingle();

  /// Igual que [getAll], pero reactivo (mismo patrón que
  /// `PropertyRepository.watchActive()`): se actualiza solo al
  /// crear/editar/borrar un huésped.
  Stream<List<Guest>> watchAll() => (_db.select(
    _db.guests,
  )..orderBy([(g) => OrderingTerm(expression: g.fullName)])).watch();

  /// Búsqueda por nombre o documento (PRD 5.3).
  Future<List<Guest>> search(String query) {
    final pattern = '%$query%';
    return (_db.select(_db.guests)
          ..where((g) => g.fullName.like(pattern) | g.documentId.like(pattern)))
        .get();
  }

  Future<String> create({
    required String fullName,
    String? documentId,
    String? phone,
    String? email,
    String? notes,
  }) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.guests)
        .insert(
          GuestsCompanion.insert(
            id: Value(id),
            fullName: fullName,
            documentId: Value(documentId),
            phone: Value(phone),
            email: Value(email),
            notes: Value(notes),
          ),
        );
    return id;
  }

  Future<void> update(Guest guest) => _db.update(_db.guests).replace(guest);

  Future<void> delete(String id) =>
      (_db.delete(_db.guests)..where((g) => g.id.equals(id))).go();
}
