import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/reservations/presentation/widgets/add_payment_dialog.dart';
import 'package:orbit_rooms/features/reservations/presentation/widgets/add_vehicle_dialog.dart';
import 'package:orbit_rooms/features/reservations/presentation/widgets/edit_notes_dialog.dart';
import 'package:orbit_rooms/features/reservations/presentation/widgets/edit_price_dialog.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';
import 'package:orbit_rooms/shared/utils/reservation_status_label.dart';

class ReservationDetailPage extends ConsumerWidget {
  const ReservationDetailPage({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(reservationDetailProvider(reservationId));
    final currency = ref.watch(currencyProvider).value ?? 'USD';

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de reserva')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (detail) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              detail.guestName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatDate(detail.reservation.checkInDate)} → '
              '${_formatDate(detail.reservation.checkOutDate)}',
            ),
            const SizedBox(height: 8),
            DropdownButton<ReservationStatus>(
              value: detail.reservation.status,
              isExpanded: true,
              items: ReservationStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(reservationStatusLabel(status)),
                    ),
                  )
                  .toList(),
              onChanged: (status) async {
                if (status == null) return;
                await ref
                    .read(reservationRepositoryProvider)
                    .updateStatus(reservationId, status);
                ref.invalidate(reservationDetailProvider(reservationId));
              },
            ),
            const Divider(height: 32),
            Text(
              'Habitaciones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final assignment in detail.roomAssignments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(assignment.room.name),
                subtitle: Text('${assignment.line.guestsCount} personas'),
                trailing: Text(
                  formatCents(assignment.line.subtotalCents, currency),
                ),
              ),
            const Divider(height: 32),
            Text(
              'Vehículos (garaje)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (detail.vehicles.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Sin vehículos declarados'),
              ),
            for (final vehicle in detail.vehicles)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(vehicle.plate),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref
                        .read(vehicleRepositoryProvider)
                        .delete(vehicle.id);
                    ref.invalidate(reservationDetailProvider(reservationId));
                  },
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _addVehicle(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Agregar vehículo'),
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Precio total',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    Text(
                      formatCents(detail.reservation.totalPriceCents, currency),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _editPrice(context, ref, detail),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Pagos', style: Theme.of(context).textTheme.titleMedium),
            for (final payment in detail.payments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(formatCents(payment.amountCents, currency)),
                subtitle: Text(_methodLabel(payment.method)),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saldo pendiente',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(formatCents(detail.balanceCents, currency)),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _addPayment(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Registrar pago'),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notas', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _editNotes(context, ref, detail),
                ),
              ],
            ),
            Text(
              detail.reservation.notes?.isNotEmpty == true
                  ? detail.reservation.notes!
                  : 'Sin notas',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPayment(BuildContext context, WidgetRef ref) async {
    final data = await showDialog<NewPaymentData>(
      context: context,
      builder: (_) => const AddPaymentDialog(),
    );
    if (data == null) return;

    await ref
        .read(registerPaymentUseCaseProvider)
        .call(
          reservationId: reservationId,
          amountCents: data.amountCents,
          method: data.method,
        );
    ref.invalidate(reservationDetailProvider(reservationId));
  }

  Future<void> _editPrice(
    BuildContext context,
    WidgetRef ref,
    ReservationDetailData detail,
  ) async {
    final newPriceCents = await showDialog<int>(
      context: context,
      builder: (_) => EditPriceDialog(
        currentPriceCents: detail.reservation.totalPriceCents,
      ),
    );
    if (newPriceCents == null) return;

    await ref
        .read(reservationRepositoryProvider)
        .overrideTotalPrice(reservationId, newPriceCents);
    ref.invalidate(reservationDetailProvider(reservationId));
  }

  Future<void> _addVehicle(BuildContext context, WidgetRef ref) async {
    final plate = await showDialog<String>(
      context: context,
      builder: (_) => const AddVehicleDialog(),
    );
    if (plate == null) return;

    await ref
        .read(vehicleRepositoryProvider)
        .create(reservationId: reservationId, plate: plate);
    ref.invalidate(reservationDetailProvider(reservationId));
  }

  Future<void> _editNotes(
    BuildContext context,
    WidgetRef ref,
    ReservationDetailData detail,
  ) async {
    final notes = await showDialog<String>(
      context: context,
      builder: (_) => EditNotesDialog(initialNotes: detail.reservation.notes),
    );
    if (notes == null) return;

    await ref
        .read(reservationRepositoryProvider)
        .updateNotes(reservationId, notes.isEmpty ? null : notes);
    ref.invalidate(reservationDetailProvider(reservationId));
  }
}

String _methodLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => 'Efectivo',
  PaymentMethod.transfer => 'Transferencia',
  PaymentMethod.card => 'Tarjeta',
  PaymentMethod.other => 'Otro',
};

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
