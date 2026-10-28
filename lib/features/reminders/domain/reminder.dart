import 'package:flutter/material.dart';

/// What the scheduler needs. Titles and bodies are composed by
/// [ReminderWording] so lock-screen text is discreet by default.
@immutable
class ReminderSpec {
  const ReminderSpec({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.weekdays,
  });
  final String id;
  final String title;
  final String body;
  final TimeOfDay time;
  final Set<int> weekdays;
}

/// The general daily wellness reminder configured in settings.
@immutable
class WellnessReminder {
  const WellnessReminder({
    this.enabled = false,
    this.time = const TimeOfDay(hour: 20, minute: 0),
    this.weekdays = const {1, 2, 3, 4, 5, 6, 7},
  });
  final bool enabled;
  final TimeOfDay time;
  final Set<int> weekdays;

  WellnessReminder copyWith({bool? enabled, TimeOfDay? time, Set<int>? weekdays}) =>
      WellnessReminder(enabled: enabled ?? this.enabled, time: time ?? this.time, weekdays: weekdays ?? this.weekdays);

  Map<String, dynamic> toJson() => {
    '_v': 1,
    'enabled': enabled,
    'h': time.hour,
    'm': time.minute,
    'weekdays': weekdays.toList()..sort(),
  };

  factory WellnessReminder.fromJson(Map<String, dynamic> json) {
    final days = (json['weekdays'] as List?)?.whereType<int>().toSet() ?? const {1, 2, 3, 4, 5, 6, 7};
    return WellnessReminder(
      enabled: json['enabled'] == true,
      time: TimeOfDay(hour: (json['h'] as int?) ?? 20, minute: (json['m'] as int?) ?? 0),
      weekdays: days.isEmpty ? const {1, 2, 3, 4, 5, 6, 7} : days,
    );
  }
}

abstract final class ReminderWording {
  static const discreetTitle = 'Reminder';
  static const discreetBody = 'Your wellness reminder is ready.';

  static (String, String) wellness({required bool discreet}) =>
      discreet ? (discreetTitle, discreetBody) : ('Daily check-in', 'A minute for your wellness routine.');

  /// User-written habit titles are shown only when discreet mode is off.
  static (String, String) habit(String habitTitle, {required bool discreet}) =>
      discreet ? (discreetTitle, discreetBody) : ('Habit reminder', habitTitle);
}

/// Stable 31-bit notification id for (spec, weekday). FNV-1a hash.
int notificationId(String specId, int weekday) {
  var hash = 0x811c9dc5;
  for (final c in '$specId#$weekday'.codeUnits) {
    hash ^= c;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}
