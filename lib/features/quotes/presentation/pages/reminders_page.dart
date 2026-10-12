import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/send_reminder_page.dart';
import 'package:orbit_rooms/features/quotes/presentation/quote_title.dart';
import 'package:orbit_rooms/features/quotes/quotes_providers.dart';
import 'package:orbit_rooms/shared/utils/spanish_dates.dart';

String _timeText(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _whenText(int daysLeft) => switch (daysLeft) {
  0 => 'Llega hoy',
  1 => 'Llega mañana',
  _ => 'Llega en $daysLeft días',
};

class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(reminderInboxProvider);
    final days = ref.watch(quoteReminderDaysProvider).value ?? 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Avisos')),
      body: inboxAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (inbox) {
          if (inbox.toRemind.isEmpty && inbox.reminded.isEmpty) {
            return _AllClear(days: days);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (inbox.toRemind.isNotEmpty) ...[
                _SectionTitle('Por recordar · ${inbox.toRemind.length}'),
                for (final reminder in inbox.toRemind)
                  _ReminderTile(reminder: reminder),
              ] else
                const _CaughtUp(),
              if (inbox.reminded.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SectionTitle('Ya recordadas · ${inbox.reminded.length}'),
                for (final reminder in inbox.reminded)
                  _ReminderTile(reminder: reminder, done: true),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder, this.done = false});

  final QuoteReminder reminder;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final quote = reminder.quote;
    final title = quoteTitle(
      guestName: quote.guestName,
      checkInDate: quote.checkInDate,
      adultsCount: quote.adultsCount,
      childrenCount: reminder.summary.childrenCount,
    );
    final sentAt = quote.reminderSentAt;
    final subtitle = done && sentAt != null
        ? 'Recordada el ${formatShortDate(sentAt)} a las ${_timeText(sentAt)}'
        : _whenText(reminder.daysLeft);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        color: done ? scheme.surfaceContainerLow : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: done
                ? scheme.surfaceContainerHighest
                : reminder.daysLeft <= 1
                ? scheme.errorContainer
                : scheme.primaryContainer,
            foregroundColor: done
                ? scheme.onSurfaceVariant
                : reminder.daysLeft <= 1
                ? scheme.onErrorContainer
                : scheme.onPrimaryContainer,
            child: Icon(done ? Icons.check : Icons.notifications_active),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: done ? scheme.onSurfaceVariant : null,
            ),
          ),
          subtitle: Text(
            '${reminder.propertyName} · Hab. ${reminder.roomName}\n$subtitle',
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SendReminderPage(quoteId: quote.id),
            ),
          ),
        ),
      ),
    );
  }
}

class _CaughtUp extends StatelessWidget {
  const _CaughtUp();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      child: ListTile(
        leading: Icon(Icons.check_circle_outline, color: scheme.primary),
        title: const Text('No te queda nadie por recordar'),
      ),
    );
  }
}

class _AllClear extends StatelessWidget {
  const _AllClear({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                Icons.notifications_none,
                size: 36,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text('Todo al día', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Cuando una cotización pendiente esté a $days '
              '${days == 1 ? 'día' : 'días'} de su check-in, aparecerá aquí '
              'para que le recuerdes al cliente.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
