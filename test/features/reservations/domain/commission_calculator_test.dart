import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/features/reservations/domain/commission_calculator.dart';

void main() {
  group('commissionPerPersonCents', () {
    test('tramo \$10 (menos de \$12), fijo sin importar huéspedes', () {
      expect(commissionPerPersonCents(1000, 1), 250);
      expect(commissionPerPersonCents(1199, 5), 250);
    });

    test('tramo \$12: \$2.50 si es 1 solo huésped, \$3.00 si son más', () {
      expect(commissionPerPersonCents(1200, 1), 250);
      expect(commissionPerPersonCents(1200, 2), 300);
      expect(commissionPerPersonCents(1299, 3), 300);
    });

    test('tramo \$13 (menos de \$15), fijo sin importar huéspedes', () {
      expect(commissionPerPersonCents(1300, 1), 300);
      expect(commissionPerPersonCents(1499, 4), 300);
    });

    test('tramo \$15: \$3.00 si es 1 solo huésped, \$3.50 si son más', () {
      expect(commissionPerPersonCents(1500, 1), 300);
      expect(commissionPerPersonCents(1500, 2), 350);
      expect(commissionPerPersonCents(1799, 3), 350);
    });

    test('tramo \$18 (menos de \$20), fijo sin importar huéspedes', () {
      expect(commissionPerPersonCents(1800, 1), 400);
      expect(commissionPerPersonCents(1999, 4), 400);
    });

    test('tramo \$20 y superior, fijo sin importar huéspedes', () {
      expect(commissionPerPersonCents(2000, 1), 500);
      expect(commissionPerPersonCents(5000, 4), 500);
    });
  });

  group('commissionCentsForNight', () {
    test('caso real del Excel: Lunes 24/8, Norma#2 — 3 huéspedes a \$12, '
        'sin auto, comisión \$9', () {
      final commission = commissionCentsForNight(
        ratePerPersonCents: 1200,
        guestsCount: 3,
        garageFeeCents: 0,
      );

      expect(commission, 900);
    });

    test('caso real del Excel: Martes 25/8, Norma#5 — 2 huéspedes a \$12, '
        'con un auto de \$3.50 de garaje, comisión \$5', () {
      final commission = commissionCentsForNight(
        ratePerPersonCents: 1200,
        guestsCount: 2,
        garageFeeCents: 350,
      );

      expect(commission, 500);
    });

    test('sin auto, garageFeeCents en 0 no cambia el ingreso', () {
      final commission = commissionCentsForNight(
        ratePerPersonCents: 1500,
        guestsCount: 1,
        garageFeeCents: 0,
      );

      expect(commission, 300);
    });

    test('un garaje que superaría el ingreso no da comisión negativa', () {
      final commission = commissionCentsForNight(
        ratePerPersonCents: 1000,
        guestsCount: 1,
        garageFeeCents: 5000,
      );

      expect(commission, 250);
    });
  });
}
