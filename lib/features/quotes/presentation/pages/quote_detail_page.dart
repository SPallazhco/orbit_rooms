import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/notifications/notification_service.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/guests/guests_providers.dart';
import 'package:orbit_rooms/features/guests/presentation/widgets/add_guest_dialog.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/quote_share_preview_page.dart';
import 'package:orbit_rooms/features/quotes/presentation/quote_status_label.dart';
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
    final dayLinesAsync = ref.watch(quoteDayLinesProvider(quoteId));
    final currency = ref.watch(currencyProvider).value ?? 'USD';

    return Scaffold(
      appBar: AppBar(title: const Text('Cotización')),
      body: quotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (quotes) {
          ({Quote quote, String propertyName, String roomName})? found;
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

          return dayLinesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (dayLines) {
              final totalCents = ref
                  .read(quoteRepositoryProvider)
                  .totalCentsFor(
                    dayLines,
                    adultsCount: quote.adultsCount,
                    childrenCount: quote.childrenCount,
                  );
              final balanceCents = totalCents - quote.depositCents;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          quote.guestName ?? 'Sin nombre todavía',
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
                    '${quote.adultsCount} adultos, ${quote.childrenCount} niños',
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
                  for (final line in dayLines)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_formatDate(line.date)),
                      subtitle: Text(
                        'Adulto: ${formatCents(line.adultsRateCents, currency)}'
                        '${quote.childrenCount > 0 ? ' · Niño: ${formatCents(line.childrenRateCents, currency)}' : ''}',
                      ),
                      trailing: Text(
                        formatCents(
                          line.adultsRateCents * quote.adultsCount +
                              line.childrenRateCents * quote.childrenCount,
                          currency,
                        ),
                      ),
                      onTap: () => _editDayLine(context, ref, line),
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
                      dayLines,
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
                      onPressed: () => _convertToReservation(
                        context,
                        ref,
                        quote,
                        totalCents,
                      ),
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
    ({Quote quote, String propertyName, String roomName}) entry,
    Quote quote,
    List<QuoteDayLine> dayLines,
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
          dayLines: dayLines,
          adultsCount: quote.adultsCount,
          childrenCount: quote.childrenCount,
          totalCents: totalCents,
          depositCents: quote.depositCents,
          balanceCents: balanceCents,
          currency: currency,
          notes: quote.notes,
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

  Future<void> _editDayLine(
    BuildContext context,
    WidgetRef ref,
    QuoteDayLine line,
  ) async {
    final rates = await showDialog<QuoteDayRates>(
      context: context,
      builder: (_) => EditQuoteDayDialog(
        date: line.date,
        adultsRateCents: line.adultsRateCents,
        childrenRateCents: line.childrenRateCents,
      ),
    );
    if (rates == null) return;

    await ref
        .read(quoteRepositoryProvider)
        .updateDayLine(
          line.id,
          adultsRateCents: rates.adultsRateCents,
          childrenRateCents: rates.childrenRateCents,
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
    int totalCents,
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
                guestsCount: quote.adultsCount + quote.childrenCount,
              ),
            ],
          );
      await ref
          .read(reservationRepositoryProvider)
          .overrideTotalPrice(reservationId, totalCents);
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
