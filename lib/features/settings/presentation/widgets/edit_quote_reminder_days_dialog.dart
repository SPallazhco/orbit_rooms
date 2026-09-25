import 'package:flutter/material.dart';

class EditQuoteReminderDaysDialog extends StatefulWidget {
  const EditQuoteReminderDaysDialog({super.key, required this.currentDays});

  final int currentDays;

  @override
  State<EditQuoteReminderDaysDialog> createState() =>
      _EditQuoteReminderDaysDialogState();
}

class _EditQuoteReminderDaysDialogState
    extends State<EditQuoteReminderDaysDialog> {
  late final _daysController = TextEditingController(
    text: '${widget.currentDays}',
  );

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  void _save() {
    final days = int.tryParse(_daysController.text);
    if (days == null || days < 0) return;
    Navigator.of(context).pop<int>(days);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recordatorio de cotizaciones'),
      content: TextField(
        controller: _daysController,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Días antes del check-in',
          helperText:
              'Cuántos días antes del check-in avisar para volver a '
              'contactar a un posible huésped que sigue en "Pendiente".',
          helperMaxLines: 3,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}
