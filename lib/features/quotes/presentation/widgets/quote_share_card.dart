import 'package:flutter/material.dart';
import 'package:orbit_rooms/features/quotes/domain/quote_pricing.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _formatShortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// Reproduce (y mejora visualmente) la tabla que la administradora arma a
/// mano hoy (ver docs/DECISIONS.md, caso real Hospedaje Shejiná): pensada
/// para convertirse en una imagen y enviarse por WhatsApp, no para verse
/// dentro de la app — por eso usa colores fijos (no `Theme.of(context)`),
/// para que se vea igual sin importar el tema del dispositivo de quien la
/// recibe.
class QuoteShareCard extends StatelessWidget {
  const QuoteShareCard({
    super.key,
    required this.propertyName,
    required this.roomName,
    required this.guestName,
    required this.nights,
    required this.adultsCount,
    required this.totalCents,
    required this.depositCents,
    required this.balanceCents,
    required this.currency,
    this.notes,
    this.showBrand = false,
  });

  final String propertyName;
  final String roomName;
  final String? guestName;
  final List<QuoteNight> nights;
  final int adultsCount;
  final int totalCents;
  final int depositCents;
  final int balanceCents;
  final String currency;
  final String? notes;

  /// Solo tiene sentido para la propiedad propia del usuario — muestra el
  /// logo del hostal en la imagen (ver docs/DECISIONS.md).
  final bool showBrand;

  static const _pageBg = Color(0xFFF2F0EA);
  static const _navy = Color(0xFF10203F);
  static const _gold = Color(0xFFCBA135);
  static const _goldLight = Color(0xFFF3E7C5);
  static const _rowAlt = Color(0xFFF6F6F8);
  static const _borderColor = Color(0xFFE1E1E6);
  static const _greenBg = Color(0xFFE4F5E8);
  static const _greenText = Color(0xFF1E7B3C);

  TableRow _dataRow(
    List<String> cells, {
    Color? background,
    Color textColor = Colors.black87,
    bool bold = false,
    double fontSize = 13,
  }) {
    return TableRow(
      decoration: BoxDecoration(color: background),
      children: [
        for (final cell in cells)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            child: Text(
              cell,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _statBox({
    required String label,
    required int cents,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatCents(cents, currency),
            style: TextStyle(
              color: foreground,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleTile(IconData icon, String label, String time) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _navy),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _pageBg,
      padding: const EdgeInsets.all(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showBrand)
                Container(
                  width: double.infinity,
                  color: _navy,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_shejina.webp',
                      height: 76,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      propertyName,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Habitación $roomName',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    if (nights.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatDate(nights.first.date)}  →  '
                            '${_formatDate(nights.last.date.add(const Duration(days: 1)))}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (guestName != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _goldLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          guestName!,
                          style: const TextStyle(
                            color: _navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Table(
                        border: TableBorder.symmetric(
                          inside: BorderSide(color: _borderColor),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(1.3),
                          2: FlexColumnWidth(0.8),
                          3: FlexColumnWidth(1.3),
                        },
                        children: [
                          _dataRow(
                            ['Fecha', 'Valor', 'Pers.', 'Total'],
                            background: _navy,
                            textColor: Colors.white,
                            bold: true,
                            fontSize: 12,
                          ),
                          for (var i = 0; i < nights.length; i++) ...[
                            _dataRow([
                              _formatShortDate(nights[i].date),
                              formatCents(nights[i].adultsRateCents, currency),
                              '$adultsCount',
                              formatCents(
                                nights[i].adultsRateCents * adultsCount,
                                currency,
                              ),
                            ], background: i.isEven ? Colors.white : _rowAlt),
                            for (final child in nights[i].children)
                              _dataRow(
                                [
                                  child.group.count == 1 ? 'niño' : 'niños',
                                  formatCents(child.rateCents, currency),
                                  '${child.group.count}',
                                  formatCents(
                                    child.rateCents * child.group.count,
                                    currency,
                                  ),
                                ],
                                background: i.isEven ? Colors.white : _rowAlt,
                                textColor: Colors.black54,
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              color: _navy,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            formatCents(totalCents, currency),
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (notes != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _goldLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(color: _gold, width: 3),
                          ),
                        ),
                        child: Text(
                          notes!,
                          style: const TextStyle(
                            color: _navy,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _statBox(
                            label: 'ABONO PARA LA RESERVA',
                            cents: depositCents,
                            background: _greenBg,
                            foreground: _greenText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statBox(
                            label: 'SALDO',
                            cents: balanceCents,
                            background: _rowAlt,
                            foreground: _navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'El saldo se cancela en el check-in.',
                      style: TextStyle(color: Colors.black45, fontSize: 11),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _rowAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _scheduleTile(
                              Icons.login,
                              'Check-in',
                              '14:00',
                            ),
                          ),
                          Container(width: 1, height: 32, color: _borderColor),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _scheduleTile(
                              Icons.logout,
                              'Check-out',
                              '11:00',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
