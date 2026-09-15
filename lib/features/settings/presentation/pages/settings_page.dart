import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/settings/presentation/widgets/add_holiday_dialog.dart';
import 'package:orbit_rooms/features/settings/presentation/widgets/edit_currency_dialog.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyAsync = ref.watch(currencyProvider);
    final holidaysAsync = ref.watch(holidaysProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Moneda'),
            subtitle: currencyAsync.when(
              loading: () => const Text('Cargando...'),
              error: (error, _) => Text('Error: $error'),
              data: (currency) => Text(currency),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  _editCurrency(context, ref, currencyAsync.value ?? 'USD'),
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Feriados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () => _addHoliday(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
          ),
          holidaysAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (holidays) {
              if (holidays.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Todavía no tienes feriados cargados'),
                );
              }

              return Column(
                children: [
                  for (final holiday in holidays)
                    ListTile(
                      title: Text(_formatDate(holiday.date)),
                      subtitle: holiday.name == null
                          ? null
                          : Text(holiday.name!),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(holidayRepositoryProvider)
                            .remove(holiday.id),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _editCurrency(
    BuildContext context,
    WidgetRef ref,
    String currentCurrency,
  ) async {
    final currency = await showDialog<String>(
      context: context,
      builder: (_) => EditCurrencyDialog(currentCurrency: currentCurrency),
    );
    if (currency == null) return;

    await ref.read(appSettingsRepositoryProvider).setCurrency(currency);
  }

  Future<void> _addHoliday(BuildContext context, WidgetRef ref) async {
    final data = await showDialog<NewHolidayData>(
      context: context,
      builder: (_) => const AddHolidayDialog(),
    );
    if (data == null) return;

    try {
      await ref
          .read(holidayRepositoryProvider)
          .add(date: data.date, name: data.name);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya existe un feriado en esa fecha')),
      );
    }
  }
}
