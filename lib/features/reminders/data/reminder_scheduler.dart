import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/logging/app_logger.dart';
import '../domain/reminder.dart';

abstract interface class ReminderScheduler {
  Future<void> initialize();

  /// Asks the OS for permission. Returns false if denied or unsupported.
  Future<bool> requestPermission();
  Future<void> schedule(ReminderSpec spec);
  Future<void> cancel(String specId);
  Future<void> cancelAll();
}

/// Weekly repeating local notifications. No payloads are attached, so
/// nothing sensitive is passed to the OS beyond the visible text.
class LocalReminderScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'wellness_reminders',
      'Reminders',
      channelDescription: 'Optional reminders you set up',
      importance: Importance.defaultImportance,
      visibility: NotificationVisibility.private,
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> initialize() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (e, s) {
      AppLogger.error('reminders.timezone_failed', e, s);
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission() ??
            false;
      case TargetPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, sound: true) ??
            false;
      default:
        return false;
    }
  }

  @override
  Future<void> schedule(ReminderSpec spec) async {
    await initialize();
    await cancel(spec.id);
    for (final weekday in spec.weekdays) {
      await _plugin.zonedSchedule(
        id: notificationId(spec.id, weekday),
        title: spec.title,
        body: spec.body,
        scheduledDate: _next(weekday, spec.time.hour, spec.time.minute),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _next(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (date.weekday != weekday || !date.isAfter(now)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  @override
  Future<void> cancel(String specId) async {
    await initialize();
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(id: notificationId(specId, weekday));
    }
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) => LocalReminderScheduler());
