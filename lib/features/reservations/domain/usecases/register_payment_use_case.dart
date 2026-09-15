import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/data/payment_repository.dart';

/// Acción real "registrar un pago" (PRD 5.5). Un reembolso es un
/// [amountCents] negativo — no hay una entidad de reembolso separada (ver
/// docs/DECISIONS.md).
class RegisterPaymentUseCase {
  RegisterPaymentUseCase(this._paymentRepository);

  final PaymentRepository _paymentRepository;

  Future<String> call({
    required String reservationId,
    required int amountCents,
    required PaymentMethod method,
  }) {
    if (amountCents == 0) {
      throw ArgumentError('El monto del pago no puede ser 0');
    }

    return _paymentRepository.addPayment(
      reservationId: reservationId,
      amountCents: amountCents,
      method: method,
    );
  }
}
