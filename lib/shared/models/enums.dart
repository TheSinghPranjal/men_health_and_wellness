import 'package:flutter/material.dart';

import '../../app/theme/clay_tokens.dart';

/// Goals chosen during onboarding. Used only for transparent, rule-based
/// personalisation on this device.
enum WellnessGoal {
  erections('Understand erections and erectile health', Icons.favorite_rounded),
  desire('Improve sexual desire', Icons.local_fire_department_rounded),
  ejaculation('Learn about ejaculation control', Icons.timelapse_rounded),
  anxiety('Reduce performance anxiety', Icons.self_improvement_rounded),
  energy('Improve sleep, energy and stress', Icons.bedtime_rounded),
  intimacy('Learn about foreplay and communication', Icons.forum_rounded),
  fitness('Improve general physical health', Icons.directions_walk_rounded),
  care('Know when to seek medical help', Icons.medical_services_rounded);

  const WellnessGoal(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum AgeRange {
  r18to29('18–29'),
  r30to39('30–39'),
  r40to49('40–49'),
  r50to59('50–59'),
  r60plus('60+');

  const AgeRange(this.label);
  final String label;
}

enum Units {
  metric('Metric'),
  imperial('Imperial');

  const Units(this.label);
  final String label;
}

enum AppThemeMode {
  system('System', ThemeMode.system),
  light('Light', ThemeMode.light),
  dark('Dark', ThemeMode.dark);

  const AppThemeMode(this.label, this.mode);
  final String label;
  final ThemeMode mode;
}

/// Metrics a user can opt in to tracking. Nothing is tracked by default and
/// sexual activity itself is never a metric.
enum TrackedMetric {
  exercise('Exercise sessions', Icons.directions_run_rounded, ClayTone.sage),
  sleep('Sleep quality', Icons.bedtime_rounded, ClayTone.lavender),
  stressSessions('Relaxation sessions', Icons.spa_rounded, ClayTone.teal),
  wellnessActivities('Wellness habits', Icons.check_circle_rounded, ClayTone.blue),
  learning('Articles read', Icons.menu_book_rounded, ClayTone.sand),
  energy('Energy (self-rated)', Icons.bolt_rounded, ClayTone.peach),
  stress('Stress (self-rated)', Icons.waves_rounded, ClayTone.slate),
  desire('Desire reflections', Icons.local_fire_department_rounded, ClayTone.rose),
  reflections('Sexual-health reflections', Icons.psychology_rounded, ClayTone.blue);

  const TrackedMetric(this.label, this.icon, this.tone);
  final String label;
  final IconData icon;
  final ClayTone tone;
}

T? enumByName<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

Set<T> enumSetByNames<T extends Enum>(List<T> values, Object? names) {
  if (names is! List) return <T>{};
  return {for (final n in names) ?enumByName(values, n)};
}
