import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/quotes/domain/quote_pricing.dart';

QuoteDayLine _line(int day, int adultsRate) => QuoteDayLine(
  id: 'l$day',
  quoteId: 'q',
  date: DateTime(2026, 6, day),
  adultsRateCents: adultsRate,
);

QuoteChildGroup _group(String id, int count, int order) =>
    QuoteChildGroup(id: id, quoteId: 'q', count: count, sortOrder: order);

QuoteChildRate _rate(String groupId, int day, int cents) => QuoteChildRate(
  id: '$groupId-$day',
  groupId: groupId,
  date: DateTime(2026, 6, day),
  rateCents: cents,
);

void main() {
  test('el total suma adultos y cada grupo de niños con su propia tarifa '
      'por noche (caso real: 3 niños a 7 y uno a 5)', () {
    final breakdown = buildQuoteBreakdown(
      adultsCount: 6,
      dayLines: [_line(4, 1200), _line(5, 1500)],
      groups: [_group('a', 3, 0), _group('b', 1, 1)],
      rates: [
        _rate('a', 4, 700),
        _rate('b', 4, 500),
        _rate('a', 5, 800),
        _rate('b', 5, 500),
      ],
    );

    expect(breakdown.childrenCount, 4);
    // noche 1: 1200*6 + 3*700 + 1*500 = 9800
    // noche 2: 1500*6 + 3*800 + 1*500 = 11900
    expect(breakdown.nights.map((n) => n.totalCents), [9800, 11900]);
    expect(breakdown.totalCents, 21700);
    expect(breakdown.hasUnpricedChildren, false);
  });

  test('un grupo sin tarifa cargada cuenta como 0 y se marca como niños sin '
      'tarifa', () {
    final breakdown = buildQuoteBreakdown(
      adultsCount: 2,
      dayLines: [_line(4, 1000)],
      groups: [_group('a', 2, 0)],
      rates: const [],
    );

    expect(breakdown.totalCents, 2000);
    expect(breakdown.hasUnpricedChildren, true);
  });

  test('sin niños no hay advertencia y el total es solo de adultos', () {
    final breakdown = buildQuoteBreakdown(
      adultsCount: 3,
      dayLines: [_line(4, 1000)],
      groups: const [],
      rates: const [],
    );

    expect(breakdown.childrenCount, 0);
    expect(breakdown.totalCents, 3000);
    expect(breakdown.hasUnpricedChildren, false);
  });
}
