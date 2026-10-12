import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/features/quotes/domain/quote_list_order.dart';

void main() {
  final now = DateTime(2026, 10, 10, 15, 30);

  test('las próximas van primero (la más cercana arriba) y las pasadas '
      'después (la más reciente arriba)', () {
    final dates = [
      DateTime(2026, 11, 5),
      DateTime(2026, 10, 1),
      DateTime(2026, 10, 10),
      DateTime(2026, 9, 20),
      DateTime(2026, 10, 12),
    ];

    final result = splitUpcomingAndPast<DateTime>(dates, (d) => d, now);

    expect(result.upcoming, [
      DateTime(2026, 10, 10),
      DateTime(2026, 10, 12),
      DateTime(2026, 11, 5),
    ]);
    expect(result.past, [DateTime(2026, 10, 1), DateTime(2026, 9, 20)]);
  });

  test('un check-in de hoy cuenta como próximo aunque ya haya pasado la '
      'hora', () {
    final result = splitUpcomingAndPast<DateTime>(
      [DateTime(2026, 10, 10)],
      (d) => d,
      now,
    );

    expect(result.upcoming, hasLength(1));
    expect(result.past, isEmpty);
  });

  test('daysUntil cuenta días calendario', () {
    expect(daysUntil(DateTime(2026, 10, 10), now), 0);
    expect(daysUntil(DateTime(2026, 10, 11), now), 1);
    expect(daysUntil(DateTime(2026, 10, 9), now), -1);
  });
}
