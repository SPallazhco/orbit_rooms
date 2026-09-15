import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';

/// Mismo formulario para crear y editar (PRD 5.2, "CRUD de habitaciones"):
/// la única diferencia es que [initial] ya trae los datos cargados.
class AddRoomDialog extends ConsumerStatefulWidget {
  const AddRoomDialog({super.key, required this.properties, this.initial});

  final List<Property> properties;
  final Room? initial;

  @override
  ConsumerState<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends ConsumerState<AddRoomDialog> {
  late final _nameController = TextEditingController(
    text: widget.initial?.name,
  );
  late final _capacityController = TextEditingController(
    text: widget.initial?.capacity.toString(),
  );
  late final _weekdayController = TextEditingController(
    text: _decimalFrom(widget.initial?.ratePerPersonWeekdayCents),
  );
  late final _weekendController = TextEditingController(
    text: _decimalFrom(widget.initial?.ratePerPersonWeekendCents),
  );
  late final _holidayController = TextEditingController(
    text: _decimalFrom(widget.initial?.ratePerPersonHolidayCents),
  );

  String? _propertyId;
  List<RoomType> _roomTypes = [];
  String? _roomTypeId;
  bool _loadingTypes = true;

  static String? _decimalFrom(int? cents) =>
      cents == null ? null : (cents / 100).toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    _propertyId =
        widget.initial?.propertyId ??
        (widget.properties.isEmpty ? null : widget.properties.first.id);
    _roomTypeId = widget.initial?.roomTypeId;
    _loadRoomTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _weekdayController.dispose();
    _weekendController.dispose();
    _holidayController.dispose();
    super.dispose();
  }

  Future<void> _loadRoomTypes() async {
    final types = await ref.read(roomTypeRepositoryProvider).getAll();
    if (!mounted) return;
    setState(() {
      _roomTypes = types;
      _roomTypeId ??= types.isEmpty ? null : types.first.id;
      _loadingTypes = false;
    });
  }

  Future<void> _createRoomType() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo tipo de habitación'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;
    final id = await ref.read(roomTypeRepositoryProvider).create(name);
    if (!mounted) return;
    setState(() => _roomTypeId = id);
    await _loadRoomTypes();
  }

  int _centsFrom(String text) {
    final value = double.tryParse(text.replaceAll(',', '.')) ?? 0;
    return (value * 100).round();
  }

  Future<void> _save() async {
    final propertyId = _propertyId;
    final roomTypeId = _roomTypeId;
    final name = _nameController.text.trim();
    final capacity = int.tryParse(_capacityController.text) ?? 0;

    if (propertyId == null ||
        roomTypeId == null ||
        name.isEmpty ||
        capacity <= 0) {
      return;
    }

    final repository = ref.read(roomRepositoryProvider);
    final initial = widget.initial;
    if (initial == null) {
      await repository.create(
        propertyId: propertyId,
        roomTypeId: roomTypeId,
        name: name,
        capacity: capacity,
        ratePerPersonWeekdayCents: _centsFrom(_weekdayController.text),
        ratePerPersonWeekendCents: _centsFrom(_weekendController.text),
        ratePerPersonHolidayCents: _centsFrom(_holidayController.text),
      );
    } else {
      await repository.update(
        initial.copyWith(
          propertyId: propertyId,
          roomTypeId: roomTypeId,
          name: name,
          capacity: capacity,
          ratePerPersonWeekdayCents: _centsFrom(_weekdayController.text),
          ratePerPersonWeekendCents: _centsFrom(_weekendController.text),
          ratePerPersonHolidayCents: _centsFrom(_holidayController.text),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null ? 'Nueva habitación' : 'Editar habitación',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _propertyId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Propiedad'),
              items: widget.properties
                  .map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _propertyId = value),
            ),
            const SizedBox(height: 8),
            if (_loadingTypes)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _roomTypeId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de habitación',
                      ),
                      items: _roomTypes
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(t.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _roomTypeId = value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Nuevo tipo',
                    onPressed: _createRoomType,
                  ),
                ],
              ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre/número'),
            ),
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacidad orientativa',
              ),
            ),
            TextField(
              controller: _weekdayController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Tarifa entre semana (por persona)',
              ),
            ),
            TextField(
              controller: _weekendController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Tarifa fin de semana (por persona)',
              ),
            ),
            TextField(
              controller: _holidayController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Tarifa feriado (por persona)',
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
