typedef DayRate = ({DateTime date, int rateCents});

/// Para cada noche entre [checkInDate] (incluida) y [checkOutDate]
/// (excluida), la tarifa por persona correspondiente esa noche. Prioridad:
/// feriado (si la fecha está en [holidayDates]) > fin de semana (viernes,
/// sábado, domingo) > entre semana. Un feriado que cae en fin de semana se
/// cobra como feriado, no como fin de semana (PRD 5.2/5.4/5.10). Función
/// pura: no toca la base de datos. Reutilizada por Reservations (suma un
/// subtotal, ver [calculateSubtotalCents]) y por Quotes (PRD 5.4
/// extendido — cada noche es una línea editable, ver
/// docs/DECISIONS.md).
List<DayRate> dayRatesForStay({
  required int ratePerPersonWeekdayCents,
  required int ratePerPersonWeekendCents,
  required int ratePerPersonHolidayCents,
  required DateTime checkInDate,
  required DateTime checkOutDate,
  Set<DateTime> holidayDates = const {},
}) {
  final rates = <DayRate>[];
  for (
    var night = checkInDate;
    night.isBefore(checkOutDate);
    night = night.add(const Duration(days: 1))
  ) {
    final isHoliday = holidayDates.contains(night);
    final isWeekend =
        night.weekday == DateTime.friday ||
        night.weekday == DateTime.saturday ||
        night.weekday == DateTime.sunday;

    final rateCents = isHoliday
        ? ratePerPersonHolidayCents
        : (isWeekend ? ratePerPersonWeekendCents : ratePerPersonWeekdayCents);

    rates.add((date: night, rateCents: rateCents));
  }
  return rates;
}

/// Suma, por cada noche entre [checkInDate] (incluida) y [checkOutDate]
/// (excluida), la tarifa por persona correspondiente x [guestsCount]. Ver
/// [dayRatesForStay] para la regla de qué tarifa aplica cada noche.
int calculateSubtotalCents({
  required int ratePerPersonWeekdayCents,
  required int ratePerPersonWeekendCents,
  required int ratePerPersonHolidayCents,
  required DateTime checkInDate,
  required DateTime checkOutDate,
  required int guestsCount,
  Set<DateTime> holidayDates = const {},
}) {
  final rates = dayRatesForStay(
    ratePerPersonWeekdayCents: ratePerPersonWeekdayCents,
    ratePerPersonWeekendCents: ratePerPersonWeekendCents,
    ratePerPersonHolidayCents: ratePerPersonHolidayCents,
    checkInDate: checkInDate,
    checkOutDate: checkOutDate,
    holidayDates: holidayDates,
  );
  return rates.fold(0, (sum, day) => sum + day.rateCents * guestsCount);
}
