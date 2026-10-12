import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/reminders_page.dart';
import 'package:orbit_rooms/features/quotes/quotes_providers.dart';

/// La campanita de la esquina: el número es cuántas cotizaciones pendientes
/// están por llegar y todavía no se recordaron.
class RemindersBell extends ConsumerWidget {
  const RemindersBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(reminderInboxProvider).value?.toRemind.length ?? 0;

    return IconButton(
      tooltip: 'Avisos de cotizaciones',
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const RemindersPage())),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
