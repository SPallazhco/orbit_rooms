import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/quotes/quotes_providers.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';

typedef DashboardMovement = ({
  Reservation reservation,
  String guestName,
  String roomNames,
  int guestsCount,
  int balanceCents,
});

typedef PropertyOccupancy = ({String propertyName, int occupied, int total});

typedef DashboardData = ({
  int occupiedRoomsCount,
  int totalActiveRoomsCount,
  int guestsInHouseCount,
  List<PropertyOccupancy> occupancyByProperty,
  List<DashboardMovement> todayCheckIns,
  List<DashboardMovement> todayCheckOuts,
  int tomorrowCheckInsCount,
  int tomorrowCheckOutsCount,
  int pendingQuotesCount,
  int incomeTodayCents,
  int incomeMonthCents,
});

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// No es un `StreamProvider` propio: se arma combinando providers
/// reactivos que ya existen (`reservationsProvider`, `activeRoomsProvider`,
/// `reservationRoomAssignmentsProvider`, `paymentsProvider`,
/// `quotesProvider`) en vez de escribir una consulta nueva — el Dashboard
/// es, literalmente, un resumen de datos que otras pantallas ya cargan de
/// forma reactiva.
final dashboardDataProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final reservationsAsync = ref.watch(reservationsProvider);
  final roomsAsync = ref.watch(activeRoomsProvider);
  final assignmentsAsync = ref.watch(reservationRoomAssignmentsProvider);
  final paymentsAsync = ref.watch(paymentsProvider);
  final quotesAsync = ref.watch(quotesProvider);

  if (reservationsAsync.isLoading ||
      roomsAsync.isLoading ||
      assignmentsAsync.isLoading ||
      paymentsAsync.isLoading ||
      quotesAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final error =
      reservationsAsync.error ??
      roomsAsync.error ??
      assignmentsAsync.error ??
      paymentsAsync.error ??
      quotesAsync.error;
  if (error != null) {
    return AsyncValue.error(error, StackTrace.current);
  }

  final reservations = reservationsAsync.value!;
  final rooms = roomsAsync.value!;
  final assignments = assignmentsAsync.value!;
  final payments = paymentsAsync.value!;
  final quotes = quotesAsync.value!;
  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));

  final occupiedAssignments = assignments.where(
    (a) =>
        a.reservation.status != ReservationStatus.cancelled &&
        !now.isBefore(a.reservation.checkInDate) &&
        now.isBefore(a.reservation.checkOutDate),
  );
  final occupiedRoomIds = occupiedAssignments.map((a) => a.line.roomId).toSet();
  final guestsInHouseCount = occupiedAssignments.fold<int>(
    0,
    (sum, a) => sum + a.line.guestsCount,
  );

  final propertyNames = <String>[];
  for (final entry in rooms) {
    if (!propertyNames.contains(entry.propertyName)) {
      propertyNames.add(entry.propertyName);
    }
  }
  final occupancyByProperty = [
    for (final name in propertyNames)
      (
        propertyName: name,
        occupied: rooms
            .where(
              (r) =>
                  r.propertyName == name && occupiedRoomIds.contains(r.room.id),
            )
            .length,
        total: rooms.where((r) => r.propertyName == name).length,
      ),
  ];

  DashboardMovement toMovement(
    ({Reservation reservation, String guestName}) r,
  ) {
    final lines = assignments
        .where((a) => a.line.reservationId == r.reservation.id)
        .toList();
    final roomNames = <String>[];
    for (final line in lines) {
      for (final entry in rooms) {
        if (entry.room.id == line.line.roomId) {
          roomNames.add(entry.room.name);
          break;
        }
      }
    }
    final paidCents = payments
        .where((p) => p.reservationId == r.reservation.id)
        .fold<int>(0, (sum, p) => sum + p.amountCents);
    return (
      reservation: r.reservation,
      guestName: r.guestName,
      roomNames: roomNames.join(', '),
      guestsCount: lines.fold<int>(0, (sum, l) => sum + l.line.guestsCount),
      balanceCents: r.reservation.totalPriceCents - paidCents,
    );
  }

  final activeReservations = reservations
      .where((r) => r.reservation.status != ReservationStatus.cancelled)
      .toList();

  final todayCheckIns = activeReservations
      .where((r) => _isSameDay(r.reservation.checkInDate, now))
      .map(toMovement)
      .toList();
  final todayCheckOuts = activeReservations
      .where((r) => _isSameDay(r.reservation.checkOutDate, now))
      .map(toMovement)
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
    guestsInHouseCount: guestsInHouseCount,
    occupancyByProperty: occupancyByProperty,
    todayCheckIns: todayCheckIns,
    todayCheckOuts: todayCheckOuts,
    tomorrowCheckInsCount: activeReservations
        .where((r) => _isSameDay(r.reservation.checkInDate, tomorrow))
        .length,
    tomorrowCheckOutsCount: activeReservations
        .where((r) => _isSameDay(r.reservation.checkOutDate, tomorrow))
        .length,
    pendingQuotesCount: quotes
        .where((q) => q.quote.status == QuoteStatus.pending)
        .length,
    incomeTodayCents: incomeTodayCents,
    incomeMonthCents: incomeMonthCents,
  ));
});
