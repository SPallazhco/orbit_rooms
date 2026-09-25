import 'package:flutter/material.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Reproduce la tabla que la administradora arma a mano hoy (ver
/// docs/DECISIONS.md, caso real Hospedaje Shejiná): pensada para
/// convertirse en una imagen y enviarse por WhatsApp, no para verse dentro
/// de la app — por eso usa colores fijos (blanco/negro) en vez de
/// `Theme.of(context)`, para que se vea igual sin importar el tema del
/// dispositivo de quien la recibe.
class QuoteShareCard extends StatelessWidget {
  const QuoteShareCard({
    super.key,
    required this.propertyName,
    required this.roomName,
    required this.guestName,
    required this.dayLines,
    required this.adultsCount,
    required this.childrenCount,
    required this.totalCents,
    required this.depositCents,
    required this.balanceCents,
    required this.currency,
    this.notes,
  });

  final String propertyName;
  final String roomName;
  final String? guestName;
  final List<QuoteDayLine> dayLines;
  final int adultsCount;
  final int childrenCount;
  final int totalCents;
  final int depositCents;
  final int balanceCents;
  final String currency;
  final String? notes;

  static const _borderColor = Color(0xFFBBBBBB);
  static const _headerColor = Color(0xFF6FD1E8);
  static const _depositColor = Color(0xFF7ED957);

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
          Text(
            propertyName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            roomName,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          if (guestName != null) ...[
            const SizedBox(height: 4),
            Text(
              guestName!,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ],
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: _borderColor),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.4),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1.4),
            },
            children: [
              _row(
                ['', 'Valor por persona', 'Personas', 'Valor por día'],
                background: _headerColor,
                bold: true,
              ),
              for (final line in dayLines) ...[
                _row([
                  _formatDate(line.date),
                  formatCents(line.adultsRateCents, currency),
                  '$adultsCount',
                  formatCents(line.adultsRateCents * adultsCount, currency),
                ]),
                if (childrenCount > 0)
                  _row([
                    '${_formatDate(line.date)} niños',
                    formatCents(line.childrenRateCents, currency),
                    '$childrenCount',
                    formatCents(
                      line.childrenRateCents * childrenCount,
                      currency,
                    ),
                  ]),
              ],
              _row(
                ['', '', 'TOTAL', formatCents(totalCents, currency)],
                background: _headerColor,
                bold: true,
              ),
            ],
          ),
          if (notes != null) ...[
            const SizedBox(height: 12),
            Text(
              notes!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: _borderColor),
            children: [
              _row(
                [
                  'ABONO PARA LA RESERVACIÓN',
                  formatCents(depositCents, currency),
                  'SALDO',
                  formatCents(balanceCents, currency),
                ],
                background: _depositColor,
                bold: true,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'El saldo se cancela en el check-in.',
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Text(
            'Check-in (registro de entrada): 14:00\n'
            'Check-out (registro de salida): 11:00',
            style: TextStyle(color: Colors.black, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
