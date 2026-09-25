import 'package:flutter/material.dart';

class EditDepositDialog extends StatefulWidget {
  const EditDepositDialog({super.key, required this.currentDepositCents});

  final int currentDepositCents;

  @override
  State<EditDepositDialog> createState() => _EditDepositDialogState();
}

class _EditDepositDialogState extends State<EditDepositDialog> {
  late final _depositController = TextEditingController(
    text: (widget.currentDepositCents / 100).toStringAsFixed(2),
  );

  @override
  void dispose() {
    _depositController.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_depositController.text.replaceAll(',', '.'));
    if (value == null) return;
    Navigator.of(context).pop<int>((value * 100).round());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Abono para la reservación'),
      content: TextField(
        controller: _depositController,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Abono',
          helperText:
              'Sugerido como la mitad del total — no hay una regla fija, '
              'ajustalo si hace falta.',
          helperMaxLines: 2,
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
