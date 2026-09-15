import 'package:orbit_rooms/core/database/app_database.dart';

String reservationStatusLabel(ReservationStatus status) => switch (status) {
  ReservationStatus.pending => 'Pendiente',
  ReservationStatus.confirmed => 'Confirmada',
  ReservationStatus.checkedIn => 'Check-in hecho',
  ReservationStatus.checkedOut => 'Check-out hecho',
  ReservationStatus.cancelled => 'Cancelada',
};
