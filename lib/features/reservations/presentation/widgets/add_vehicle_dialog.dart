import 'package:flutter/material.dart';

class AddVehicleDialog extends StatefulWidget {
  const AddVehicleDialog({super.key});

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _plateController = TextEditingController();

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _save() {
    final plate = _plateController.text.trim();
    if (plate.isEmpty) return;
    Navigator.of(context).pop<String>(plate);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo vehículo'),
      content: TextField(
        controller: _plateController,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(labelText: 'Placa'),
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
