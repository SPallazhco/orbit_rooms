import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/features/quotes/presentation/quote_title.dart';

void main() {
  final now = DateTime(2026, 10, 10);

  test('con nombre: nombre - fecha - adultos y niños', () {
    expect(
      quoteTitle(
        guestName: 'Ana',
        checkInDate: DateTime(2026, 10, 27),
        adultsCount: 6,
        childrenCount: 2,
        now: now,
      ),
      'Ana - 27/10 - 6 adultos, 2 niños',
    );
  });

  test('sin nombre (nulo o vacío) arranca por la fecha', () {
    for (final name in [null, '', '   ']) {
      expect(
        quoteTitle(
          guestName: name,
          checkInDate: DateTime(2026, 10, 27),
          adultsCount: 6,
          childrenCount: 2,
          now: now,
        ),
        '27/10 - 6 adultos, 2 niños',
      );
    }
  });

  test('sin niños no los menciona y usa singular cuando corresponde', () {
    expect(
      quoteTitle(
        checkInDate: DateTime(2026, 3, 5),
        adultsCount: 1,
        childrenCount: 0,
        now: now,
      ),
      '05/03 - 1 adulto',
    );
    expect(
      quoteTitle(
        checkInDate: DateTime(2026, 3, 5),
        adultsCount: 2,
        childrenCount: 1,
        now: now,
      ),
      '05/03 - 2 adultos, 1 niño',
    );
  });

  test('el año aparece solo si no es el actual', () {
    expect(
      quoteTitle(
        checkInDate: DateTime(2027, 1, 2),
        adultsCount: 2,
        childrenCount: 0,
        now: now,
      ),
      '02/01/2027 - 2 adultos',
    );
  });
}
