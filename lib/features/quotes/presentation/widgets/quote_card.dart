import 'package:flutter/material.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/quotes/domain/quote_list_order.dart';
import 'package:orbit_rooms/features/quotes/presentation/quote_status_label.dart';
import 'package:orbit_rooms/features/quotes/presentation/quote_title.dart';
import 'package:orbit_rooms/features/quotes/quotes_providers.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';
import 'package:orbit_rooms/shared/utils/spanish_dates.dart';

/// Tarjeta de la lista de cotizaciones: lo que la administradora necesita
/// para decidir a quién escribirle primero — quién, cuándo llega, cuánto es
/// y en qué estado está — sin abrir cada una.
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    required this.propertyName,
    required this.roomName,
    required this.summary,
    required this.currency,
    required this.onTap,
  });

  final Quote quote;
  final String propertyName;
  final String roomName;
  final QuoteSummary summary;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = quoteStatusColor(context, quote.status);
    final nights = quote.checkOutDate.difference(quote.checkInDate).inDays;
    final title = quoteTitle(
      guestName: quote.guestName,
      checkInDate: quote.checkInDate,
      adultsCount: quote.adultsCount,
      childrenCount: summary.childrenCount,
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatCents(summary.totalCents, currency),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$propertyName · Hab. $roomName',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${formatShortDate(quote.checkInDate)} → '
                              '${formatShortDate(quote.checkOutDate)} · '
                              '$nights ${nights == 1 ? 'noche' : 'noches'}',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _Pill(
                            label: quoteStatusLabel(quote.status),
                            background: statusColor.withValues(alpha: 0.14),
                            foreground: statusColor,
                          ),
                          if (quote.status == QuoteStatus.pending)
                            _urgencyPill(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _urgencyPill(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = daysUntil(quote.checkInDate, DateTime.now());

    if (days < 0) {
      return _Pill(
        label: 'Fecha pasada',
        background: scheme.surfaceContainerHighest,
        foreground: scheme.onSurfaceVariant,
      );
    }
    final label = switch (days) {
      0 => 'Llega hoy',
      1 => 'Llega mañana',
      _ => 'Llega en $days días',
    };
    final urgent = days <= 3;
    return _Pill(
      icon: urgent ? Icons.schedule : null,
      label: label,
      background: urgent
          ? scheme.errorContainer
          : scheme.surfaceContainerHighest,
      foreground: urgent ? scheme.onErrorContainer : scheme.onSurfaceVariant,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
