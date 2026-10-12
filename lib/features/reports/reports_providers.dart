import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/guests/guests_providers.dart';
import 'package:orbit_rooms/features/reservations/domain/commission_calculator.dart';
import 'package:orbit_rooms/features/reservations/domain/reservation_pricing.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';

typedef DateRange = ({DateTime start, DateTime end});

typedef GarageEntry = ({
  String guestName,
  String? guestPhone,
  String propertyName,
  String roomNames,
  String plate,
});

/// Reporte de garaje (PRD 9, idea futura convertida en feature a pedido de
/// la administradora): qué autos van a estar la noche de `day`, para
/// enviárselo al dueño del parqueadero (un tercero, no el dueño de la
/// propiedad). Mismo patrón de provider derivado que `dashboardDataProvider`
/// — combina providers reactivos que ya existen (`vehiclesProvider`,
/// `reservationsProvider`, `reservationRoomAssignmentsProvider`,
/// `activeRoomsProvider`, `guestsProvider`), sin tabla ni consulta nueva.
/// Un vehículo está atado a una reserva, no a una habitación puntual — si
/// la reserva cubre varias habitaciones, `roomNames` las junta todas.
final garageReportProvider =
    Provider.family<AsyncValue<List<GarageEntry>>, DateTime>((ref, day) {
      final vehiclesAsync = ref.watch(vehiclesProvider);
      final reservationsAsync = ref.watch(reservationsProvider);
      final assignmentsAsync = ref.watch(reservationRoomAssignmentsProvider);
      final roomsAsync = ref.watch(activeRoomsProvider);
      final guestsAsync = ref.watch(guestsProvider);

      if (vehiclesAsync.isLoading ||
          reservationsAsync.isLoading ||
          assignmentsAsync.isLoading ||
          roomsAsync.isLoading ||
          guestsAsync.isLoading) {
        return const AsyncValue.loading();
      }

      final error =
          vehiclesAsync.error ??
          reservationsAsync.error ??
          assignmentsAsync.error ??
          roomsAsync.error ??
          guestsAsync.error;
      if (error != null) {
        return AsyncValue.error(error, StackTrace.current);
      }

      final vehicles = vehiclesAsync.value!;
      final reservations = reservationsAsync.value!;
      final assignments = assignmentsAsync.value!;
      final rooms = roomsAsync.value!;
      final guests = guestsAsync.value!;

      final entries = <GarageEntry>[];
      for (final vehicle in vehicles) {
        ({Reservation reservation, String guestName})? found;
        for (final entry in reservations) {
          if (entry.reservation.id == vehicle.reservationId) {
            found = entry;
            break;
          }
        }
        if (found == null) continue;
        final reservation = found.reservation;

        final isActiveOnDay =
            reservation.status != ReservationStatus.cancelled &&
            !day.isBefore(reservation.checkInDate) &&
            day.isBefore(reservation.checkOutDate);
        if (!isActiveOnDay) continue;

        Guest? guest;
        for (final g in guests) {
          if (g.id == reservation.guestId) {
            guest = g;
            break;
          }
        }

        final roomNames = <String>[];
        String? propertyName;
        for (final assignment in assignments) {
          if (assignment.line.reservationId != reservation.id) continue;
          for (final roomEntry in rooms) {
            if (roomEntry.room.id == assignment.line.roomId) {
              roomNames.add(roomEntry.room.name);
              propertyName ??= roomEntry.propertyName;
              break;
            }
          }
        }
        if (roomNames.isEmpty) continue;

        entries.add((
          guestName: found.guestName,
          guestPhone: guest?.phone,
          propertyName: propertyName ?? '',
          roomNames: roomNames.join(', '),
          plate: vehicle.plate,
        ));
      }

      return AsyncValue.data(entries);
    });

typedef CommissionEntry = ({
  DateTime date,
  String roomName,
  int guestsCount,
  int revenueCents,
  int garageFeeCents,
  int commissionCents,
});

typedef CommissionReportParams = ({
  String propertyId,
  DateTime start,
  DateTime end,
});

/// Reporte de comisión para una casa administrada (no propia, ver
/// docs/DECISIONS.md): cuánto hay que cobrarle a esa propiedad por los
/// huéspedes que le enviamos en el rango elegido. Mismo patrón de provider
/// derivado que `dashboardDataProvider`/`garageReportProvider` — combina
/// providers reactivos que ya existen (`activeRoomsProvider`,
/// `reservationRoomAssignmentsProvider`, `vehiclesProvider`,
/// `holidaysProvider`), sin tabla ni consulta SQL nueva. Reusa
/// `dayRatesForStay` (mismo dominio que Reservations/Quotes) para el
/// desglose noche por noche, y `commissionCentsForNight` para la regla de
/// comisión negociada con la administradora.
final commissionReportProvider =
    Provider.family<AsyncValue<List<CommissionEntry>>, CommissionReportParams>((
      ref,
      params,
    ) {
      final roomsAsync = ref.watch(activeRoomsProvider);
      final assignmentsAsync = ref.watch(reservationRoomAssignmentsProvider);
      final vehiclesAsync = ref.watch(vehiclesProvider);
      final holidaysAsync = ref.watch(holidaysProvider);

      if (roomsAsync.isLoading ||
          assignmentsAsync.isLoading ||
          vehiclesAsync.isLoading ||
          holidaysAsync.isLoading) {
        return const AsyncValue.loading();
      }

      final error =
          roomsAsync.error ??
          assignmentsAsync.error ??
          vehiclesAsync.error ??
          holidaysAsync.error;
      if (error != null) {
        return AsyncValue.error(error, StackTrace.current);
      }

      final rooms = roomsAsync.value!
          .where((entry) => entry.room.propertyId == params.propertyId)
          .toList();
      final assignments = assignmentsAsync.value!;
      final vehicles = vehiclesAsync.value!;
      final holidayDates = holidaysAsync.value!
          .map((h) => DateTime(h.date.year, h.date.month, h.date.day))
          .toSet();

      final start = DateTime(
        params.start.year,
        params.start.month,
        params.start.day,
      );
      final end = DateTime(params.end.year, params.end.month, params.end.day);
      final rangeEndExclusive = end.add(const Duration(days: 1));

      final entries = <CommissionEntry>[];
      for (final roomEntry in rooms) {
        final room = roomEntry.room;
        final roomAssignments = assignments.where(
          (a) =>
              a.line.roomId == room.id &&
              a.reservation.status != ReservationStatus.cancelled,
        );

        for (final assignment in roomAssignments) {
          final reservation = assignment.reservation;
          final clampedCheckIn = reservation.checkInDate.isBefore(start)
              ? start
              : reservation.checkInDate;
          final clampedCheckOut =
              reservation.checkOutDate.isAfter(rangeEndExclusive)
              ? rangeEndExclusive
              : reservation.checkOutDate;
          if (!clampedCheckIn.isBefore(clampedCheckOut)) continue;

          final garageFeeCents = vehicles
              .where((v) => v.reservationId == reservation.id)
              .fold<int>(0, (sum, v) => sum + (v.garageFeeCents ?? 0));

          final dayRates = dayRatesForStay(
            ratePerPersonWeekdayCents: room.ratePerPersonWeekdayCents,
            ratePerPersonWeekendCents: room.ratePerPersonWeekendCents,
            ratePerPersonHolidayCents: room.ratePerPersonHolidayCents,
            checkInDate: clampedCheckIn,
            checkOutDate: clampedCheckOut,
            holidayDates: holidayDates,
          );

          for (final dayRate in dayRates) {
            final guestsCount = assignment.line.guestsCount;
            entries.add((
              date: dayRate.date,
              roomName: room.name,
              guestsCount: guestsCount,
              revenueCents: dayRate.rateCents * guestsCount,
              garageFeeCents: garageFeeCents,
              commissionCents: commissionCentsForNight(
                ratePerPersonCents: dayRate.rateCents,
                guestsCount: guestsCount,
                garageFeeCents: garageFeeCents,
              ),
            ));
          }
        }
      }

      entries.sort((a, b) => a.date.compareTo(b.date));
      return AsyncValue.data(entries);
    });
