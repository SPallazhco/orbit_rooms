/// Nombre con el que se muestra una cotización. Si se dio un nombre va
/// primero; si no, queda solo lo demás, para que igual se distingan entre
/// sí: "Ana - 27/10 - 6 adultos, 2 niños" / "27/10 - 6 adultos, 2 niños".
/// El año solo aparece si no es el actual.
String quoteTitle({
  String? guestName,
  required DateTime checkInDate,
  required int adultsCount,
  required int childrenCount,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final day = checkInDate.day.toString().padLeft(2, '0');
  final month = checkInDate.month.toString().padLeft(2, '0');
  final date = checkInDate.year == today.year
      ? '$day/$month'
      : '$day/$month/${checkInDate.year}';

  final people = [
    '$adultsCount ${adultsCount == 1 ? 'adulto' : 'adultos'}',
    if (childrenCount > 0)
      '$childrenCount ${childrenCount == 1 ? 'niño' : 'niños'}',
  ].join(', ');

  final name = guestName?.trim();
  return [if (name != null && name.isNotEmpty) name, date, people].join(' - ');
}
