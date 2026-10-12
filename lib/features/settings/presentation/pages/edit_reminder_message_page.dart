import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/settings/settings_providers.dart';
import 'package:orbit_rooms/features/quotes/domain/reminder_message.dart';

/// El texto del recordatorio que la usuaria quiere mandar siempre, con
/// variables que la app reemplaza por los datos de cada cotización. Se ve
/// una vista previa en vivo con datos de ejemplo.
class EditReminderMessagePage extends ConsumerStatefulWidget {
  const EditReminderMessagePage({super.key});

  @override
  ConsumerState<EditReminderMessagePage> createState() =>
      _EditReminderMessagePageState();
}

class _EditReminderMessagePageState
    extends ConsumerState<EditReminderMessagePage> {
  late final _controller = TextEditingController(
    text:
        ref.read(reminderMessageTemplateProvider).value ??
        defaultReminderTemplate,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insert(String token) {
    final value = _controller.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final text = value.text.replaceRange(selection.start, selection.end, token);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: selection.start + token.length,
      ),
    );
    setState(() {});
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await ref
        .read(appSettingsRepositoryProvider)
        .setReminderMessageTemplate(
          text == defaultReminderTemplate ? null : text,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mensaje guardado')));
    Navigator.of(context).pop();
  }

  void _restore() => setState(() => _controller.text = defaultReminderTemplate);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final today = DateTime.now();
    final preview = renderReminderMessage(_controller.text, (
      guestName: 'María',
      propertyName: 'Hospedaje Shejina',
      checkInDate: DateTime(today.year, today.month, today.day + 3),
      adultsCount: 4,
      childrenCount: 2,
      total: '120.00 USD',
      deposit: '60.00 USD',
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('Mensaje de recordatorio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Es el mensaje que se prepara al recordarle a un cliente que tiene '
            'una cotización pendiente. Toca una variable para insertarla: la '
            'app la reemplaza con los datos de cada cotización.',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final p in reminderPlaceholders)
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: Text(p.label),
                  onPressed: () => _insert(p.token),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 6,
            maxLines: 12,
            keyboardType: TextInputType.multiline,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Mensaje',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Así se vería', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(preview.isEmpty ? '—' : preview),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _controller.text.trim().isEmpty ? null : _save,
            child: const Text('Guardar'),
          ),
          TextButton(
            onPressed: _restore,
            child: const Text('Restaurar el mensaje original'),
          ),
        ],
      ),
    );
  }
}
