import 'package:flutter/material.dart';
import 'package:orbit_rooms/core/notifications/notification_service.dart';
import 'package:orbit_rooms/core/routes/app_routes.dart';
import 'package:orbit_rooms/core/routes/routes_names.dart';
import 'package:orbit_rooms/core/themes/app_theme.dart';

class OrbitRooms extends StatelessWidget {
  const OrbitRooms({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: "OrbitRooms",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: AppRoutes.routes,
      initialRoute: RoutesNames.properties,
    );
  }
}
