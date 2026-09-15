import 'package:flutter/material.dart';
import 'package:orbit_rooms/core/routes/routes_names.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text("OrbitRooms")),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pushNamed(context, RoutesNames.dashboard),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text("Propiedades/Casas"),
            onTap: () => Navigator.pushNamed(context, RoutesNames.properties),
          ),
          ListTile(
            leading: const Icon(Icons.bed_rounded),
            title: const Text("Cuartos/Habitaciones"),
            onTap: () => Navigator.pushNamed(context, RoutesNames.rooms),
          ),
          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text("Reservas"),
            onTap: () => Navigator.pushNamed(context, RoutesNames.reservations),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Calendario"),
            onTap: () => Navigator.pushNamed(context, RoutesNames.calendar),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("Reportes"),
            onTap: () => Navigator.pushNamed(context, RoutesNames.reports),
          ),
        ],
      ),
    );
  }
}
