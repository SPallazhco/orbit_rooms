const _weekdayNames = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

const _monthNames = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String weekdayName(DateTime d) => _weekdayNames[d.weekday - 1];

String monthName(DateTime d) => _monthNames[d.month - 1];

/// "Vie 9 oct" — compacta, para chips y filas donde no cabe la fecha larga.
String formatShortDate(DateTime d) =>
    '${weekdayName(d).substring(0, 3)} ${d.day} '
    '${monthName(d).substring(0, 3)}';

/// "Viernes 9 de octubre".
String formatLongDate(DateTime d) =>
    '${weekdayName(d)} ${d.day} de ${monthName(d)}';
