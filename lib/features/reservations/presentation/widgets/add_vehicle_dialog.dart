import 'package:flutter/material.dart';
import 'package:orbit_rooms/core/database/app_database.dart';

typedef VehicleFormData = ({String plate, int? garageFeeCents});

/// Mismo patrón `initial` que `AddGuestDialog`/`AddRoomDialog`: crear si es
/// `null`, editar si trae datos.
class AddVehicleDialog extends StatefulWidget {
  const AddVehicleDialog({super.key, this.initial, this.showGarageFee = true});

  final Vehicle? initial;

  /// La comisión de garaje solo tiene sentido en una casa que no es la del
  /// usuario (en la suya el garaje es gratis) — ver docs/DECISIONS.md.
  final bool showGarageFee;

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  late final _plateController = TextEditingController(
    text: widget.initial?.plate,
  );
  late final _garageFeeController = TextEditingController(
    text: widget.initial?.garageFeeCents == null
        ? ''
        : (widget.initial!.garageFeeCents! / 100).toStringAsFixed(2),
  );

  @override
  void dispose() {
    _plateController.dispose();
    _garageFeeController.dispose();
    super.dispose();
  }

  void _save() {
    final plate = _plateController.text.trim();
    if (plate.isEmpty) return;

    final feeText = _garageFeeController.text.trim();
    final garageFeeCents = !widget.showGarageFee || feeText.isEmpty
        ? null
        : ((double.tryParse(feeText.replaceAll(',', '.')) ?? 0) * 100).round();

    Navigator.of(
      context,
    ).pop<VehicleFormData>((plate: plate, garageFeeCents: garageFeeCents));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null ? 'Nuevo vehículo' : 'Editar vehículo',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _plateController,
            autofocus: widget.initial == null,
            enabled: widget.initial == null,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Placa'),
          ),
          if (widget.showGarageFee)
            TextField(
              controller: _garageFeeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Comisión de garaje (opcional)',
                helperText:
                    'Lo que se resta del ingreso de esa noche por tener '
                    'este auto ahí, a tu conveniencia. Dejalo vacío si no '
                    'aplica.',
                helperMaxLines: 3,
              ),
            ),
        ],
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
