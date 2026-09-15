import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/presentation/pages/create_reservation_page.dart';
import 'package:orbit_rooms/features/reservations/presentation/pages/reservation_detail_page.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

String _statusLabel(ReservationStatus status) => switch (status) {
  ReservationStatus.pending => 'Pendiente',
  ReservationStatus.confirmed => 'Confirmada',
  ReservationStatus.checkedIn => 'Check-in hecho',
  ReservationStatus.checkedOut => 'Check-out hecho',
  ReservationStatus.cancelled => 'Cancelada',
};

class ReservationsPage extends ConsumerWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(reservationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reservas')),
      drawer: AppDrawer(),
      body: reservationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(child: Text('Todavía no tienes reservas'));
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final entry = reservations[index];
              final reservation = entry.reservation;
              return ListTile(
                title: Text(entry.guestName),
                subtitle: Text(
                  '${_formatDate(reservation.checkInDate)} → '
                  '${_formatDate(reservation.checkOutDate)} · '
                  '${_statusLabel(reservation.status)}',
                ),
                trailing: Text(
                  (reservation.totalPriceCents / 100).toStringAsFixed(2),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ReservationDetailPage(reservationId: reservation.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateReservationPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
