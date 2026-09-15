import 'package:flutter/material.dart';

class EditNotesDialog extends StatefulWidget {
  const EditNotesDialog({super.key, required this.initialNotes});

  final String? initialNotes;

  @override
  State<EditNotesDialog> createState() => _EditNotesDialogState();
}

class _EditNotesDialogState extends State<EditNotesDialog> {
  late final _notesController = TextEditingController(
    text: widget.initialNotes,
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Notas'),
      content: TextField(
        controller: _notesController,
        autofocus: true,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Ej. desayuno a las 7, auto extra +\$5...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop<String>(_notesController.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
