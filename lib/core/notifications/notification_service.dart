import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:orbit_rooms/features/quotes/presentation/pages/quote_detail_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Le da navegación a la notificación al tocarla, sin depender de rutas con
/// nombre (`QuoteDetailPage` necesita un `quoteId` que las rutas actuales no
/// pasan como argumento).
final rootNavigatorKey = GlobalKey<NavigatorState>();

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Recordatorio local para volver a contactar a un posible huésped que
/// cotizó y no respondió (PRD 5.4 extendido, ver docs/DECISIONS.md).
///
/// Zona horaria fija en `America/Guayaquil`: la app es para un hostal real
/// en Cuenca, Ecuador (sin horario de verano) — detectar la zona del
/// dispositivo agregaría una dependencia (`flutter_timezone`) para un
/// problema que hoy no existe.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Guayaquil'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static void _onNotificationTap(NotificationResponse response) {
    final quoteId = response.payload;
    if (quoteId == null) return;
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => QuoteDetailPage(quoteId: quoteId)),
    );
  }

  /// El id de la notificación se deriva del `quoteId` — no hace falta
  /// guardar uno aparte en la tabla `Quotes`.
  static int _notificationId(String quoteId) => quoteId.hashCode & 0x7FFFFFFF;

  static Future<void> scheduleQuoteReminder({
    required String quoteId,
    required DateTime checkInDate,
    required int reminderDays,
    required String guestLabel,
  }) async {
    final fireDate = checkInDate.subtract(Duration(days: reminderDays));
    if (!fireDate.isAfter(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime(
      tz.local,
      fireDate.year,
      fireDate.month,
      fireDate.day,
      9,
    );

    await _plugin.zonedSchedule(
      id: _notificationId(quoteId),
      title: 'Cotización pendiente',
      body:
          '$guestLabel cotizó para el ${_formatDate(checkInDate)}. '
          'Volvé a contactarla.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'quote_reminders',
          'Recordatorios de cotización',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: quoteId,
    );
  }

  static Future<void> cancelQuoteReminder(String quoteId) =>
      _plugin.cancel(id: _notificationId(quoteId));
}
