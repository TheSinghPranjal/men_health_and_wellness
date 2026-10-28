import 'package:flutter/material.dart';

import '../../../core/utils/dates.dart';

@immutable
class Habit {
  const Habit({
    required this.id,
    required this.title,
    this.description = '',
    this.weekdays = allDays,
    this.reminder,
    required this.startDate,
    this.active = true,
  });

  static const allDays = {1, 2, 3, 4, 5, 6, 7};
  static const maxTitle = 60;
  static const maxDescription = 200;

  final String id;
  final String title;
  final String description;

  /// ISO weekdays (Monday = 1).
  final Set<int> weekdays;
  final TimeOfDay? reminder;
  final DateTime startDate;
  final bool active;

  bool get isDaily => weekdays.length == 7;

  bool isScheduledOn(DateTime day) {
    final d = Dates.dayOf(day);
    return active && !d.isBefore(Dates.dayOf(startDate)) && weekdays.contains(d.weekday);
  }

  String get scheduleLabel {
    if (isDaily) return 'Every day';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = weekdays.toList()..sort();
    return sorted.map((d) => names[d - 1]).join(', ');
  }

  Habit copyWith({
    String? title,
    String? description,
    Set<int>? weekdays,
    TimeOfDay? Function()? reminder,
    DateTime? startDate,
    bool? active,
  }) => Habit(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    weekdays: weekdays ?? this.weekdays,
    reminder: reminder != null ? reminder() : this.reminder,
    startDate: startDate ?? this.startDate,
    active: active ?? this.active,
  );

  Map<String, dynamic> toJson() => {
    '_v': 1,
    'id': id,
    'title': title,
    'description': description,
    'weekdays': weekdays.toList()..sort(),
    'reminder': reminder == null ? null : {'h': reminder!.hour, 'm': reminder!.minute},
    'startDate': Dates.key(startDate),
    'active': active,
  };

  static Habit? fromJson(Map<String, dynamic> json) {
    try {
      final r = json['reminder'];
      final days = (json['weekdays'] as List).whereType<int>().where((d) => d >= 1 && d <= 7).toSet();
      return Habit(
        id: json['id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        weekdays: days.isEmpty ? allDays : days,
        reminder: r is Map ? TimeOfDay(hour: r['h'] as int, minute: r['m'] as int) : null,
        startDate: Dates.parseKey(json['startDate'] as String),
        active: json['active'] != false,
      );
    } catch (_) {
      return null;
    }
  }
}

abstract final class HabitValidator {
  static String? title(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty) return 'Give your habit a name';
    if (v.length > Habit.maxTitle) return 'Keep it under ${Habit.maxTitle} characters';
    return null;
  }

  static String? description(String? raw) =>
      (raw?.length ?? 0) > Habit.maxDescription ? 'Keep it under ${Habit.maxDescription} characters' : null;

  static String? weekdays(Set<int> days) => days.isEmpty ? 'Choose at least one day' : null;
}

/// Suggested starting points. Framed as wellness routines, never as
/// treatments.
@immutable
class HabitTemplate {
  const HabitTemplate(this.title, this.description, this.icon, {this.weekdays = Habit.allDays});
  final String title;
  final String description;
  final IconData icon;
  final Set<int> weekdays;

  static const all = [
    HabitTemplate('Brisk walk', '10–30 minutes at a pace that warms you up', Icons.directions_walk_rounded),
    HabitTemplate('Breathing practice', 'Three minutes of slow breathing', Icons.air_rounded),
    HabitTemplate('Wind-down routine', 'Screens off and a calm half hour before bed', Icons.bedtime_rounded),
    HabitTemplate(
      'Strength session',
      'Simple body-weight or gym exercises',
      Icons.fitness_center_rounded,
      weekdays: {1, 4},
    ),
    HabitTemplate('Read one article', 'Learn something from the library', Icons.menu_book_rounded, weekdays: {2, 5}),
    HabitTemplate('Alcohol-free day', 'A day off from drinking', Icons.local_drink_rounded, weekdays: {1, 2, 3}),
  ];
}
