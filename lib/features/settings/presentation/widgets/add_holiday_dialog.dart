import 'package:flutter/material.dart';

typedef NewHolidayData = ({DateTime date, String? name});

class AddHolidayDialog extends StatefulWidget {
  const AddHolidayDialog({super.key});

  @override
  State<AddHolidayDialog> createState() => _AddHolidayDialogState();
}

class _AddHolidayDialogState extends State<AddHolidayDialog> {
  final _nameController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 2),
      lastDate: DateTime(_date.year + 2),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    Navigator.of(
      context,
    ).pop<NewHolidayData>((date: _date, name: name.isEmpty ? null : name));
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo feriado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Fecha'),
            subtitle: Text(_formatDate(_date)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre (opcional)',
              hintText: 'Ej. Independencia de Cuenca',
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
