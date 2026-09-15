import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/features/properties/properties_providers.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

class PropertiesPage extends ConsumerWidget {
  const PropertiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(activePropertiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("OrbitRooms")),
      drawer: AppDrawer(),
      body: propertiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (properties) {
          if (properties.isEmpty) {
            return const Center(child: Text('Todavía no tienes propiedades'));
          }
          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return ListTile(
                title: Text(property.name),
                subtitle: property.address == null
                    ? null
                    : Text(property.address!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref
                      .read(propertyRepositoryProvider)
                      .deactivate(property.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addProperty(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addProperty(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva propiedad'),
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

    if (name != null && name.isNotEmpty) {
      await ref.read(propertyRepositoryProvider).create(name: name);
    }
  }
}
