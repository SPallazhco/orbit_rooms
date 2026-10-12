import 'package:flutter/material.dart';
import 'package:orbit_rooms/features/dashboard/dashboard_providers.dart';
import 'package:orbit_rooms/shared/utils/format_money.dart';

/// Lista de llegadas o salidas del día: cada fila muestra quién es, en qué
/// habitaciones, cuántas personas y cuánto saldo queda por cobrar.
class MovementsCard extends StatelessWidget {
  const MovementsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.emptyMessage,
    required this.movements,
    required this.currency,
    required this.onTap,
    this.footnote,
  });

  final String title;
  final IconData icon;
  final String emptyMessage;
  final List<DashboardMovement> movements;
  final String currency;
  final void Function(String reservationId) onTap;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(icon, color: scheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title, style: textTheme.titleMedium)),
                  if (movements.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${movements.length}',
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (movements.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  emptyMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            for (final movement in movements)
              _MovementTile(
                movement: movement,
                currency: currency,
                onTap: () => onTap(movement.reservation.id),
              ),
            if (footnote != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  footnote!,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({
    required this.movement,
    required this.currency,
    required this.onTap,
  });

  final DashboardMovement movement;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final initial = movement.guestName.trim().isEmpty
        ? '?'
        : movement.guestName.trim()[0].toUpperCase();
    final hasBalance = movement.balanceCents > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paidColor = isDark ? Colors.green.shade300 : Colors.green.shade800;

    final details = [
      if (movement.roomNames.isNotEmpty) 'Hab. ${movement.roomNames}',
      '${movement.guestsCount} ${movement.guestsCount == 1 ? 'persona' : 'personas'}',
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
              child: Text(initial),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movement.guestName,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    details,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: hasBalance
                    ? scheme.errorContainer
                    : paidColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                hasBalance
                    ? 'Saldo ${formatCents(movement.balanceCents, currency)}'
                    : 'Pagado',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasBalance ? scheme.onErrorContainer : paidColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
