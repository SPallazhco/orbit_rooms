import 'package:flutter/material.dart';
import 'package:orbit_rooms/features/reports/reports_providers.dart';

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Pensada para convertirse en una imagen y enviarse por WhatsApp al dueño
/// del parqueadero (un tercero, no el dueño de la propiedad) — mismo
/// criterio que `QuoteShareCard`: colores fijos (blanco/negro), no
/// `Theme.of(context)`, para que se vea igual sin importar el tema de quien
/// la recibe.
class GarageReportCard extends StatelessWidget {
  const GarageReportCard({super.key, required this.day, required this.entries});

  final DateTime day;
  final List<GarageEntry> entries;

  static const _borderColor = Color(0xFFBBBBBB);
  static const _headerColor = Color(0xFF6FD1E8);

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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Vehículos registrados',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _formatDate(day),
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Text(
              'Sin vehículos registrados para esta fecha.',
              style: TextStyle(color: Colors.black87),
            )
          else
            Table(
              border: TableBorder.all(color: _borderColor),
              columnWidths: const {
                0: FlexColumnWidth(1.6),
                1: FlexColumnWidth(1.6),
                2: FlexColumnWidth(1),
              },
              children: [
                _row(
                  ['Huésped', 'Casa / Habitación', 'Placa'],
                  background: _headerColor,
                  bold: true,
                ),
                for (final entry in entries)
                  _row([
                    entry.guestName,
                    '${entry.propertyName} — ${entry.roomNames}',
                    entry.plate,
                  ]),
              ],
            ),
        ],
      ),
    );
  }
}
