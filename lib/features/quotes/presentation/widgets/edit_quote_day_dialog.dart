import 'package:flutter/material.dart';

typedef QuoteDayRates = ({int adultsRateCents, int childrenRateCents});

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Tarifa de adulto y de niño para una noche puntual de la cotización —
/// ambas editables a mano (PRD 5.4 extendido): la de adulto parte de la
/// tarifa configurada en la habitación pero se puede ajustar, la de niño
/// no tiene default real, la decide la administradora caso a caso y puede
/// variar de una noche a otra.
class EditQuoteDayDialog extends StatefulWidget {
  const EditQuoteDayDialog({
    super.key,
    required this.date,
    required this.adultsRateCents,
    required this.childrenRateCents,
  });

  final DateTime date;
  final int adultsRateCents;
  final int childrenRateCents;

  @override
  State<EditQuoteDayDialog> createState() => _EditQuoteDayDialogState();
}

class _EditQuoteDayDialogState extends State<EditQuoteDayDialog> {
  late final _adultsController = TextEditingController(
    text: (widget.adultsRateCents / 100).toStringAsFixed(2),
  );
  late final _childrenController = TextEditingController(
    text: (widget.childrenRateCents / 100).toStringAsFixed(2),
  );

  @override
  void dispose() {
    _adultsController.dispose();
    _childrenController.dispose();
    super.dispose();
  }

  int? _centsFrom(String text) {
    final value = double.tryParse(text.replaceAll(',', '.'));
    if (value == null) return null;
    return (value * 100).round();
  }

  void _save() {
    final adultsRateCents = _centsFrom(_adultsController.text);
    final childrenRateCents = _centsFrom(_childrenController.text);
    if (adultsRateCents == null || childrenRateCents == null) return;

    Navigator.of(context).pop<QuoteDayRates>((
      adultsRateCents: adultsRateCents,
      childrenRateCents: childrenRateCents,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_formatDate(widget.date)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _adultsController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Tarifa adulto (por persona)',
            ),
          ),
          TextField(
            controller: _childrenController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Tarifa niño (por persona)',
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
