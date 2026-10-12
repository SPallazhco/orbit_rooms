import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/notifications/notification_service.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/guests/guests_providers.dart';
import 'package:orbit_rooms/features/guests/presentation/widgets/add_guest_dialog.dart';
import 'package:orbit_rooms/features/quotes/domain/quote_pricing.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/quote_share_preview_page.dart';
import 'package:orbit_rooms/features/quotes/presentation/quote_status_label.dart';
import 'package:orbit_rooms/features/quotes/presentation/quote_title.dart';
import 'package:orbit_rooms/features/quotes/presentation/widgets/edit_deposit_dialog.dart';
import 'package:orbit_rooms/features/quotes/presentation/widgets/edit_quote_day_dialog.dart';
import 'package:orbit_rooms/features/quotes/presentation/widgets/edit_quote_guest_dialog.dart';
import 'package:orbit_rooms/features/quotes/quotes_providers.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';
import 'package:orbit_rooms/features/reservations/presentation/pages/reservation_detail_page.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

/// Igual que `GuestDetailPage`: busca la cotización en la lista reactiva
/// ya cargada (`quotesProvider`) en vez de un `FutureProvider` aparte, así
/// que editar desde acá se refleja solo.
class QuoteDetailPage extends ConsumerWidget {
  const QuoteDetailPage({super.key, required this.quoteId});

  final String quoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(quotesProvider);
    final currency = ref.watch(currencyProvider).value ?? 'USD';

    return Scaffold(
      appBar: AppBar(title: const Text('Cotización')),
      body: quotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (quotes) {
          ({
            Quote quote,
            String propertyName,
            String? ownerName,
            String roomName,
          })?
          found;
          for (final entry in quotes) {
            if (entry.quote.id == quoteId) {
              found = entry;
              break;
            }
          }
          if (found == null) {
            return const Center(child: Text('Esta cotización ya no existe'));
          }
          final entry = found;
          final quote = entry.quote;

          final breakdownAsync = ref.watch(
            quoteBreakdownProvider((
              quoteId: quoteId,
              adultsCount: quote.adultsCount,
            )),
          );

          return breakdownAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (breakdown) {
              final totalCents = breakdown.totalCents;
              final balanceCents = totalCents - quote.depositCents;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          quote.guestName ??
                              quoteTitle(
                                checkInDate: quote.checkInDate,
                                adultsCount: quote.adultsCount,
                                childrenCount: breakdown.childrenCount,
                              ),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _editGuestInfo(context, ref, quote),
                      ),
                    ],
                  ),
                  if (quote.guestContact != null) Text(quote.guestContact!),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.propertyName} — ${entry.roomName} · '
                    '${_formatDate(quote.checkInDate)} → '
                    '${_formatDate(quote.checkOutDate)}',
                  ),
                  Text(
                    '${quote.adultsCount} '
                    '${quote.adultsCount == 1 ? 'adulto' : 'adultos'}, '
                    '${breakdown.childrenCount} '
                    '${breakdown.childrenCount == 1 ? 'niño' : 'niños'}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quoteStatusLabel(quote.status),
                    style: TextStyle(
                      color: quoteStatusColor(context, quote.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    'Desglose por noche',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (breakdown.hasUnpricedChildren)
                    Card(
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        title: Text(
                          'Hay niños con tarifa 0.00: se están cobrando '
                          'gratis. Tocá una noche para ponerles tarifa.',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  for (final night in breakdown.nights)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_formatDate(night.date)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adultos ${quote.adultsCount} × '
                            '${formatCents(night.adultsRateCents, currency)}',
                          ),
                          for (final child in night.children)
                            Text(
                              '${child.group.count == 1 ? 'Niño' : 'Niños'} '
                              '${child.group.count} × '
                              '${formatCents(child.rateCents, currency)}',
                            ),
                        ],
                      ),
                      trailing: Text(formatCents(night.totalCents, currency)),
                      onTap: () => _editNight(
                        context,
                        ref,
                        night,
                        breakdown.nights.length,
                      ),
                    ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        formatCents(totalCents, currency),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Abono para la reservación'),
                      Row(
                        children: [
                          Text(formatCents(quote.depositCents, currency)),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editDeposit(context, ref, quote),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Saldo'),
                      Text(formatCents(balanceCents, currency)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _shareQuote(
                      context,
                      entry,
                      quote,
                      breakdown,
                      totalCents,
                      balanceCents,
                      currency,
                    ),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Compartir por WhatsApp'),
                  ),
                  const SizedBox(height: 8),
                  if (quote.status != QuoteStatus.reserved) ...[
                    OutlinedButton(
                      onPressed: () => _toggleRejected(context, ref, quote),
                      child: Text(
                        quote.status == QuoteStatus.rejected
                            ? 'Reactivar cotización'
                            : 'Marcar como rechazada',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () =>
                          _convertToReservation(context, ref, quote, breakdown),
                      child: const Text('Convertir en reserva'),
                    ),
                  ] else
                    Text(
                      'Ya se convirtió en una reserva.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _shareQuote(
    BuildContext context,
    ({Quote quote, String propertyName, String? ownerName, String roomName})
    entry,
    Quote quote,
    QuoteBreakdown breakdown,
    int totalCents,
    int balanceCents,
    String currency,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuoteSharePreviewPage(
          propertyName: entry.propertyName,
          roomName: entry.roomName,
          guestName: quote.guestName,
          nights: breakdown.nights,
          adultsCount: quote.adultsCount,
          totalCents: totalCents,
          depositCents: quote.depositCents,
          balanceCents: balanceCents,
          currency: currency,
          notes: quote.notes,
          showBrand: entry.ownerName == null || entry.ownerName!.trim().isEmpty,
        ),
      ),
    );
  }

  Future<void> _editGuestInfo(
    BuildContext context,
    WidgetRef ref,
    Quote quote,
  ) async {
    final data = await showDialog<QuoteGuestInfo>(
      context: context,
      builder: (_) => EditQuoteGuestDialog(
        guestName: quote.guestName,
        guestContact: quote.guestContact,
        notes: quote.notes,
      ),
    );
    if (data == null) return;

    await ref
        .read(quoteRepositoryProvider)
        .updateGuestInfo(
          quote.id,
          guestName: data.guestName,
          guestContact: data.guestContact,
          notes: data.notes,
        );
  }

  Future<void> _editNight(
    BuildContext context,
    WidgetRef ref,
    QuoteNight night,
    int nightsCount,
  ) async {
    final edit = await showDialog<QuoteNightEdit>(
      context: context,
      builder: (_) =>
          EditQuoteDayDialog(night: night, nightsCount: nightsCount),
    );
    if (edit == null) return;

    await ref
        .read(quoteRepositoryProvider)
        .updateNight(
          night.line,
          adultsRateCents: edit.adultsRateCents,
          childRatesByGroupId: edit.childRatesByGroupId,
          applyChildRatesToAllNights: edit.applyChildRatesToAllNights,
        );
  }

  Future<void> _editDeposit(
    BuildContext context,
    WidgetRef ref,
    Quote quote,
  ) async {
    final depositCents = await showDialog<int>(
      context: context,
      builder: (_) =>
          EditDepositDialog(currentDepositCents: quote.depositCents),
    );
    if (depositCents == null) return;

    await ref
        .read(quoteRepositoryProvider)
        .updateDeposit(quote.id, depositCents);
  }

  Future<void> _toggleRejected(
    BuildContext context,
    WidgetRef ref,
    Quote quote,
  ) async {
    final newStatus = quote.status == QuoteStatus.rejected
        ? QuoteStatus.pending
        : QuoteStatus.rejected;
    await ref.read(quoteRepositoryProvider).updateStatus(quote.id, newStatus);

    if (newStatus == QuoteStatus.rejected) {
      await NotificationService.cancelQuoteReminder(quote.id);
    } else {
      final reminderDays = await ref
          .read(appSettingsRepositoryProvider)
          .getQuoteReminderDays();
      await NotificationService.scheduleQuoteReminder(
        quoteId: quote.id,
        checkInDate: quote.checkInDate,
        reminderDays: reminderDays,
        guestLabel: quote.guestName ?? 'Un posible huésped',
      );
    }
  }

  Future<void> _convertToReservation(
    BuildContext context,
    WidgetRef ref,
    Quote quote,
    QuoteBreakdown breakdown,
  ) async {
    final data = await showDialog<NewGuestData>(
      context: context,
      builder: (_) => AddGuestDialog(
        initial: Guest(
          id: '',
          fullName: quote.guestName ?? '',
          phone: quote.guestContact,
        ),
      ),
    );
    if (data == null) return;

    final guestId = await ref
        .read(guestRepositoryProvider)
        .create(
          fullName: data.fullName,
          documentId: data.documentId,
          phone: data.phone,
          email: data.email,
          notes: data.notes,
        );

    try {
      final reservationId = await ref
          .read(reservationRepositoryProvider)
          .createGroupReservation(
            guestId: guestId,
            checkInDate: quote.checkInDate,
            checkOutDate: quote.checkOutDate,
            roomAssignments: [
              RoomAssignmentInput(
                roomId: quote.roomId,
                guestsCount: quote.adultsCount + breakdown.childrenCount,
              ),
            ],
          );
      await ref
          .read(reservationRepositoryProvider)
          .overrideTotalPrice(reservationId, breakdown.totalCents);
      if (quote.notes != null) {
        await ref
            .read(reservationRepositoryProvider)
            .updateNotes(reservationId, quote.notes);
      }
      await ref
          .read(quoteRepositoryProvider)
          .markReserved(quote.id, reservationId);
      await NotificationService.cancelQuoteReminder(quote.id);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReservationDetailPage(reservationId: reservationId),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo reservar: $e')));
    }
  }
}
