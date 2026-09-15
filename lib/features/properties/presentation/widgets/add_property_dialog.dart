import 'package:flutter/material.dart';
import 'package:orbit_rooms/core/database/app_database.dart';

typedef NewPropertyData = ({
  String name,
  String? address,
  String? ownerName,
  String? ownerContact,
  bool isPrimary,
});

/// Mismo formulario para crear y editar (PRD 5.1, "Crear, editar, listar y
/// desactivar propiedades"): la única diferencia es que [initial] ya trae
/// los datos cargados.
class AddPropertyDialog extends StatefulWidget {
  const AddPropertyDialog({super.key, this.initial});

  final Property? initial;

  @override
  State<AddPropertyDialog> createState() => _AddPropertyDialogState();
}

class _AddPropertyDialogState extends State<AddPropertyDialog> {
  late final _nameController = TextEditingController(
    text: widget.initial?.name,
  );
  late final _addressController = TextEditingController(
    text: widget.initial?.address,
  );
  late final _ownerNameController = TextEditingController(
    text: widget.initial?.ownerName,
  );
  late final _ownerContactController = TextEditingController(
    text: widget.initial?.ownerContact,
  );
  late bool _isPrimary = widget.initial?.isPrimary ?? false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _ownerContactController.dispose();
    super.dispose();
  }

  String? _emptyToNull(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.of(context).pop<NewPropertyData>((
      name: name,
      address: _emptyToNull(_addressController.text),
      ownerName: _emptyToNull(_ownerNameController.text),
      ownerContact: _emptyToNull(_ownerContactController.text),
      isPrimary: _isPrimary,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null ? 'Nueva propiedad' : 'Editar propiedad',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            TextField(
              controller: _ownerNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del dueño (si es de un tercero)',
              ),
            ),
            TextField(
              controller: _ownerContactController,
              decoration: const InputDecoration(
                labelText: 'Contacto del dueño',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Es mi propiedad principal'),
              value: _isPrimary,
              onChanged: (value) => setState(() => _isPrimary = value),
            ),
          ],
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
