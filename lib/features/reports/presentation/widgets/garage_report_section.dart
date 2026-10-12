import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/features/reports/presentation/pages/garage_report_preview_page.dart';
import 'package:orbit_rooms/features/reports/presentation/widgets/report_section_card.dart';
import 'package:orbit_rooms/features/reports/reports_providers.dart';
import 'package:orbit_rooms/shared/utils/spanish_dates.dart';

const _previewLimit = 4;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class GarageReportSection extends ConsumerStatefulWidget {
  const GarageReportSection({super.key});

  @override
  ConsumerState<GarageReportSection> createState() =>
      _GarageReportSectionState();
}

class _GarageReportSectionState extends ConsumerState<GarageReportSection> {
  DateTime _day = _dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final isToday = _day == today;
    final isTomorrow = _day == tomorrow;
    final garageAsync = ref.watch(garageReportProvider(_day));

    return ReportSectionCard(
      icon: Icons.local_parking_rounded,
      title: 'Garaje',
      subtitle: 'Autos que pasan la noche, para avisar al parqueadero',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('Hoy'),
                selected: isToday,
                onSelected: (_) => setState(() => _day = today),
              ),
              ChoiceChip(
                label: const Text('Mañana'),
                selected: isTomorrow,
                onSelected: (_) => setState(() => _day = tomorrow),
              ),
              ChoiceChip(
                avatar: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  isToday || isTomorrow ? 'Otra fecha' : formatShortDate(_day),
                ),
                selected: !isToday && !isTomorrow,
                onSelected: (_) => _pickDay(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          garageAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
            data: (entries) => _GarageSummary(day: _day, entries: entries),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDay(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => _day = _dateOnly(picked));
    }
  }
}

class _GarageSummary extends StatelessWidget {
  const _GarageSummary({required this.day, required this.entries});

  final DateTime day;
  final List<GarageEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final count = entries.length;

    if (entries.isEmpty) {
      return ReportEmptyState(
        message:
            'No hay autos registrados la noche del ${formatLongDate(day).toLowerCase()}.',
      );
    }

    final shown = entries.take(_previewLimit).toList();
    final hidden = count - shown.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$count',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${count == 1 ? 'auto' : 'autos'} · ${formatLongDate(day)}',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final entry in shown) _PlateRow(entry: entry),
        if (hidden > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'y $hidden más en el reporte',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    GarageReportPreviewPage(day: day, entries: entries),
              ),
            ),
            icon: const Icon(Icons.ios_share),
            label: const Text('Ver y compartir'),
          ),
        ),
      ],
    );
  }
}

class _PlateRow extends StatelessWidget {
  const _PlateRow({required this.entry});

  final GarageEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outline, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              entry.plate,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.guestName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.propertyName} · Hab. ${entry.roomNames}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
