import 'package:flutter/material.dart';

class EditPriceDialog extends StatefulWidget {
  const EditPriceDialog({super.key, required this.currentPriceCents});

  final int currentPriceCents;

  @override
  State<EditPriceDialog> createState() => _EditPriceDialogState();
}

class _EditPriceDialogState extends State<EditPriceDialog> {
  late final _priceController = TextEditingController(
    text: (widget.currentPriceCents / 100).toStringAsFixed(2),
  );

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_priceController.text.replaceAll(',', '.'));
    if (value == null) return;
    Navigator.of(context).pop<int>((value * 100).round());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajustar precio final'),
      content: TextField(
        controller: _priceController,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Precio total',
          helperText:
              'El precio calculado es un punto de partida — este ajuste no '
              'sigue una fórmula fija (ej. auto extra, multa, descuento). '
              'Dejá el motivo en Notas.',
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
