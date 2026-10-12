import 'package:orbit_rooms/core/database/app_database.dart';

class QuoteNightChildRate {
  const QuoteNightChildRate({required this.group, required this.rateCents});

  final QuoteChildGroup group;
  final int rateCents;
}

class QuoteNight {
  const QuoteNight({
    required this.line,
    required this.adultsCount,
    required this.children,
  });

  final QuoteDayLine line;
  final int adultsCount;
  final List<QuoteNightChildRate> children;

  DateTime get date => line.date;

  int get adultsRateCents => line.adultsRateCents;

  int get totalCents =>
      line.adultsRateCents * adultsCount +
      children.fold(0, (sum, c) => sum + c.rateCents * c.group.count);
}

/// Desglose completo de una cotización: el total no se guarda como columna
/// (no puede desincronizarse si se edita una noche), se arma siempre desde
/// las líneas por noche + grupos de niños + tarifas por grupo y noche.
class QuoteBreakdown {
  const QuoteBreakdown({
    required this.adultsCount,
    required this.groups,
    required this.nights,
  });

  final int adultsCount;
  final List<QuoteChildGroup> groups;
  final List<QuoteNight> nights;

  int get childrenCount => groups.fold(0, (sum, g) => sum + g.count);

  int get totalCents => nights.fold(0, (sum, n) => sum + n.totalCents);

  /// Hay niños que hoy se cobran gratis en alguna noche — casi siempre es
  /// una tarifa que todavía no se cargó, no una cortesía.
  bool get hasUnpricedChildren => nights.any(
    (night) => night.children.any((c) => c.rateCents == 0 && c.group.count > 0),
  );
}

QuoteBreakdown buildQuoteBreakdown({
  required int adultsCount,
  required List<QuoteDayLine> dayLines,
  required List<QuoteChildGroup> groups,
  required List<QuoteChildRate> rates,
}) {
  final sortedGroups = [...groups]
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  final rateByGroupAndDate = {
    for (final r in rates) (r.groupId, r.date): r.rateCents,
  };

  return QuoteBreakdown(
    adultsCount: adultsCount,
    groups: sortedGroups,
    nights: [
      for (final line in dayLines)
        QuoteNight(
          line: line,
          adultsCount: adultsCount,
          children: [
            for (final group in sortedGroups)
              QuoteNightChildRate(
                group: group,
                rateCents: rateByGroupAndDate[(group.id, line.date)] ?? 0,
              ),
          ],
        ),
    ],
  );
}
