import 'package:flutter/material.dart';
import 'package:orbit_rooms/features/reports/reports_providers.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Pensada para convertirse en una imagen y enviarse a la dueña de la casa
/// administrada (ej. Norma) para que sepa cuánto transferir — mismo
/// criterio que `QuoteShareCard`/`GarageReportCard`: colores fijos
/// (blanco/negro), no `Theme.of(context)`.
class CommissionReportCard extends StatelessWidget {
  const CommissionReportCard({
    super.key,
    required this.propertyName,
    required this.start,
    required this.end,
    required this.entries,
    required this.currency,
  });

  final String propertyName;
  final DateTime start;
  final DateTime end;
  final List<CommissionEntry> entries;
  final String currency;

  static const _borderColor = Color(0xFFBBBBBB);
  static const _headerColor = Color(0xFF6FD1E8);
  static const _totalColor = Color(0xFF7ED957);

  TableRow _row(List<String> cells, {Color? background, bool bold = false}) {
    return TableRow(
      decoration: BoxDecoration(color: background),
      children: [
        for (final cell in cells)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              cell,
              style: TextStyle(
                color: Colors.black,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCents = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.commissionCents,
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Comisión — $propertyName',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_formatDate(start)} — ${_formatDate(end)}',
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Text(
              'Sin huéspedes enviados en este rango de fechas.',
              style: TextStyle(color: Colors.black87),
            )
          else ...[
            Table(
              border: TableBorder.all(color: _borderColor),
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.6),
                2: FlexColumnWidth(0.8),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                _row(
                  ['Fecha', 'Habitación', 'Hués.', 'Ingreso', 'Comisión'],
                  background: _headerColor,
                  bold: true,
                ),
                for (final entry in entries)
                  _row([
                    _formatDate(entry.date),
                    entry.roomName,
                    '${entry.guestsCount}',
                    formatCents(entry.revenueCents, currency),
                    formatCents(entry.commissionCents, currency),
                  ]),
              ],
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: _borderColor),
              children: [
                _row(
                  ['TOTAL A COBRAR', formatCents(totalCents, currency)],
                  background: _totalColor,
                  bold: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
