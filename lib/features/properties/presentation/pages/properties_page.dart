import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_rooms/core/database/app_database.dart';
import 'package:orbit_rooms/features/properties/presentation/widgets/add_property_dialog.dart';
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
                onTap: () => _editProperty(context, ref, property),
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
    final data = await showDialog<NewPropertyData>(
      context: context,
      builder: (_) => const AddPropertyDialog(),
    );
    if (data == null) return;

    await ref
        .read(propertyRepositoryProvider)
        .create(
          name: data.name,
          address: data.address,
          ownerName: data.ownerName,
          ownerContact: data.ownerContact,
          isPrimary: data.isPrimary,
        );
  }

  Future<void> _editProperty(
    BuildContext context,
    WidgetRef ref,
    Property property,
  ) async {
    final data = await showDialog<NewPropertyData>(
      context: context,
      builder: (_) => AddPropertyDialog(initial: property),
    );
    if (data == null) return;

    await ref
        .read(propertyRepositoryProvider)
        .update(
          property.copyWith(
            name: data.name,
            address: Value(data.address),
            ownerName: Value(data.ownerName),
            ownerContact: Value(data.ownerContact),
            isPrimary: data.isPrimary,
          ),
        );
  }
}
