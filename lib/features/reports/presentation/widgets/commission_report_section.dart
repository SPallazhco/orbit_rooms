import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/properties/properties_providers.dart';
import 'package:orbit_rooms/features/reports/presentation/pages/commission_report_preview_page.dart';
import 'package:orbit_rooms/features/reports/presentation/widgets/report_section_card.dart';
import 'package:orbit_rooms/features/reports/reports_providers.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';
import 'package:orbit_rooms/shared/utils/spanish_dates.dart';

enum _Period { thisWeek, lastWeek, thisMonth, lastMonth, custom }

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _periodLabel(_Period p) => switch (p) {
  _Period.thisWeek => 'Esta semana',
  _Period.lastWeek => 'Semana pasada',
  _Period.thisMonth => 'Este mes',
  _Period.lastMonth => 'Mes pasado',
  _Period.custom => 'Otro rango',
};

/// Semanas de lunes a domingo (así se arma el Excel semanal). Los períodos
/// en curso se cortan en hoy: no se cobra comisión de noches que todavía no
/// pasaron.
DateRange _rangeFor(_Period period, DateTime today, DateRange custom) {
  final monday = today.subtract(Duration(days: today.weekday - 1));
  DateTime capAtToday(DateTime d) => d.isAfter(today) ? today : d;

  return switch (period) {
    _Period.thisWeek => (start: monday, end: today),
    _Period.lastWeek => (
      start: monday.subtract(const Duration(days: 7)),
      end: monday.subtract(const Duration(days: 1)),
    ),
    _Period.thisMonth => (
      start: DateTime(today.year, today.month),
      end: capAtToday(DateTime(today.year, today.month + 1, 0)),
    ),
    _Period.lastMonth => (
      start: DateTime(today.year, today.month - 1),
      end: DateTime(today.year, today.month, 0),
    ),
    _Period.custom => custom,
  };
}

class CommissionReportSection extends ConsumerStatefulWidget {
  const CommissionReportSection({super.key});

  @override
  ConsumerState<CommissionReportSection> createState() =>
      _CommissionReportSectionState();
}

class _CommissionReportSectionState
    extends ConsumerState<CommissionReportSection> {
  _Period _period = _Period.lastWeek;
  late DateRange _customRange = (
    start: _dateOnly(DateTime.now()),
    end: _dateOnly(DateTime.now()),
  );
  String? _propertyId;

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(activePropertiesProvider);
    final currency = ref.watch(currencyProvider).value ?? 'USD';
    final today = _dateOnly(DateTime.now());
    final range = _rangeFor(_period, today, _customRange);

    return ReportSectionCard(
      icon: Icons.request_quote_rounded,
      title: 'Comisión',
      subtitle: 'Lo que te debe una casa administrada por sus huéspedes',
      child: propertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('Error: $error'),
        data: (properties) {
          if (properties.isEmpty) {
            return const ReportEmptyState(
              message: 'Todavía no tienes propiedades.',
            );
          }
          final propertyId =
              (_propertyId != null &&
                  properties.any((p) => p.id == _propertyId))
              ? _propertyId!
              : properties.first.id;
          final propertyName = properties
              .firstWhere((p) => p.id == propertyId)
              .name;

          final commissionAsync = ref.watch(
            commissionReportProvider((
              propertyId: propertyId,
              start: range.start,
              end: range.end,
            )),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: propertyId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Casa',
                  prefixIcon: Icon(Icons.home_work_outlined),
                  border: OutlineInputBorder(),
                ),
                items: properties
                    .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _propertyId = value),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final period in _Period.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: period == _Period.custom
                              ? const Icon(Icons.date_range, size: 16)
                              : null,
                          label: Text(_periodLabel(period)),
                          selected: _period == period,
                          onSelected: (_) => period == _Period.custom
                              ? _pickRange(context)
                              : setState(() => _period = period),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${formatShortDate(range.start)} – ${formatShortDate(range.end)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              commissionAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Error: $error'),
                data: (entries) => _CommissionSummary(
                  propertyName: propertyName,
                  range: range,
                  entries: entries,
                  currency: currency,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final current = _rangeFor(_period, _dateOnly(now), _customRange);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(start: current.start, end: current.end),
    );

    if (picked != null) {
      setState(() {
        _customRange = (
          start: _dateOnly(picked.start),
          end: _dateOnly(picked.end),
        );
        _period = _Period.custom;
      });
    }
  }
}

class _CommissionSummary extends StatelessWidget {
  const _CommissionSummary({
    required this.propertyName,
    required this.range,
    required this.entries,
    required this.currency,
  });

  final String propertyName;
  final DateRange range;
  final List<CommissionEntry> entries;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (entries.isEmpty) {
      return ReportEmptyState(
        message: 'Sin noches de huéspedes en $propertyName en este período.',
      );
    }

    final commissionCents = entries.fold<int>(
      0,
      (sum, e) => sum + e.commissionCents,
    );
    final revenueCents = entries.fold<int>(0, (sum, e) => sum + e.revenueCents);
    final garageCents = entries.fold<int>(
      0,
      (sum, e) => sum + e.garageFeeCents,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comisión a cobrar',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatCents(commissionCents, currency),
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Stat(label: 'Noches', value: '${entries.length}'),
            ),
            Expanded(
              child: _Stat(
                label: 'Cobró la casa',
                value: formatCents(revenueCents, currency),
              ),
            ),
            Expanded(
              child: _Stat(
                label: 'Garaje',
                value: formatCents(garageCents, currency),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CommissionReportPreviewPage(
                  propertyName: propertyName,
                  start: range.start,
                  end: range.end,
                  entries: entries,
                  currency: currency,
                ),
              ),
            ),
            icon: const Icon(Icons.ios_share),
            label: const Text('Ver detalle y compartir'),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
