import 'package:flutter/material.dart';

typedef NewGuestData = ({
  String fullName,
  String? documentId,
  String? phone,
  String? email,
  String? notes,
});

class AddGuestDialog extends StatefulWidget {
  const AddGuestDialog({super.key});

  @override
  State<AddGuestDialog> createState() => _AddGuestDialogState();
}

class _AddGuestDialogState extends State<AddGuestDialog> {
  final _fullNameController = TextEditingController();
  final _documentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _emptyToNull(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _save() {
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) return;

    Navigator.of(context).pop<NewGuestData>((
      fullName: fullName,
      documentId: _emptyToNull(_documentIdController.text),
      phone: _emptyToNull(_phoneController.text),
      email: _emptyToNull(_emailController.text),
      notes: _emptyToNull(_notesController.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo huésped'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _fullNameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            TextField(
              controller: _documentIdController,
              decoration: const InputDecoration(
                labelText: 'Documento de identidad',
              ),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notas'),
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
