import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
  }

  static Future<void> requestPermissions() async {
    await Permission.notification.request();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'ocean_hazard_channel',
      'Ocean Hazard Alerts',
      channelDescription: 'Notifications for ocean hazard events',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  static Future<void> showHazardAlert({
    required String title,
    required String body,
    required String hazardType,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🚨 $title',
      body: body,
      payload: 'hazard_alert:$hazardType',
    );
  }

  static Future<void> showReportConfirmation({
    required String reportId,
  }) async {
    await showNotification(
      id: reportId.hashCode,
      title: 'Report Submitted',
      body: 'Your ocean hazard report has been successfully submitted.',
      payload: 'report_confirmation:$reportId',
    );
  }
}
