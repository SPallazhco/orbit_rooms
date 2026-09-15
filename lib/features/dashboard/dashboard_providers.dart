import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';

typedef DashboardData = ({
  int occupiedRoomsCount,
  int totalActiveRoomsCount,
  List<({Reservation reservation, String guestName})> todayCheckIns,
  List<({Reservation reservation, String guestName})> todayCheckOuts,
  int incomeTodayCents,
  int incomeMonthCents,
});

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// No es un `StreamProvider` propio: se arma combinando providers
/// reactivos que ya existen (`reservationsProvider`, `activeRoomsProvider`,
/// `reservationRoomAssignmentsProvider`, `paymentsProvider`) en vez de
/// escribir una consulta nueva — el Dashboard es, literalmente, un resumen
/// de datos que otras pantallas ya cargan de forma reactiva.
final dashboardDataProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final reservationsAsync = ref.watch(reservationsProvider);
  final roomsAsync = ref.watch(activeRoomsProvider);
  final assignmentsAsync = ref.watch(reservationRoomAssignmentsProvider);
  final paymentsAsync = ref.watch(paymentsProvider);

  if (reservationsAsync.isLoading ||
      roomsAsync.isLoading ||
      assignmentsAsync.isLoading ||
      paymentsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final error =
      reservationsAsync.error ??
      roomsAsync.error ??
      assignmentsAsync.error ??
      paymentsAsync.error;
  if (error != null) {
    return AsyncValue.error(error, StackTrace.current);
  }

  final reservations = reservationsAsync.value!;
  final rooms = roomsAsync.value!;
  final assignments = assignmentsAsync.value!;
  final payments = paymentsAsync.value!;
  final now = DateTime.now();

  final occupiedRoomIds = assignments
      .where(
        (a) =>
            a.reservation.status != ReservationStatus.cancelled &&
            !now.isBefore(a.reservation.checkInDate) &&
            now.isBefore(a.reservation.checkOutDate),
      )
      .map((a) => a.line.roomId)
      .toSet();

  final activeReservations = reservations.where(
    (r) => r.reservation.status != ReservationStatus.cancelled,
  );

  final todayCheckIns = activeReservations
      .where((r) => _isSameDay(r.reservation.checkInDate, now))
      .toList();
  final todayCheckOuts = activeReservations
      .where((r) => _isSameDay(r.reservation.checkOutDate, now))
      .toList();

  final incomeTodayCents = payments
      .where((p) => _isSameDay(p.paidAt, now))
      .fold<int>(0, (sum, p) => sum + p.amountCents);
  final incomeMonthCents = payments
      .where((p) => p.paidAt.year == now.year && p.paidAt.month == now.month)
      .fold<int>(0, (sum, p) => sum + p.amountCents);

  return AsyncValue.data((
    occupiedRoomsCount: occupiedRoomIds.length,
    totalActiveRoomsCount: rooms.length,
    todayCheckIns: todayCheckIns,
    todayCheckOuts: todayCheckOuts,
    incomeTodayCents: incomeTodayCents,
    incomeMonthCents: incomeMonthCents,
  ));
});
