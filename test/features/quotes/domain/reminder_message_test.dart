import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_rooms/features/quotes/domain/reminder_message.dart';

void main() {
  ReminderValues values({String? name = 'Sergio'}) => (
    guestName: name,
    propertyName: 'Hospedaje Shejina',
    checkInDate: DateTime(2026, 10, 29),
    adultsCount: 4,
    childrenCount: 1,
    total: '48.00 USD',
    deposit: '24.00 USD',
  );

  test('reemplaza todas las variables del mensaje original', () {
    final text = renderReminderMessage(defaultReminderTemplate, values());

    expect(
      text,
      'Hola Sergio, te escribimos de Hospedaje Shejina. Recuerda que tienes '
      'una cotización pendiente para el jueves 29 de octubre (4 adultos, '
      '1 niño), total 48.00 USD. ¿Quieres que te confirmemos la reserva?',
    );
  });

  test('sin nombre el saludo queda prolijo, sin espacio antes de la coma', () {
    for (final name in [null, '', '  ']) {
      final text = renderReminderMessage(
        defaultReminderTemplate,
        values(name: name),
      );
      expect(text.startsWith('Hola, te escribimos de'), true);
    }
  });

  test('una variable repetida se reemplaza en todos los lugares y el texto '
      'sin variables queda igual', () {
    expect(
      renderReminderMessage('{casa} / {casa} - abono {abono}', values()),
      'Hospedaje Shejina / Hospedaje Shejina - abono 24.00 USD',
    );
    expect(
      renderReminderMessage('Hola, ¿sigues interesado?', values()),
      'Hola, ¿sigues interesado?',
    );
  });

  test('conserva los saltos de línea que escribió la usuaria', () {
    expect(
      renderReminderMessage('Hola {nombre}\n\n{casa}', values()),
      'Hola Sergio\n\nHospedaje Shejina',
    );
  });
}
