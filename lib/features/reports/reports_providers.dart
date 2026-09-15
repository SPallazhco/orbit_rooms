import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';

typedef DateRange = ({DateTime start, DateTime end});

typedef ReportData = ({
  int occupiedRoomNights,
  int totalRoomNights,
  int incomeCents,
});

bool _isWithin(DateTime day, DateTime start, DateTime end) =>
    !day.isBefore(start) && !day.isAfter(end);

/// No es un `StreamProvider` propio: se arma combinando providers reactivos
/// que ya existen (`activeRoomsProvider`, `reservationRoomAssignmentsProvider`,
/// `paymentsProvider`) para un rango de fechas puntual — mismo patrón que
/// `dashboardDataProvider` y `roomOccupancyProvider` (PRD 5.8 es, otra vez,
/// un resumen de datos que ya existen). Es global (todas las propiedades),
/// no por propiedad — a diferencia del Calendar, el PRD no pide filtrar
/// Reports por propiedad.
final reportDataProvider = Provider.family<AsyncValue<ReportData>, DateRange>((
  ref,
  range,
) {
  final roomsAsync = ref.watch(activeRoomsProvider);
  final assignmentsAsync = ref.watch(reservationRoomAssignmentsProvider);
  final paymentsAsync = ref.watch(paymentsProvider);

  if (roomsAsync.isLoading ||
      assignmentsAsync.isLoading ||
      paymentsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final error =
      roomsAsync.error ?? assignmentsAsync.error ?? paymentsAsync.error;
  if (error != null) {
    return AsyncValue.error(error, StackTrace.current);
  }

  final rooms = roomsAsync.value!;
  final assignments = assignmentsAsync.value!;
  final payments = paymentsAsync.value!;

  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(range.end.year, range.end.month, range.end.day);
  final daysCount = end.difference(start).inDays + 1;

  var occupiedRoomNights = 0;
  for (var i = 0; i < daysCount; i++) {
    final day = start.add(Duration(days: i));
    final occupiedRoomIds = assignments
        .where(
          (a) =>
              a.reservation.status != ReservationStatus.cancelled &&
              !day.isBefore(a.reservation.checkInDate) &&
              day.isBefore(a.reservation.checkOutDate),
        )
        .map((a) => a.line.roomId)
        .toSet();
    occupiedRoomNights += occupiedRoomIds.length;
  }

  final incomeCents = payments
      .where(
        (p) => _isWithin(
          DateTime(p.paidAt.year, p.paidAt.month, p.paidAt.day),
          start,
          end,
        ),
      )
      .fold<int>(0, (sum, p) => sum + p.amountCents);

  return AsyncValue.data((
    occupiedRoomNights: occupiedRoomNights,
    totalRoomNights: rooms.length * daysCount,
    incomeCents: incomeCents,
  ));
});
