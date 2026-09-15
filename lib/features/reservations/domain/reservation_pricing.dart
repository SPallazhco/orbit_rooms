/// Suma, por cada noche entre [checkInDate] (incluida) y [checkOutDate]
/// (excluida), la tarifa por persona correspondiente x [guestsCount].
/// Prioridad de tarifa por noche: feriado (si la fecha está en
/// [holidayDates]) > fin de semana (viernes, sábado, domingo) > entre
/// semana. Un feriado que cae en fin de semana se cobra como feriado, no
/// como fin de semana (PRD 5.2/5.4/5.10). Función pura: no toca la base de
/// datos.
int calculateSubtotalCents({
  required int ratePerPersonWeekdayCents,
  required int ratePerPersonWeekendCents,
  required int ratePerPersonHolidayCents,
  required DateTime checkInDate,
  required DateTime checkOutDate,
  required int guestsCount,
  Set<DateTime> holidayDates = const {},
}) {
  var subtotalCents = 0;
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

    subtotalCents += rateCents * guestsCount;
  }
  return subtotalCents;
}
