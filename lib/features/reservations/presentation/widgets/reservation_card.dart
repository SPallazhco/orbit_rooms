import 'package:flutter/material.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/reservations/domain/reservation_timeline.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';
import 'package:orbit_rooms/shared/utils/reservation_status_label.dart';
import 'package:orbit_rooms/shared/utils/spanish_dates.dart';

/// Tarjeta de la lista de reservas: quién, dónde, cuándo, cuánto y qué falta
/// por cobrar, sin abrir cada una.
class ReservationCard extends StatelessWidget {
  const ReservationCard({
    super.key,
    required this.item,
    required this.currency,
    required this.onTap,
  });

  final ReservationListItem item;
  final String currency;
  final VoidCallback onTap;

  Color _phaseColor(ColorScheme scheme) => switch (item.phase) {
    ReservationPhase.inHouse => scheme.primary,
    ReservationPhase.upcoming => scheme.secondary,
    ReservationPhase.past => scheme.outline,
    ReservationPhase.cancelled => scheme.error,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reservation = item.reservation;
    final color = _phaseColor(scheme);
    final nights = reservation.checkOutDate
        .difference(reservation.checkInDate)
        .inDays;
    final timing = reservationTimingLabel(reservation, DateTime.now());
    final cancelled = item.phase == ReservationPhase.cancelled;

    final details = [
      if (item.roomNames.isNotEmpty) 'Hab. ${item.roomNames}',
      if (item.guestsCount > 0)
        '${item.guestsCount} ${item.guestsCount == 1 ? 'persona' : 'personas'}',
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: color),
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
                              item.guestName,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: cancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatCents(reservation.totalPriceCents, currency),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cancelled
                                  ? scheme.onSurfaceVariant
                                  : scheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          details,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                              '${formatShortDate(reservation.checkInDate)} → '
                              '${formatShortDate(reservation.checkOutDate)} · '
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
                          if (timing != null)
                            _Pill(
                              label: timing,
                              background: color.withValues(alpha: 0.14),
                              foreground: color,
                            ),
                          if (!cancelled) _paymentPill(context),
                          if (item.phase == ReservationPhase.cancelled ||
                              reservation.status == ReservationStatus.pending)
                            _Pill(
                              label: reservationStatusLabel(reservation.status),
                              background: scheme.surfaceContainerHighest,
                              foreground: scheme.onSurfaceVariant,
                            ),
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

  Widget _paymentPill(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final green = isDark ? Colors.green.shade300 : Colors.green.shade800;
    final balance = balanceCents(item.reservation, item.paidCents);

    if (balance <= 0) {
      return _Pill(
        icon: Icons.check,
        label: 'Pagada',
        background: green.withValues(alpha: 0.16),
        foreground: green,
      );
    }
    final past = item.phase == ReservationPhase.past;
    return _Pill(
      label: item.paidCents == 0
          ? 'Sin abono · ${formatCents(balance, currency)}'
          : 'Saldo ${formatCents(balance, currency)}',
      background: past ? scheme.errorContainer : scheme.secondaryContainer,
      foreground: past ? scheme.onErrorContainer : scheme.onSecondaryContainer,
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
