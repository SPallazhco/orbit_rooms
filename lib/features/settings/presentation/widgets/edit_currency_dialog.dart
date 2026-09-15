import 'package:flutter/material.dart';

class EditCurrencyDialog extends StatefulWidget {
  const EditCurrencyDialog({super.key, required this.currentCurrency});

  final String currentCurrency;

  @override
  State<EditCurrencyDialog> createState() => _EditCurrencyDialogState();
}

class _EditCurrencyDialogState extends State<EditCurrencyDialog> {
  late final _currencyController = TextEditingController(
    text: widget.currentCurrency,
  );

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }

  void _save() {
    final currency = _currencyController.text.trim().toUpperCase();
    if (currency.isEmpty) return;
    Navigator.of(context).pop<String>(currency);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Moneda'),
      content: TextField(
        controller: _currencyController,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: 'Código de moneda',
          hintText: 'Ej. USD, COP, PEN',
          helperText:
              'Una sola moneda para toda la app — no hay conversión ni '
              'moneda por propiedad.',
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
