/// Orden de la lista de cotizaciones: primero las que todavía están por
/// venir (la más cercana arriba, que es la que hay que atender antes) y
/// después las de fechas pasadas (la más reciente arriba).
({List<T> upcoming, List<T> past}) splitUpcomingAndPast<T>(
  Iterable<T> items,
  DateTime Function(T) checkInOf,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final upcoming = items.where((i) => !checkInOf(i).isBefore(today)).toList()
    ..sort((a, b) => checkInOf(a).compareTo(checkInOf(b)));
  final past = items.where((i) => checkInOf(i).isBefore(today)).toList()
    ..sort((a, b) => checkInOf(b).compareTo(checkInOf(a)));
  return (upcoming: upcoming, past: past);
}

/// Cuánto falta para el check-in, en días calendario (0 = hoy). Negativo si
/// ya pasó.
int daysUntil(DateTime checkIn, DateTime now) => DateTime(
  checkIn.year,
  checkIn.month,
  checkIn.day,
).difference(DateTime(now.year, now.month, now.day)).inDays;
