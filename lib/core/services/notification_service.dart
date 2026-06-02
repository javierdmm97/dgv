import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// OS notification service for checkpoint timers.
///
/// Shows one **ongoing countdown notification per group** using Android's
/// native chronometer. The OS renders the live ticking counter from the
/// target timestamp — no background execution or exact-alarm permission needed.
///
/// Call [init] from main() before runApp.
/// Call [showGroupTimer] when a group's window is set up.
/// Call [cancelGroupTimer] when a group is measured.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  // Channel for ongoing timer notifications (persistent, cannot be dismissed).
  static const _timerChannelId = 'dgv_group_timers';
  static const _timerChannelName = 'Temporizadores de Grupo';
  static const _timerChannelDesc =
      'Cuenta atrás en curso para cada grupo del control';

  // Separate channel for "due now" alerts — Android locks importance per channel
  // after first creation, so this must be distinct from the low-importance timer channel.
  static const _dueChannelId = 'dgv_group_due';
  static const _dueChannelName = 'Alertas de Medición';
  static const _dueChannelDesc =
      'Aviso cuando llega el momento de medir un grupo';

  /// Base notification ID — group 0 → 200, group 1 → 201, …
  static const _baseId = 200;

  /// Initialize the plugin and request notification permissions.
  static Future<void> init() async {
    tz_data.initializeTimeZones();

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

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImpl?.requestNotificationsPermission();
  }

  /// Show (or replace) an ongoing countdown notification for [groupIndex].
  ///
  /// The notification uses Android's native chronometer counting down to
  /// [expiresAt], so it ticks automatically without any app involvement.
  static Future<void> showGroupTimer(
    int groupIndex,
    String groupLabel,
    DateTime expiresAt,
    int round,
  ) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _timerChannelId,
        _timerChannelName,
        channelDescription: _timerChannelDesc,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: true,
        when: expiresAt.millisecondsSinceEpoch,
        usesChronometer: true,
        chronometerCountDown: true,
        enableVibration: false,
        playSound: false,
        // Blue color strip on the left of the notification.
        color: const Color(0xFF003DA5),
        colorized: true,
        channelShowBadge: false,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      await _plugin.show(
        _baseId + groupIndex,
        '⏱ $groupLabel — Ronda $round',
        'Próxima medición',
        NotificationDetails(android: androidDetails, iOS: darwinDetails),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] showGroupTimer failed: $e');
      }
    }
  }

  /// Show (or replace) a persistent "measure now" alert for [groupIndex].
  ///
  /// Called when the countdown hits zero. Uses high importance + vibration to
  /// produce a heads-up notification. Replaces the countdown notification.
  static Future<void> showGroupDue(
    int groupIndex,
    String groupLabel,
    int round,
  ) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _dueChannelId,
        _dueChannelName,
        channelDescription: _dueChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        playSound: false,
        color: const Color(0xFFD32F2F),
        colorized: true,
        channelShowBadge: false,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      await _plugin.show(
        _baseId + groupIndex,
        '🚨 $groupLabel — Ronda $round',
        '¡Puedes medir al $groupLabel ahora!',
        NotificationDetails(android: androidDetails, iOS: darwinDetails),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] showGroupDue failed: $e');
      }
    }
  }

  /// Schedule a native OS alarm that fires at [scheduledAt] and replaces the
  /// countdown notification with the "measure now" alert.
  ///
  /// Uses [zonedSchedule] so the OS delivers it even when the app is in the
  /// background, screen is off, or the Dart isolate has been suspended.
  /// The same notification ID as [showGroupTimer] ensures the countdown is
  /// replaced atomically when the alarm fires.
  static Future<void> scheduleGroupDue(
    int groupIndex,
    String groupLabel,
    DateTime scheduledAt,
    int round,
  ) async {
    try {
      final scheduledTZ = tz.TZDateTime.from(scheduledAt, tz.local);
      final androidDetails = AndroidNotificationDetails(
        _dueChannelId,
        _dueChannelName,
        channelDescription: _dueChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        playSound: false,
        color: const Color(0xFFD32F2F),
        colorized: true,
        channelShowBadge: false,
      );
      await _plugin.zonedSchedule(
        _baseId + groupIndex,
        '🚨 $groupLabel — Ronda $round',
        '¡Puedes medir al $groupLabel ahora!',
        scheduledTZ,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] scheduleGroupDue failed: $e');
      }
    }
  }

  /// Cancel the countdown notification for [groupIndex].
  static Future<void> cancelGroupTimer(int groupIndex) async {
    try {
      await _plugin.cancel(_baseId + groupIndex);
    } catch (_) {}
  }

  /// Cancel all pending/ongoing notifications.
  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
