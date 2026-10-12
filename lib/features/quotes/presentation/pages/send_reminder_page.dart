import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/notifications/notification_service.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/quotes/domain/quote_list_order.dart';
import 'package:orbit_rooms/features/quotes/domain/reminder_message.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/quote_detail_page.dart';
import 'package:orbit_rooms/features/quotes/presentation/quote_title.dart';
import 'package:orbit_rooms/features/quotes/quotes_providers.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';
import 'package:orbit_rooms/shared/utils/spanish_dates.dart';
import 'package:share_plus/share_plus.dart';

/// "Recordar al cliente": el mensaje ya armado con los datos de la
/// cotización, editable en el momento, y se comparte con la hoja de
/// compartir (igual que las imágenes del parqueadero y de la comisión) —
/// la usuaria elige el chat de WhatsApp y pulsa enviar. No hay API de
/// WhatsApp de por medio.
class SendReminderPage extends ConsumerWidget {
  const SendReminderPage({super.key, required this.quoteId});

  final String quoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(quotesProvider);
    final currency = ref.watch(currencyProvider).value ?? 'USD';
    final templateAsync = ref.watch(reminderMessageTemplateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recordar al cliente')),
      body: quotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (quotes) {
          final matches = quotes.where((q) => q.quote.id == quoteId);
          if (matches.isEmpty) {
            return const Center(child: Text('Esta cotización ya no existe'));
          }
          final entry = matches.first;
          final breakdownAsync = ref.watch(
            quoteBreakdownProvider((
              quoteId: quoteId,
              adultsCount: entry.quote.adultsCount,
            )),
          );

          return breakdownAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (breakdown) {
              final message = renderReminderMessage(
                templateAsync.value ?? defaultReminderTemplate,
                (
                  guestName: entry.quote.guestName,
                  propertyName: entry.propertyName,
                  checkInDate: entry.quote.checkInDate,
                  adultsCount: entry.quote.adultsCount,
                  childrenCount: breakdown.childrenCount,
                  total: formatCents(breakdown.totalCents, currency),
                  deposit: formatCents(entry.quote.depositCents, currency),
                ),
              );

              return _ReminderForm(
                quote: entry.quote,
                propertyName: entry.propertyName,
                roomName: entry.roomName,
                childrenCount: breakdown.childrenCount,
                totalText: formatCents(breakdown.totalCents, currency),
                initialMessage: message,
              );
            },
          );
        },
      ),
    );
  }
}

class _ReminderForm extends ConsumerStatefulWidget {
  const _ReminderForm({
    required this.quote,
    required this.propertyName,
    required this.roomName,
    required this.childrenCount,
    required this.totalText,
    required this.initialMessage,
  });

  final Quote quote;
  final String propertyName;
  final String roomName;
  final int childrenCount;
  final String totalText;
  final String initialMessage;

  @override
  ConsumerState<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends ConsumerState<_ReminderForm> {
  late final _controller = TextEditingController(text: widget.initialMessage);
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markSent() async {
    await ref
        .read(quoteRepositoryProvider)
        .markReminderSent(widget.quote.id, DateTime.now());
    await NotificationService.cancelQuoteReminder(widget.quote.id);
  }

  Future<void> _share() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _busy = true);
    try {
      final result = await SharePlus.instance.share(ShareParams(text: text));
      if (result.status != ShareResultStatus.success) return;

      await _markSent();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Recordatorio enviado')));
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _alreadyContacted() async {
    await _markSent();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Marcada como recordada')));
    Navigator.of(context).pop();
  }

  Future<void> _copyContact(String contact) async {
    await Clipboard.setData(ClipboardData(text: contact));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Número copiado')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final quote = widget.quote;
    final contact = quote.guestContact?.trim();
    final hasContact = contact != null && contact.isNotEmpty;
    final daysLeft = daysUntil(quote.checkInDate, DateTime.now());
    final sentAt = quote.reminderSentAt;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            title: Text(
              quoteTitle(
                guestName: quote.guestName,
                checkInDate: quote.checkInDate,
                adultsCount: quote.adultsCount,
                childrenCount: widget.childrenCount,
              ),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${widget.propertyName} · Hab. ${widget.roomName}\n'
              '${daysLeft <= 0
                  ? 'Llega hoy'
                  : daysLeft == 1
                  ? 'Llega mañana'
                  : 'Llega en $daysLeft días'} · ${widget.totalText}',
            ),
            isThreeLine: true,
            trailing: IconButton(
              tooltip: 'Ver cotización',
              icon: const Icon(Icons.open_in_new),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuoteDetailPage(quoteId: quote.id),
                ),
              ),
            ),
          ),
        ),
        if (sentAt != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ya se le recordó el ${formatShortDate(sentAt)}. '
                  'Puedes enviarlo de nuevo.',
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        if (hasContact)
          Row(
            children: [
              Icon(Icons.phone_outlined, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  contact,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyContact(contact),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar'),
              ),
            ],
          )
        else
          Text(
            'Esta cotización no tiene contacto cargado: al compartir, elige '
            'el chat de WhatsApp a mano.',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          minLines: 6,
          maxLines: 12,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            labelText: 'Mensaje',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            helperText:
                'Puedes editarlo antes de enviar. El texto de siempre se '
                'cambia en Configuración.',
            helperMaxLines: 2,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _busy ? null : _share,
          icon: const Icon(Icons.ios_share),
          label: const Text('Enviar por WhatsApp'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : _alreadyContacted,
          child: const Text('Ya le escribí por otro medio'),
        ),
      ],
    );
  }
}
