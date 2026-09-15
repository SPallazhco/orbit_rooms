import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/properties/properties_providers.dart';
import 'package:orbit_rooms/features/rooms/presentation/widgets/add_room_dialog.dart';
import 'package:orbit_rooms/features/rooms/rooms_providers.dart';

class RoomsPage extends ConsumerWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(activeRoomsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habitaciones')),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(child: Text('Todavía no tienes habitaciones'));
          }

          final byProperty = <String, List<Room>>{};
          for (final entry in rooms) {
            byProperty
                .putIfAbsent(entry.propertyName, () => [])
                .add(entry.room);
          }

          return ListView(
            children: [
              for (final group in byProperty.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    group.key,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (final room in group.value)
                  ListTile(
                    title: Text(room.name),
                    subtitle: Text('Capacidad orientativa: ${room.capacity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(roomRepositoryProvider).deactivate(room.id),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRoom(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addRoom(BuildContext context, WidgetRef ref) async {
    final properties = await ref.read(propertyRepositoryProvider).getActive();

    if (!context.mounted) return;

    if (properties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero creá una propiedad en la pestaña Propiedades'),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => AddRoomDialog(properties: properties),
    );
  }
}
