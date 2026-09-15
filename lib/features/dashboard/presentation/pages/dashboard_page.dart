import 'package:flutter/material.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OrbitRooms")),
      drawer: AppDrawer(),
      body: const Center(child: Text("Dashboard")),
    );
  }
}
