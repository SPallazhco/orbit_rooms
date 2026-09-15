import 'package:drift/drift.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

class PaymentRepository {
  PaymentRepository(this._db);

  final AppDatabase _db;

  Future<List<Payment>> getForReservation(String reservationId) => (_db.select(
    _db.payments,
  )..where((p) => p.reservationId.equals(reservationId))).get();

  /// Todos los pagos de todas las reservas — para sumar ingresos en el
  /// Dashboard (PRD 5.7). Reactivo, mismo patrón que
  /// `PropertyRepository.watchActive()`.
  Stream<List<Payment>> watchAll() => _db.select(_db.payments).watch();

  /// Un reembolso se registra con [amountCents] negativo — no existe una
  /// entidad de reembolso separada (ver docs/DECISIONS.md).
  Future<String> addPayment({
    required String reservationId,
    required int amountCents,
    required PaymentMethod method,
  }) async {
    final id = const Uuid().v4();
    await _db
        .into(_db.payments)
        .insert(
          PaymentsCompanion.insert(
            id: Value(id),
            reservationId: reservationId,
            amountCents: amountCents,
            method: method,
          ),
        );
    return id;
  }

  /// Saldo pendiente = precio total de la reserva − suma de pagos (PRD 5.5).
  Future<int> getBalanceCents(String reservationId) async {
    final reservation = await (_db.select(
      _db.reservations,
    )..where((r) => r.id.equals(reservationId))).getSingle();
    final payments = await getForReservation(reservationId);
    final paidCents = payments.fold<int>(0, (sum, p) => sum + p.amountCents);
    return reservation.totalPriceCents - paidCents;
  }
}
