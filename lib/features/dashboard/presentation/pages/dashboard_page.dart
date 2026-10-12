import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/routes/routes_names.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/dashboard/dashboard_providers.dart';
import 'package:orbit_rooms/features/dashboard/presentation/widgets/movements_card.dart';
import 'package:orbit_rooms/features/dashboard/presentation/widgets/occupancy_donut.dart';
import 'package:orbit_rooms/features/quotes/presentation/widgets/reminders_bell.dart';
import 'package:orbit_rooms/features/reservations/presentation/pages/reservation_detail_page.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';
import 'package:orbit_rooms/shared/utils/spanish_dates.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

String _greeting(DateTime now) {
  if (now.hour < 12) return 'Buenos días';
  if (now.hour < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardDataProvider);
    final currency = ref.watch(currencyProvider).value ?? 'USD';

    return Scaffold(
      appBar: AppBar(
        title: const Text('OrbitRooms'),
        actions: const [RemindersBell()],
      ),
      drawer: AppDrawer(),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _Header(),
            const SizedBox(height: 16),
            _OccupancyCard(data: data),
            const SizedBox(height: 16),
            MovementsCard(
              title: 'Llegadas de hoy',
              icon: Icons.login,
              emptyMessage: 'Hoy no llega nadie.',
              movements: data.todayCheckIns,
              currency: currency,
              onTap: (id) => _openDetail(context, id),
              footnote:
                  'Mañana: ${data.tomorrowCheckInsCount} '
                  '${data.tomorrowCheckInsCount == 1 ? 'llegada' : 'llegadas'}',
            ),
            const SizedBox(height: 16),
            MovementsCard(
              title: 'Salidas de hoy',
              icon: Icons.logout,
              emptyMessage: 'Hoy no sale nadie.',
              movements: data.todayCheckOuts,
              currency: currency,
              onTap: (id) => _openDetail(context, id),
              footnote:
                  'Mañana: ${data.tomorrowCheckOutsCount} '
                  '${data.tomorrowCheckOutsCount == 1 ? 'salida' : 'salidas'}',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _IncomeTile(
                    label: 'Ingresos de hoy',
                    value: formatCents(data.incomeTodayCents, currency),
                    icon: Icons.today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IncomeTile(
                    label: 'Ingresos del mes',
                    value: formatCents(data.incomeMonthCents, currency),
                    icon: Icons.calendar_month,
                  ),
                ),
              ],
            ),
            if (data.pendingQuotesCount > 0) ...[
              const SizedBox(height: 16),
              _PendingQuotesCard(count: data.pendingQuotesCount),
            ],
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, String reservationId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReservationDetailPage(reservationId: reservationId),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(now),
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          formatLongDate(now),
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  const _OccupancyCard({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final free = data.totalActiveRoomsCount - data.occupiedRoomsCount;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ocupación actual', style: textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                OccupancyDonut(
                  occupied: data.occupiedRoomsCount,
                  total: data.totalActiveRoomsCount,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow(
                        color: scheme.primary,
                        label: 'Ocupadas',
                        value: data.occupiedRoomsCount,
                      ),
                      const SizedBox(height: 10),
                      _LegendRow(
                        color: scheme.surfaceContainerHighest,
                        label: 'Libres',
                        value: free,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${data.guestsInHouseCount} '
                              '${data.guestsInHouseCount == 1 ? 'huésped' : 'huéspedes'} '
                              'hospedados',
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (data.occupancyByProperty.length > 1) ...[
              const Divider(height: 28),
              for (final property in data.occupancyByProperty)
                _PropertyBar(property: property),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        Text(
          '$value',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _PropertyBar extends StatelessWidget {
  const _PropertyBar({required this.property});

  final PropertyOccupancy property;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fraction = property.total == 0
        ? 0.0
        : property.occupied / property.total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  property.propertyName,
                  style: textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${property.occupied}/${property.total}',
                style: textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeTile extends StatelessWidget {
  const _IncomeTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary, size: 22),
            const SizedBox(height: 10),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingQuotesCard extends StatelessWidget {
  const _PendingQuotesCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.secondaryContainer,
      child: ListTile(
        leading: Icon(
          Icons.request_quote_outlined,
          color: scheme.onSecondaryContainer,
        ),
        title: Text(
          count == 1
              ? '1 cotización pendiente'
              : '$count cotizaciones pendientes',
          style: TextStyle(
            color: scheme.onSecondaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Pendientes de confirmar',
          style: TextStyle(color: scheme.onSecondaryContainer),
        ),
        trailing: Icon(Icons.chevron_right, color: scheme.onSecondaryContainer),
        onTap: () => Navigator.of(context).pushNamed(RoutesNames.quotes),
      ),
    );
  }
}
