import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/domain/reservation_timeline.dart';

void main() {
  final now = DateTime(2026, 10, 10, 15);

  Reservation reservation(
    DateTime checkIn,
    DateTime checkOut, [
    ReservationStatus status = ReservationStatus.confirmed,
  ]) => Reservation(
    id: 'r',
    guestId: 'g',
    checkInDate: checkIn,
    checkOutDate: checkOut,
    status: status,
    totalPriceCents: 10000,
    createdAt: now,
  );

  test('fases según estado y fechas', () {
    ReservationPhase phase(Reservation r) => reservationPhase(r, now);

    expect(
      phase(reservation(DateTime(2026, 10, 12), DateTime(2026, 10, 14))),
      ReservationPhase.upcoming,
    );
    expect(
      phase(reservation(DateTime(2026, 10, 10), DateTime(2026, 10, 12))),
      ReservationPhase.inHouse,
    );
    expect(
      phase(reservation(DateTime(2026, 10, 8), DateTime(2026, 10, 10))),
      ReservationPhase.inHouse,
      reason: 'sale hoy: sigue en casa hasta marcar el check-out',
    );
    expect(
      phase(reservation(DateTime(2026, 10, 8), DateTime(2026, 10, 9))),
      ReservationPhase.past,
    );
    expect(
      phase(
        reservation(
          DateTime(2026, 10, 8),
          DateTime(2026, 10, 10),
          ReservationStatus.checkedOut,
        ),
      ),
      ReservationPhase.past,
    );
    expect(
      phase(
        reservation(
          DateTime(2026, 10, 12),
          DateTime(2026, 10, 14),
          ReservationStatus.cancelled,
        ),
      ),
      ReservationPhase.cancelled,
    );
  });

  test('frase de cuándo pasa lo siguiente', () {
    String? label(Reservation r) => reservationTimingLabel(r, now);

    expect(
      label(reservation(DateTime(2026, 10, 11), DateTime(2026, 10, 12))),
      'Llega mañana',
    );
    expect(
      label(reservation(DateTime(2026, 10, 15), DateTime(2026, 10, 16))),
      'Llega en 5 días',
    );
    expect(
      label(reservation(DateTime(2026, 10, 10), DateTime(2026, 10, 12))),
      'Llega hoy',
    );
    expect(
      label(
        reservation(
          DateTime(2026, 10, 10),
          DateTime(2026, 10, 12),
          ReservationStatus.checkedIn,
        ),
      ),
      'Sale en 2 días',
    );
    expect(
      label(reservation(DateTime(2026, 10, 8), DateTime(2026, 10, 10))),
      'Sale hoy',
    );
    expect(
      label(reservation(DateTime(2026, 10, 9), DateTime(2026, 10, 11))),
      'Sale mañana',
    );
    expect(
      label(reservation(DateTime(2026, 10, 1), DateTime(2026, 10, 2))),
      isNull,
    );
  });
}
