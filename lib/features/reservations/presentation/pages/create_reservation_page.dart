import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/features/guests/guests_providers.dart';
import 'package:orbit_rooms/features/guests/presentation/widgets/add_guest_dialog.dart';
import 'package:orbit_rooms/features/reservations/data/reservation_repository.dart';
import 'package:orbit_rooms/features/reservations/reservations_providers.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';

class _RoomAssignmentRow {
  _RoomAssignmentRow();

  String? roomId;
  final TextEditingController guestsCountController = TextEditingController();

  void dispose() => guestsCountController.dispose();
}

class CreateReservationPage extends ConsumerStatefulWidget {
  const CreateReservationPage({super.key});

  @override
  ConsumerState<CreateReservationPage> createState() =>
      _CreateReservationPageState();
}

class _CreateReservationPageState extends ConsumerState<CreateReservationPage> {
  String? _guestId;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  final List<_RoomAssignmentRow> _roomRows = [_RoomAssignmentRow()];
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final row in _roomRows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final initialDate = isCheckIn
        ? (_checkInDate ?? now)
        : (_checkOutDate ?? _checkInDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
      ),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;

    setState(() {
      if (isCheckIn) {
        _checkInDate = picked;
      } else {
        _checkOutDate = picked;
      }
    });
  }

  Future<void> _addGuest() async {
    final data = await showDialog<NewGuestData>(
      context: context,
      builder: (_) => const AddGuestDialog(),
    );
    if (data == null) return;

    final id = await ref
        .read(guestRepositoryProvider)
        .create(
          fullName: data.fullName,
          documentId: data.documentId,
          phone: data.phone,
          email: data.email,
          notes: data.notes,
        );
    setState(() => _guestId = id);
  }

  Future<void> _save() async {
    setState(() => _errorMessage = null);

    final guestId = _guestId;
    final checkInDate = _checkInDate;
    final checkOutDate = _checkOutDate;

    if (guestId == null || checkInDate == null || checkOutDate == null) {
      setState(() => _errorMessage = 'Completá huésped y fechas');
      return;
    }

    final assignments = <RoomAssignmentInput>[];
    for (final row in _roomRows) {
      if (row.roomId == null) continue;
      final guestsCount = int.tryParse(row.guestsCountController.text) ?? 0;
      assignments.add(
        RoomAssignmentInput(roomId: row.roomId!, guestsCount: guestsCount),
      );
    }
    if (assignments.isEmpty) {
      setState(() => _errorMessage = 'Asigná al menos una habitación');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(createReservationUseCaseProvider)
          .call(
            guestId: guestId,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            roomAssignments: assignments,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestsAsync = ref.watch(guestsProvider);
    final roomsAsync = ref.watch(activeRoomsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva reserva')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          guestsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
            data: (guests) => Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _guestId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Huésped principal',
                    ),
                    items: guests
                        .map(
                          (g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.fullName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _guestId = value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Nuevo huésped',
                  onPressed: _addGuest,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(isCheckIn: true),
                  child: Text(
                    _checkInDate == null
                        ? 'Check-in'
                        : 'Check-in: ${_formatDate(_checkInDate!)}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(isCheckIn: false),
                  child: Text(
                    _checkOutDate == null
                        ? 'Check-out'
                        : 'Check-out: ${_formatDate(_checkOutDate!)}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Habitaciones asignadas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          roomsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
            data: (rooms) => Column(
              children: [
                for (final row in _roomRows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            initialValue: row.roomId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Habitación',
                            ),
                            items: rooms
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.room.id,
                                    child: Text(
                                      '${entry.propertyName} — ${entry.room.name}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => row.roomId = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: row.guestsCountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Personas',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _roomRows.length == 1
                              ? null
                              : () => setState(() {
                                  row.dispose();
                                  _roomRows.remove(row);
                                }),
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _roomRows.add(_RoomAssignmentRow())),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar habitación'),
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar reserva'),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
