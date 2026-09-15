import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/dashboard/dashboard_providers.dart';
import 'package:orbit_rooms/features/reservations/presentation/pages/reservation_detail_page.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardDataProvider);
    final currency = ref.watch(currencyProvider).value ?? 'USD';

    return Scaffold(
      appBar: AppBar(title: const Text("OrbitRooms")),
      drawer: AppDrawer(),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Ocupación actual',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${data.occupiedRoomsCount} / ${data.totalActiveRoomsCount} '
              'habitaciones ocupadas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(height: 32),
            Text(
              'Check-ins de hoy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (data.todayCheckIns.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Ninguno'),
              ),
            for (final entry in data.todayCheckIns)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.guestName),
                onTap: () => _openDetail(context, entry.reservation.id),
              ),
            const Divider(height: 32),
            Text(
              'Check-outs de hoy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (data.todayCheckOuts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Ninguno'),
              ),
            for (final entry in data.todayCheckOuts)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.guestName),
                onTap: () => _openDetail(context, entry.reservation.id),
              ),
            const Divider(height: 32),
            Text('Ingresos', style: Theme.of(context).textTheme.titleMedium),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hoy'),
              trailing: Text(formatCents(data.incomeTodayCents, currency)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Este mes'),
              trailing: Text(formatCents(data.incomeMonthCents, currency)),
            ),
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
