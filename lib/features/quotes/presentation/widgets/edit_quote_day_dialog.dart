import 'package:flutter/material.dart';
import 'package:orbit_rooms/features/quotes/domain/quote_pricing.dart';
import 'package:orbit_rooms/shared/utils/spanish_dates.dart';

typedef QuoteNightEdit = ({
  int adultsRateCents,
  Map<String, int> childRatesByGroupId,
  bool applyChildRatesToAllNights,
});

/// Tarifa de adulto y de cada grupo de niños para una noche puntual de la
/// cotización — todas editables a mano (PRD 5.4 extendido): la de adulto
/// parte de la tarifa de la habitación pero se puede ajustar; las de niños
/// no tienen default real, las decide la administradora caso a caso y
/// pueden variar de una noche a otra (feriado, fin de semana).
class EditQuoteDayDialog extends StatefulWidget {
  const EditQuoteDayDialog({
    super.key,
    required this.night,
    required this.nightsCount,
  });

  final QuoteNight night;
  final int nightsCount;

  @override
  State<EditQuoteDayDialog> createState() => _EditQuoteDayDialogState();
}

class _EditQuoteDayDialogState extends State<EditQuoteDayDialog> {
  late final _adultsController = TextEditingController(
    text: _format(widget.night.adultsRateCents),
  );
  late final Map<String, TextEditingController> _childControllers = {
    for (final child in widget.night.children)
      child.group.id: TextEditingController(text: _format(child.rateCents)),
  };
  bool _applyToAll = false;
  bool _invalid = false;

  @override
  void dispose() {
    _adultsController.dispose();
    for (final controller in _childControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _format(int cents) => (cents / 100).toStringAsFixed(2);

  int? _centsFrom(String text) {
    final value = double.tryParse(text.replaceAll(',', '.'));
    if (value == null) return null;
    return (value * 100).round();
  }

  void _save() {
    final adultsRateCents = _centsFrom(_adultsController.text);
    final childRates = <String, int>{};
    var valid = adultsRateCents != null && adultsRateCents >= 0;
    for (final entry in _childControllers.entries) {
      final cents = _centsFrom(entry.value.text);
      if (cents == null || cents < 0) valid = false;
      childRates[entry.key] = cents ?? 0;
    }
    if (!valid) {
      setState(() => _invalid = true);
      return;
    }

    Navigator.of(context).pop<QuoteNightEdit>((
      adultsRateCents: adultsRateCents!,
      childRatesByGroupId: childRates,
      applyChildRatesToAllNights: _applyToAll,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final night = widget.night;

    return AlertDialog(
      title: Text(formatLongDate(night.date)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _adultsController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Adultos ×${night.adultsCount} (por persona)',
              ),
            ),
            for (var i = 0; i < night.children.length; i++)
              TextField(
                controller: _childControllers[night.children[i].group.id],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText:
                      '${night.children.length > 1 ? 'Grupo ${i + 1} · ' : ''}'
                      '${night.children[i].group.count == 1 ? 'Niño' : 'Niños'} '
                      '×${night.children[i].group.count} (por persona)',
                ),
              ),
            if (_invalid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Revisá las tarifas: solo números, por ejemplo 7.50',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (night.children.isNotEmpty && widget.nightsCount > 1)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _applyToAll,
                onChanged: (value) => setState(() => _applyToAll = value!),
                title: const Text(
                  'Usar estas tarifas de niños en todas las noches',
                ),
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
