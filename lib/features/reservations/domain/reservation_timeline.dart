import 'package:orbit_rooms/core/database/app_database.dart';

/// En qué momento de su vida está una reserva, para ordenarla y filtrarla en
/// la lista. Mezcla estado y fechas: una reserva "confirmada" cuyo check-out
/// ya pasó es una reserva pasada, y una que sale hoy sigue "en casa" hasta
/// que se marque el check-out.
enum ReservationPhase { inHouse, upcoming, past, cancelled }

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

ReservationPhase reservationPhase(Reservation reservation, DateTime now) {
  if (reservation.status == ReservationStatus.cancelled) {
    return ReservationPhase.cancelled;
  }
  if (reservation.status == ReservationStatus.checkedOut) {
    return ReservationPhase.past;
  }

  final today = _day(now);
  final checkIn = _day(reservation.checkInDate);
  final checkOut = _day(reservation.checkOutDate);

  if (checkOut.isBefore(today)) return ReservationPhase.past;
  if (reservation.status == ReservationStatus.checkedIn ||
      !checkIn.isAfter(today)) {
    return ReservationPhase.inHouse;
  }
  return ReservationPhase.upcoming;
}

/// Frase corta de cuándo pasa lo siguiente ("Llega mañana", "Sale hoy").
/// `null` si no aporta nada (pasadas y canceladas).
String? reservationTimingLabel(Reservation reservation, DateTime now) {
  final today = _day(now);
  final toCheckIn = _day(reservation.checkInDate).difference(today).inDays;
  final toCheckOut = _day(reservation.checkOutDate).difference(today).inDays;

  final arrivesToday =
      toCheckIn == 0 && reservation.status != ReservationStatus.checkedIn;

  return switch (reservationPhase(reservation, now)) {
    ReservationPhase.upcoming =>
      toCheckIn == 1 ? 'Llega mañana' : 'Llega en $toCheckIn días',
    ReservationPhase.inHouse =>
      arrivesToday
          ? 'Llega hoy'
          : switch (toCheckOut) {
              <= 0 => 'Sale hoy',
              1 => 'Sale mañana',
              _ => 'Sale en $toCheckOut días',
            },
    _ => null,
  };
}

/// Cuánto falta por cobrar. Negativo si se cobró de más (ej. un descuento
/// aplicado después de un pago).
int balanceCents(Reservation reservation, int paidCents) =>
    reservation.totalPriceCents - paidCents;
