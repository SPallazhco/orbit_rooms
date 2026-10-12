import 'package:flutter/material.dart';
import 'package:orbit_rooms/features/quotes/presentation/widgets/reminders_bell.dart';
import 'package:orbit_rooms/features/reports/presentation/widgets/commission_report_section.dart';
import 'package:orbit_rooms/features/reports/presentation/widgets/garage_report_section.dart';
import 'package:orbit_rooms/shared/widgets/app_drawer.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: const [RemindersBell()],
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          GarageReportSection(),
          SizedBox(height: 16),
          CommissionReportSection(),
        ],
      ),
    );
  }
}
