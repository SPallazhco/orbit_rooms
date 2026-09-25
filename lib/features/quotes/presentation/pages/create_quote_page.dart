import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/core/notifications/notification_service.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/quote_detail_page.dart';
import 'package:orbit_rooms/features/quotes/quotes_providers.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

class CreateQuotePage extends ConsumerStatefulWidget {
  const CreateQuotePage({super.key});

  @override
  ConsumerState<CreateQuotePage> createState() => _CreateQuotePageState();
}

class _CreateQuotePageState extends ConsumerState<CreateQuotePage> {
  String? _roomId;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  final _adultsController = TextEditingController(text: '1');
  final _childrenController = TextEditingController(text: '0');
  final _guestNameController = TextEditingController();
  final _guestContactController = TextEditingController();
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _adultsController.dispose();
    _childrenController.dispose();
    _guestNameController.dispose();
    _guestContactController.dispose();
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

  String? _emptyToNull(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _save(List<({Room room, String propertyName})> rooms) async {
    setState(() => _errorMessage = null);

    final roomId = _roomId;
    final checkInDate = _checkInDate;
    final checkOutDate = _checkOutDate;
    final adultsCount = int.tryParse(_adultsController.text) ?? 0;
    final childrenCount = int.tryParse(_childrenController.text) ?? 0;

    if (roomId == null || checkInDate == null || checkOutDate == null) {
      setState(() => _errorMessage = 'Completá habitación y fechas');
      return;
    }
    if (!checkOutDate.isAfter(checkInDate)) {
      setState(
        () => _errorMessage = 'El check-out debe ser posterior al check-in',
      );
      return;
    }
    if (adultsCount <= 0) {
      setState(() => _errorMessage = 'Al menos 1 adulto');
      return;
    }

    final room = rooms.firstWhere((entry) => entry.room.id == roomId).room;

    setState(() => _saving = true);
    try {
      final guestName = _emptyToNull(_guestNameController.text);
      final quoteId = await ref
          .read(quoteRepositoryProvider)
          .create(
            propertyId: room.propertyId,
            roomId: roomId,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            adultsCount: adultsCount,
            childrenCount: childrenCount,
            guestName: guestName,
            guestContact: _emptyToNull(_guestContactController.text),
          );

      final reminderDays = await ref
          .read(appSettingsRepositoryProvider)
          .getQuoteReminderDays();
      await NotificationService.scheduleQuoteReminder(
        quoteId: quoteId,
        checkInDate: checkInDate,
        reminderDays: reminderDays,
        guestLabel: guestName ?? 'Un posible huésped',
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => QuoteDetailPage(quoteId: quoteId)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(activeRoomsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva cotización')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          roomsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Error: $error'),
            data: (rooms) => DropdownButtonFormField<String>(
              initialValue: _roomId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Habitación'),
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
              onChanged: (value) => setState(() => _roomId = value),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _adultsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Adultos'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _childrenController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Niños'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _guestNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre (si lo dio, opcional)',
            ),
          ),
          TextField(
            controller: _guestContactController,
            decoration: const InputDecoration(
              labelText: 'Contacto / WhatsApp (opcional)',
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
          roomsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => const SizedBox.shrink(),
            data: (rooms) => FilledButton(
              onPressed: _saving ? null : () => _save(rooms),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear cotización'),
            ),
          ),
        ],
      ),
    );
  }
}
