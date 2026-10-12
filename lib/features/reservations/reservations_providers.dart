import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/database/database_providers.dart';
import 'package:orbit_rooms/features/guests/guests_providers.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';

import 'data/payment_repository.dart';
import 'data/reservation_repository.dart';
import 'data/vehicle_repository.dart';
import 'domain/reservation_timeline.dart';
import 'domain/usecases/create_reservation_use_case.dart';
import 'domain/usecases/register_payment_use_case.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>(
  (ref) => ReservationRepository(ref.watch(appDatabaseProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepository(ref.watch(appDatabaseProvider)),
);

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) => VehicleRepository(ref.watch(appDatabaseProvider)),
);

final createReservationUseCaseProvider = Provider<CreateReservationUseCase>(
  (ref) => CreateReservationUseCase(ref.watch(reservationRepositoryProvider)),
);

final registerPaymentUseCaseProvider = Provider<RegisterPaymentUseCase>(
  (ref) => RegisterPaymentUseCase(ref.watch(paymentRepositoryProvider)),
);

/// Estado reactivo, mismo patrón que `activePropertiesProvider`.
final reservationsProvider =
    StreamProvider<List<({Reservation reservation, String guestName})>>(
      (ref) => ref.watch(reservationRepositoryProvider).watchAll(),
    );

/// Para calcular ocupación actual en el Dashboard (PRD 5.7).
final reservationRoomAssignmentsProvider =
    StreamProvider<List<({ReservationRoom line, Reservation reservation})>>(
      (ref) =>
          ref.watch(reservationRepositoryProvider).watchAllRoomAssignments(),
    );

/// Para sumar ingresos en el Dashboard (PRD 5.7).
final paymentsProvider = StreamProvider<List<Payment>>(
  (ref) => ref.watch(paymentRepositoryProvider).watchAll(),
);

/// Para el reporte de garaje (PRD 9), en Reportes.
final vehiclesProvider = StreamProvider<List<Vehicle>>(
  (ref) => ref.watch(vehicleRepositoryProvider).watchAll(),
);

/// Historial de reservas de un huésped (PRD 5.3), en `GuestDetailPage`.
final reservationsForGuestProvider =
    StreamProvider.family<List<Reservation>, String>(
      (ref, guestId) =>
          ref.watch(reservationRepositoryProvider).watchByGuest(guestId),
    );

typedef ReservationDetailData = ({
  Reservation reservation,
  String guestName,
  List<({ReservationRoom line, Room room})> roomAssignments,
  List<Payment> payments,
  int balanceCents,
  List<Vehicle> vehicles,
});

/// A diferencia de `reservationsProvider`, esto NO es reactivo (es un
/// `FutureProvider`, una foto única): una pantalla de detalle se abre de
/// nuevo cada vez, así que alcanza con refrescar a mano
/// (`ref.invalidate(reservationDetailProvider(id))`) después de cada acción
/// (pago, cambio de estado) en vez de mantener un stream abierto.
final reservationDetailProvider =
    FutureProvider.family<ReservationDetailData, String>((
      ref,
      reservationId,
    ) async {
      final reservationRepository = ref.watch(reservationRepositoryProvider);
      final guestRepository = ref.watch(guestRepositoryProvider);
      final roomRepository = ref.watch(roomRepositoryProvider);
      final paymentRepository = ref.watch(paymentRepositoryProvider);
      final vehicleRepository = ref.watch(vehicleRepositoryProvider);

      final reservation = await reservationRepository.getById(reservationId);
      final guest = await guestRepository.getById(reservation.guestId);
      final lines = await reservationRepository.getRoomsForReservation(
        reservationId,
      );
      final roomAssignments = <({ReservationRoom line, Room room})>[];
      for (final line in lines) {
        final room = await roomRepository.getById(line.roomId);
        roomAssignments.add((line: line, room: room));
      }
      final payments = await paymentRepository.getForReservation(reservationId);
      final balanceCents = await paymentRepository.getBalanceCents(
        reservationId,
      );
      final vehicles = await vehicleRepository.getForReservation(reservationId);

      return (
        reservation: reservation,
        guestName: guest.fullName,
        roomAssignments: roomAssignments,
        payments: payments,
        balanceCents: balanceCents,
        vehicles: vehicles,
      );
    });

typedef ReservationListItem = ({
  Reservation reservation,
  String guestName,
  String roomNames,
  int guestsCount,
  int paidCents,
  ReservationPhase phase,
});

/// Cada reserva con lo que la lista necesita para decidir de un vistazo:
/// habitaciones, personas, cuánto se cobró y en qué fase está. Provider
/// derivado (mismo patrón que Dashboard): sin consulta SQL nueva.
final reservationListProvider = Provider<AsyncValue<List<ReservationListItem>>>(
  (ref) {
    final reservationsAsync = ref.watch(reservationsProvider);
    final assignmentsAsync = ref.watch(reservationRoomAssignmentsProvider);
    final roomsAsync = ref.watch(activeRoomsProvider);
    final paymentsAsync = ref.watch(paymentsProvider);

    if (reservationsAsync.isLoading ||
        assignmentsAsync.isLoading ||
        roomsAsync.isLoading ||
        paymentsAsync.isLoading) {
      return const AsyncValue.loading();
    }
    final error =
        reservationsAsync.error ??
        assignmentsAsync.error ??
        roomsAsync.error ??
        paymentsAsync.error;
    if (error != null) return AsyncValue.error(error, StackTrace.current);

    final roomNameById = {
      for (final entry in roomsAsync.value!) entry.room.id: entry.room.name,
    };
    final linesByReservation = <String, List<ReservationRoom>>{};
    for (final a in assignmentsAsync.value!) {
      linesByReservation.putIfAbsent(a.reservation.id, () => []).add(a.line);
    }
    final paidByReservation = <String, int>{};
    for (final p in paymentsAsync.value!) {
      paidByReservation.update(
        p.reservationId,
        (sum) => sum + p.amountCents,
        ifAbsent: () => p.amountCents,
      );
    }

    final now = DateTime.now();
    return AsyncValue.data([
      for (final entry in reservationsAsync.value!)
        (
          reservation: entry.reservation,
          guestName: entry.guestName,
          roomNames: (linesByReservation[entry.reservation.id] ?? [])
              .map((l) => roomNameById[l.roomId])
              .whereType<String>()
              .join(', '),
          guestsCount: (linesByReservation[entry.reservation.id] ?? []).fold(
            0,
            (sum, l) => sum + l.guestsCount,
          ),
          paidCents: paidByReservation[entry.reservation.id] ?? 0,
          phase: reservationPhase(entry.reservation, now),
        ),
    ]);
  },
);
