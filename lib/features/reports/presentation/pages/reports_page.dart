import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/properties/properties_providers.dart';
import 'package:orbit_rooms/features/reports/presentation/pages/commission_report_preview_page.dart';
import 'package:orbit_rooms/features/reports/presentation/pages/garage_report_preview_page.dart';
import 'package:orbit_rooms/features/reports/reports_providers.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

DateTime _startOfMonth(DateTime d) => DateTime(d.year, d.month);

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

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
  DateTime _garageDay = _dateOnly(DateTime.now());
  late DateRange _commissionRange = (
    start: _startOfMonth(DateTime.now()),
    end: DateTime.now(),
  );
  String? _commissionPropertyId;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(reportDataProvider(_range));
    final garageAsync = ref.watch(garageReportProvider(_garageDay));
    final propertiesAsync = ref.watch(activePropertiesProvider);
    final currency = ref.watch(currencyProvider).value ?? 'USD';

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
                    formatCents(report.incomeCents, currency),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              );
            },
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reporte de garaje',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => _pickGarageDay(context),
                child: Text(_formatDate(_garageDay)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          garageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
            data: (entries) => OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GarageReportPreviewPage(
                    day: _garageDay,
                    entries: entries,
                  ),
                ),
              ),
              icon: const Icon(Icons.local_parking_outlined),
              label: Text('Compartir con el parqueadero (${entries.length})'),
            ),
          ),
          const Divider(height: 32),
          Text(
            'Reporte de comisión',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          propertiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
            data: (properties) {
              if (properties.isEmpty) {
                return const Text('Todavía no tienes propiedades');
              }
              final propertyId =
                  (_commissionPropertyId != null &&
                      properties.any((p) => p.id == _commissionPropertyId))
                  ? _commissionPropertyId!
                  : properties.first.id;
              final propertyName = properties
                  .firstWhere((p) => p.id == propertyId)
                  .name;

              final commissionAsync = ref.watch(
                commissionReportProvider((
                  propertyId: propertyId,
                  start: _commissionRange.start,
                  end: _commissionRange.end,
                )),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: propertyId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Propiedad'),
                    items: properties
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _commissionPropertyId = value),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatDate(_commissionRange.start)} - '
                        '${_formatDate(_commissionRange.end)}',
                      ),
                      TextButton(
                        onPressed: () => _pickCommissionRange(context),
                        child: const Text('Elegir rango'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  commissionAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text('Error: $error'),
                    data: (entries) {
                      final totalCents = entries.fold<int>(
                        0,
                        (sum, e) => sum + e.commissionCents,
                      );
                      return OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CommissionReportPreviewPage(
                              propertyName: propertyName,
                              start: _commissionRange.start,
                              end: _commissionRange.end,
                              entries: entries,
                              currency: currency,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.request_quote_outlined),
                        label: Text(
                          'Ver comisión de $propertyName '
                          '(${formatCents(totalCents, currency)})',
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickGarageDay(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _garageDay,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => _garageDay = _dateOnly(picked));
    }
  }

  Future<void> _pickCommissionRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: _commissionRange.start,
        end: _commissionRange.end,
      ),
    );

    if (picked != null) {
      setState(() => _commissionRange = (start: picked.start, end: picked.end));
    }
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
