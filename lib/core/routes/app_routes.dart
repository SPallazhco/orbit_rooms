import 'package:flutter/widgets.dart';
import 'package:orbit_rooms/core/routes/routes_names.dart';
import 'package:orbit_rooms/features/calendar/presentation/pages/calendar_page.dart';
import 'package:orbit_rooms/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:orbit_rooms/features/properties/presentation/pages/properties_page.dart';
import 'package:orbit_rooms/features/reports/presentation/pages/reports_page.dart';
import 'package:orbit_rooms/features/reservations/presentation/pages/reservations_page.dart';
import 'package:orbit_rooms/features/rooms/presentation/pages/rooms_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    RoutesNames.dashboard: (_) => const DashboardPage(),
    RoutesNames.properties: (_) => const PropertiesPage(),
    RoutesNames.rooms: (_) => const RoomsPage(),
    RoutesNames.reservations: (_) => const ReservationsPage(),
    RoutesNames.calendar: (_) => const CalendarPage(),
    RoutesNames.reports: (_) => const ReportsPage(),
  };
}
