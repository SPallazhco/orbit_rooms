import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/data/payment_repository.dart';
import 'package:orbit_rooms/features/reservations/domain/usecases/register_payment_use_case.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late RegisterPaymentUseCase useCase;
  late String reservationId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    useCase = RegisterPaymentUseCase(PaymentRepository(db));

    final guestId = const Uuid().v4();
    reservationId = const Uuid().v4();

    await db
        .into(db.guests)
        .insert(GuestsCompanion.insert(id: Value(guestId), fullName: 'Ana'));
    await db
        .into(db.reservations)
        .insert(
          ReservationsCompanion.insert(
            id: Value(reservationId),
            guestId: guestId,
            checkInDate: DateTime(2026, 6, 1),
            checkOutDate: DateTime(2026, 6, 3),
            totalPriceCents: 2400,
          ),
        );
  });

  tearDown(() => db.close());

  test('rechaza un pago de monto 0', () {
    expect(
      () => useCase.call(
        reservationId: reservationId,
        amountCents: 0,
        method: PaymentMethod.cash,
      ),
      throwsArgumentError,
    );
  });

  test('permite un reembolso con monto negativo', () async {
    await useCase.call(
      reservationId: reservationId,
      amountCents: -500,
      method: PaymentMethod.cash,
    );

    final payments = await db.select(db.payments).get();
    expect(payments, hasLength(1));
    expect(payments.single.amountCents, -500);
  });
}
