import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Dona de ocupación: un solo arco (ocupadas) sobre un anillo de fondo
/// (libres). Dibujada con `CustomPaint` porque con un solo valor no
/// justifica sumar un paquete de gráficos.
class OccupancyDonut extends StatelessWidget {
  const OccupancyDonut({
    super.key,
    required this.occupied,
    required this.total,
    this.size = 150,
  });

  final int occupied;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fraction = total == 0 ? 0.0 : (occupied / total).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _DonutPainter(
            fraction: value,
            trackColor: scheme.surfaceContainerHighest,
            arcColor: scheme.primary,
            strokeWidth: size * 0.14,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(fraction * 100).round()}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'ocupación',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.fraction,
    required this.trackColor,
    required this.arcColor,
    required this.strokeWidth,
  });

  final double fraction;
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    if (fraction <= 0) return;
    final arc = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * fraction, false, arc);
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.fraction != fraction ||
      old.trackColor != trackColor ||
      old.arcColor != arcColor;
}
