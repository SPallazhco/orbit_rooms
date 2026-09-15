import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/features/reports/reports_providers.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

String _formatCents(int cents) => (cents / 100).toStringAsFixed(2);

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

DateTime _startOfMonth(DateTime d) => DateTime(d.year, d.month);

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  late DateRange _range = (
    start: _startOfMonth(DateTime.now()),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(reportDataProvider(_range));

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatDate(_range.start)} - ${_formatDate(_range.end)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => _pickRange(context),
                child: const Text('Elegir rango'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          reportAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (report) {
              final occupancyRate = report.totalRoomNights == 0
                  ? 0.0
                  : report.occupiedRoomNights / report.totalRoomNights * 100;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ocupación',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${report.occupiedRoomNights} / '
                    '${report.totalRoomNights} noches-habitación '
                    '(${occupancyRate.toStringAsFixed(1)}%)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(height: 32),
                  Text(
                    'Ingresos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCents(report.incomeCents),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(start: _range.start, end: _range.end),
    );

    if (picked != null) {
      setState(() => _range = (start: picked.start, end: picked.end));
    }
  }
}
