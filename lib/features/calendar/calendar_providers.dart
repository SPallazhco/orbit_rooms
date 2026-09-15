import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';

typedef RoomStay = ({
  DateTime checkInDate,
  DateTime checkOutDate,
  String guestName,
  String reservationId,
});

typedef RoomOccupancy = ({Room room, List<RoomStay> stays});

/// No es un `StreamProvider` propio: se arma combinando providers reactivos
/// que ya existen (`activeRoomsProvider`, `reservationRoomAssignmentsProvider`,
/// `reservationsProvider`) para una propiedad puntual — mismo patrón que
/// `dashboardDataProvider` (PRD 5.6 es, igual que el Dashboard, un resumen
/// de datos que otras pantallas ya cargan).
final roomOccupancyProvider =
    Provider.family<AsyncValue<List<RoomOccupancy>>, String>((ref, propertyId) {
      final roomsAsync = ref.watch(activeRoomsProvider);
      final assignmentsAsync = ref.watch(reservationRoomAssignmentsProvider);
      final reservationsAsync = ref.watch(reservationsProvider);

      if (roomsAsync.isLoading ||
          assignmentsAsync.isLoading ||
          reservationsAsync.isLoading) {
        return const AsyncValue.loading();
      }

      final error =
          roomsAsync.error ?? assignmentsAsync.error ?? reservationsAsync.error;
      if (error != null) {
        return AsyncValue.error(error, StackTrace.current);
      }

      final rooms = roomsAsync.value!
          .where((entry) => entry.room.propertyId == propertyId)
          .map((entry) => entry.room)
          .toList();
      final assignments = assignmentsAsync.value!;
      final guestNameByReservationId = {
        for (final entry in reservationsAsync.value!)
          entry.reservation.id: entry.guestName,
      };

      final occupancy = rooms.map((room) {
        final stays = assignments
            .where(
              (a) =>
                  a.line.roomId == room.id &&
                  a.reservation.status != ReservationStatus.cancelled,
            )
            .map(
              (a) => (
                checkInDate: a.reservation.checkInDate,
                checkOutDate: a.reservation.checkOutDate,
                guestName: guestNameByReservationId[a.reservation.id] ?? '',
                reservationId: a.reservation.id,
              ),
            )
            .toList();
        return (room: room, stays: stays);
      }).toList();

      return AsyncValue.data(occupancy);
    });
