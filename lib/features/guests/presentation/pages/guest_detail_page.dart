import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/guests/guests_providers.dart';
import 'package:orbit_rooms/features/guests/presentation/widgets/add_guest_dialog.dart';
import 'package:orbit_rooms/features/reservations/presentation/pages/reservation_detail_page.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';
import 'package:orbit_rooms/shared/utils/reservation_status_label.dart';

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

/// Historial de reservas de un huésped (PRD 5.3). Se busca al huésped en la
/// lista reactiva ya cargada (`guestsProvider`) en vez de con un
/// `FutureProvider` aparte: así, si se edita desde acá, el nombre/datos de
/// arriba se actualizan solos, igual que el resto de la app.
class GuestDetailPage extends ConsumerWidget {
  const GuestDetailPage({super.key, required this.guestId});

  final String guestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guestsAsync = ref.watch(guestsProvider);
    final reservationsAsync = ref.watch(reservationsForGuestProvider(guestId));
    final currency = ref.watch(currencyProvider).value ?? 'USD';

    return Scaffold(
      appBar: AppBar(title: const Text('Huésped')),
      body: guestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (guests) {
          Guest? found;
          for (final g in guests) {
            if (g.id == guestId) {
              found = g;
              break;
            }
          }
          if (found == null) {
            return const Center(child: Text('Este huésped ya no existe'));
          }
          final guest = found;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    guest.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editGuest(context, ref, guest),
                  ),
                ],
              ),
              if (guest.documentId != null) Text(guest.documentId!),
              if (guest.phone != null) Text(guest.phone!),
              if (guest.email != null) Text(guest.email!),
              if (guest.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(guest.notes!),
              ],
              const Divider(height: 32),
              Text(
                'Historial de reservas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              reservationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (reservations) {
                  if (reservations.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Todavía no tiene reservas'),
                    );
                  }

                  return Column(
                    children: [
                      for (final reservation in reservations)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${_formatDate(reservation.checkInDate)} → '
                            '${_formatDate(reservation.checkOutDate)}',
                          ),
                          subtitle: Text(
                            reservationStatusLabel(reservation.status),
                          ),
                          trailing: Text(
                            formatCents(reservation.totalPriceCents, currency),
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReservationDetailPage(
                                reservationId: reservation.id,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editGuest(
    BuildContext context,
    WidgetRef ref,
    Guest guest,
  ) async {
    final data = await showDialog<NewGuestData>(
      context: context,
      builder: (_) => AddGuestDialog(initial: guest),
    );
    if (data == null) return;

    await ref
        .read(guestRepositoryProvider)
        .update(
          guest.copyWith(
            fullName: data.fullName,
            documentId: Value(data.documentId),
            phone: Value(data.phone),
            email: Value(data.email),
            notes: Value(data.notes),
          ),
        );
  }
}
