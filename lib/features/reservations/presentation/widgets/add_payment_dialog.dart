import 'package:flutter/material.dart';
import 'package:orbit_rooms/core/database/app_database.dart';

typedef NewPaymentData = ({int amountCents, PaymentMethod method});

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _amountController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount == 0) return;

    Navigator.of(context).pop<NewPaymentData>((
      amountCents: (amount * 100).round(),
      method: _method,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar pago'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Monto (negativo = reembolso)',
            ),
          ),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _method,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Método'),
            items: const [
              DropdownMenuItem(
                value: PaymentMethod.cash,
                child: Text('Efectivo'),
              ),
              DropdownMenuItem(
                value: PaymentMethod.transfer,
                child: Text('Transferencia'),
              ),
              DropdownMenuItem(
                value: PaymentMethod.card,
                child: Text('Tarjeta'),
              ),
              DropdownMenuItem(value: PaymentMethod.other, child: Text('Otro')),
            ],
            onChanged: (value) => setState(() => _method = value!),
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
