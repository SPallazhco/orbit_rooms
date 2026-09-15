import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/features/guests/guests_providers.dart';
import 'package:orbit_rooms/features/guests/presentation/widgets/add_guest_dialog.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

class GuestsPage extends ConsumerStatefulWidget {
  const GuestsPage({super.key});

  @override
  ConsumerState<GuestsPage> createState() => _GuestsPageState();
}

class _GuestsPageState extends ConsumerState<GuestsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final guestsAsync = ref.watch(guestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Huéspedes')),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre o documento',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: guestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (guests) {
                final filtered = _query.isEmpty
                    ? guests
                    : guests
                          .where(
                            (g) =>
                                g.fullName.toLowerCase().contains(_query) ||
                                (g.documentId?.toLowerCase().contains(_query) ??
                                    false),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      guests.isEmpty
                          ? 'Todavía no tienes huéspedes'
                          : 'Sin resultados para "$_query"',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final guest = filtered[index];
                    return ListTile(
                      title: Text(guest.fullName),
                      subtitle: guest.documentId == null
                          ? null
                          : Text(guest.documentId!),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteGuest(context, guest.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addGuest(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addGuest(BuildContext context) async {
    final data = await showDialog<NewGuestData>(
      context: context,
      builder: (_) => const AddGuestDialog(),
    );
    if (data == null) return;

    await ref
        .read(guestRepositoryProvider)
        .create(
          fullName: data.fullName,
          documentId: data.documentId,
          phone: data.phone,
          email: data.email,
          notes: data.notes,
        );
  }

  /// A diferencia de Property/Room (que se desactivan), Guest sí se borra
  /// de verdad — y `PRAGMA foreign_keys = ON` va a rechazar el borrado si
  /// el huésped tiene reservas asociadas (ver docs/DECISIONS.md).
  Future<void> _deleteGuest(BuildContext context, String id) async {
    try {
      await ref.read(guestRepositoryProvider).delete(id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar: tiene reservas asociadas'),
        ),
      );
    }
  }
}
