import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/features/reservations/domain/reservation_pricing.dart';

void main() {
  group('calculateSubtotalCents', () {
    test('cobra tarifa entre semana para lunes', () {
      final subtotal = calculateSubtotalCents(
        ratePerPersonWeekdayCents: 1200,
        ratePerPersonWeekendCents: 1500,
        ratePerPersonHolidayCents: 2000,
        checkInDate: DateTime(2026, 6, 1), // lunes
        checkOutDate: DateTime(2026, 6, 2),
        guestsCount: 1,
      );

      expect(subtotal, 1200);
    });

    test('cobra tarifa fin de semana para viernes, sábado y domingo', () {
      final subtotal = calculateSubtotalCents(
        ratePerPersonWeekdayCents: 1200,
        ratePerPersonWeekendCents: 1500,
        ratePerPersonHolidayCents: 2000,
        checkInDate: DateTime(2026, 6, 5), // viernes
        checkOutDate: DateTime(2026, 6, 8), // lunes (excluido)
        guestsCount: 1,
      );

      expect(subtotal, 1500 * 3);
    });

    test('multiplica por la cantidad de personas', () {
      final subtotal = calculateSubtotalCents(
        ratePerPersonWeekdayCents: 1200,
        ratePerPersonWeekendCents: 1500,
        ratePerPersonHolidayCents: 2000,
        checkInDate: DateTime(2026, 6, 1),
        checkOutDate: DateTime(2026, 6, 2),
        guestsCount: 5,
      );

      expect(subtotal, 1200 * 5);
    });

    test('mezcla noches entre semana y fin de semana', () {
      final subtotal = calculateSubtotalCents(
        ratePerPersonWeekdayCents: 1200,
        ratePerPersonWeekendCents: 1500,
        ratePerPersonHolidayCents: 2000,
        checkInDate: DateTime(2026, 6, 4), // jueves
        checkOutDate: DateTime(2026, 6, 7), // domingo (excluido)
        guestsCount: 2,
      );

      // jueves (entre semana) + viernes + sábado (fin de semana)
      expect(subtotal, (1200 * 2) + (1500 * 2) + (1500 * 2));
    });

    test('una estadía de 0 noches no cobra nada', () {
      final subtotal = calculateSubtotalCents(
        ratePerPersonWeekdayCents: 1200,
        ratePerPersonWeekendCents: 1500,
        ratePerPersonHolidayCents: 2000,
        checkInDate: DateTime(2026, 6, 1),
        checkOutDate: DateTime(2026, 6, 1),
        guestsCount: 3,
      );

      expect(subtotal, 0);
    });

    test(
      'un feriado entre semana cobra tarifa de feriado, no de entre semana',
      () {
        final subtotal = calculateSubtotalCents(
          ratePerPersonWeekdayCents: 1200,
          ratePerPersonWeekendCents: 1500,
          ratePerPersonHolidayCents: 2000,
          checkInDate: DateTime(2026, 6, 1), // lunes
          checkOutDate: DateTime(2026, 6, 2),
          guestsCount: 1,
          holidayDates: {DateTime(2026, 6, 1)},
        );

        expect(subtotal, 2000);
      },
    );

    test('un feriado que cae en fin de semana cobra tarifa de feriado, no de '
        'fin de semana', () {
      final subtotal = calculateSubtotalCents(
        ratePerPersonWeekdayCents: 1200,
        ratePerPersonWeekendCents: 1500,
        ratePerPersonHolidayCents: 2000,
        checkInDate: DateTime(2026, 6, 6), // sábado
        checkOutDate: DateTime(2026, 6, 7),
        guestsCount: 1,
        holidayDates: {DateTime(2026, 6, 6)},
      );

      expect(subtotal, 2000);
    });
  });

  group('dayRatesForStay', () {
    test('devuelve una línea por noche con la tarifa que corresponde a cada '
        'una (usada por Quotes para el desglose día por día)', () {
      final rates = dayRatesForStay(
        ratePerPersonWeekdayCents: 1200,
        ratePerPersonWeekendCents: 1500,
        ratePerPersonHolidayCents: 2000,
        checkInDate: DateTime(2026, 6, 4), // jueves
        checkOutDate: DateTime(2026, 6, 7), // domingo (excluido)
        holidayDates: {DateTime(2026, 6, 5)}, // viernes feriado
      );

      expect(rates, [
        (date: DateTime(2026, 6, 4), rateCents: 1200), // jueves
        (date: DateTime(2026, 6, 5), rateCents: 2000), // viernes feriado
        (date: DateTime(2026, 6, 6), rateCents: 1500), // sábado
      ]);
    });

    test('una estadía de 0 noches devuelve una lista vacía', () {
      final rates = dayRatesForStay(
        ratePerPersonWeekdayCents: 1200,
        ratePerPersonWeekendCents: 1500,
        ratePerPersonHolidayCents: 2000,
        checkInDate: DateTime(2026, 6, 1),
        checkOutDate: DateTime(2026, 6, 1),
      );

      expect(rates, isEmpty);
    });
  });
}
