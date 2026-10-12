import 'package:orbit_rooms/shared/utils/spanish_dates.dart';

const defaultReminderTemplate =
    'Hola {nombre}, te escribimos de {casa}. Recuerda que tienes una '
    'cotización pendiente para el {fecha} ({personas}), total {total}. '
    '¿Quieres que te confirmemos la reserva?';

/// Variables que la usuaria puede usar en el mensaje, con el nombre que ve
/// en pantalla.
const reminderPlaceholders = <({String token, String label})>[
  (token: '{nombre}', label: 'Nombre'),
  (token: '{casa}', label: 'Casa'),
  (token: '{fecha}', label: 'Fecha'),
  (token: '{personas}', label: 'Personas'),
  (token: '{total}', label: 'Total'),
  (token: '{abono}', label: 'Abono'),
];

typedef ReminderValues = ({
  String? guestName,
  String propertyName,
  DateTime checkInDate,
  int adultsCount,
  int childrenCount,
  String total,
  String deposit,
});

String peopleText(int adultsCount, int childrenCount) => [
  '$adultsCount ${adultsCount == 1 ? 'adulto' : 'adultos'}',
  if (childrenCount > 0)
    '$childrenCount ${childrenCount == 1 ? 'niño' : 'niños'}',
].join(', ');

String _dateText(DateTime d) =>
    '${weekdayName(d).toLowerCase()} ${d.day} de ${monthName(d)}';

/// Reemplaza las variables y deja el texto prolijo: si no hay nombre,
/// "Hola {nombre}," queda "Hola,", sin espacios de más.
String renderReminderMessage(String template, ReminderValues values) {
  final replacements = {
    '{nombre}': values.guestName?.trim() ?? '',
    '{casa}': values.propertyName,
    '{fecha}': _dateText(values.checkInDate),
    '{personas}': peopleText(values.adultsCount, values.childrenCount),
    '{total}': values.total,
    '{abono}': values.deposit,
  };

  var text = template;
  replacements.forEach((token, value) => text = text.replaceAll(token, value));

  return text
      .replaceAllMapped(RegExp(r'[ \t]+([,.;:!?])'), (m) => m.group(1)!)
      .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
      .trim();
}
