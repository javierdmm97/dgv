import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// OS push notification service for checkpoint alerts.
///
/// Call [init] from main() before runApp.
/// Call [showCheckpointAlert] when a group's measurement window opens.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'dgv_checkpoint_default';
  static const _channelName = 'Control Sorpresa';
  static const _channelDesc = 'Alertas de control de alcoholemia';

  /// Initialize the notification plugin and request permissions.
  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Show an immediate checkpoint alert for the given group name.
  static Future<void> showCheckpointAlert(String groupName) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.show(
      0,
      '🚨 Control Sorpresa',
      '¡$groupName, a soplar!',
      details,
    );
  }
}
