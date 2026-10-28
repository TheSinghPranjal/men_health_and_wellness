import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../settings/presentation/controllers/preferences_controller.dart';
import '../../data/reminder_repository.dart';
import '../../data/reminder_scheduler.dart';
import '../../domain/reminder.dart';

const wellnessReminderId = 'wellness';

class WellnessReminderController extends Notifier<WellnessReminder> {
  @override
  WellnessReminder build() => ref.watch(reminderRepositoryProvider).load();

  /// Permission is requested only here, when the user switches a reminder on.
  Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      final granted = await ref.read(reminderSchedulerProvider).requestPermission();
      if (!granted) {
        throw const PlatformFeatureException(
          'Notifications are turned off for this app. You can allow them in your device settings.',
        );
      }
    }
    await _apply(state.copyWith(enabled: enabled));
  }

  Future<void> setTime(TimeOfDay time) => _apply(state.copyWith(time: time));

  Future<void> toggleDay(int weekday) {
    final days = {...state.weekdays};
    days.contains(weekday) ? days.remove(weekday) : days.add(weekday);
    if (days.isEmpty) throw const ValidationException('Choose at least one day');
    return _apply(state.copyWith(weekdays: days));
  }

  /// Re-applies scheduling, e.g. after the wording preference changes.
  Future<void> resync() => _apply(state);

  Future<void> _apply(WellnessReminder next) async {
    await ref.read(reminderRepositoryProvider).save(next);
    state = next;
    final scheduler = ref.read(reminderSchedulerProvider);
    if (!next.enabled) {
      await scheduler.cancel(wellnessReminderId);
      return;
    }
    final (title, body) = ReminderWording.wellness(discreet: ref.read(preferencesProvider).discreetNotifications);
    await scheduler.schedule(
      ReminderSpec(id: wellnessReminderId, title: title, body: body, time: next.time, weekdays: next.weekdays),
    );
  }
}

final wellnessReminderProvider = NotifierProvider<WellnessReminderController, WellnessReminder>(
  WellnessReminderController.new,
);
