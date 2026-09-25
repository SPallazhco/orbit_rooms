import 'package:flutter/material.dart';

typedef QuoteGuestInfo = ({
  String? guestName,
  String? guestContact,
  String? notes,
});

/// Al cotizar puede no haber ni nombre todavía (PRD 5.4 extendido) — por
/// eso los tres campos son opcionales, a diferencia de `AddGuestDialog`
/// donde el nombre es obligatorio.
class EditQuoteGuestDialog extends StatefulWidget {
  const EditQuoteGuestDialog({
    super.key,
    this.guestName,
    this.guestContact,
    this.notes,
  });

  final String? guestName;
  final String? guestContact;
  final String? notes;

  @override
  State<EditQuoteGuestDialog> createState() => _EditQuoteGuestDialogState();
}

class _EditQuoteGuestDialogState extends State<EditQuoteGuestDialog> {
  late final _guestNameController = TextEditingController(
    text: widget.guestName,
  );
  late final _guestContactController = TextEditingController(
    text: widget.guestContact,
  );
  late final _notesController = TextEditingController(text: widget.notes);

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _emptyToNull(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _save() {
    Navigator.of(context).pop<QuoteGuestInfo>((
      guestName: _emptyToNull(_guestNameController.text),
      guestContact: _emptyToNull(_guestContactController.text),
      notes: _emptyToNull(_notesController.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Datos del posible huésped'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _guestNameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nombre (si lo dio)'),
          ),
          TextField(
            controller: _guestContactController,
            decoration: const InputDecoration(
              labelText: 'Contacto (teléfono/WhatsApp)',
            ),
          ),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notas (ej. qué incluye la cotización)',
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
