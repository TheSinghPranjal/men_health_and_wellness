import 'package:flutter/foundation.dart';

import '../../../shared/models/enums.dart';

/// Everything the app remembers about how the user wants it to behave.
/// Deliberately excludes names, orientation, relationship status and
/// medical history.
@immutable
class UserPreferences {
  const UserPreferences({
    this.onboardingComplete = false,
    this.adultConfirmed = false,
    this.goals = const {},
    this.ageRange,
    this.units = Units.metric,
    this.progressTrackingEnabled = false,
    this.trackedMetrics = const {},
    this.dailyRoutineEnabled = true,
    this.themeMode = AppThemeMode.system,
    this.appLockEnabled = false,
    this.discreetNotifications = true,
  });

  static const schemaVersion = 1;

  final bool onboardingComplete;
  final bool adultConfirmed;
  final Set<WellnessGoal> goals;
  final AgeRange? ageRange;
  final Units units;
  final bool progressTrackingEnabled;
  final Set<TrackedMetric> trackedMetrics;
  final bool dailyRoutineEnabled;
  final AppThemeMode themeMode;
  final bool appLockEnabled;
  final bool discreetNotifications;

  bool tracks(TrackedMetric m) => progressTrackingEnabled && trackedMetrics.contains(m);

  UserPreferences copyWith({
    bool? onboardingComplete,
    bool? adultConfirmed,
    Set<WellnessGoal>? goals,
    AgeRange? Function()? ageRange,
    Units? units,
    bool? progressTrackingEnabled,
    Set<TrackedMetric>? trackedMetrics,
    bool? dailyRoutineEnabled,
    AppThemeMode? themeMode,
    bool? appLockEnabled,
    bool? discreetNotifications,
  }) {
    return UserPreferences(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      adultConfirmed: adultConfirmed ?? this.adultConfirmed,
      goals: goals ?? this.goals,
      ageRange: ageRange != null ? ageRange() : this.ageRange,
      units: units ?? this.units,
      progressTrackingEnabled: progressTrackingEnabled ?? this.progressTrackingEnabled,
      trackedMetrics: trackedMetrics ?? this.trackedMetrics,
      dailyRoutineEnabled: dailyRoutineEnabled ?? this.dailyRoutineEnabled,
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      discreetNotifications: discreetNotifications ?? this.discreetNotifications,
    );
  }

  Map<String, dynamic> toJson() => {
    '_v': schemaVersion,
    'onboardingComplete': onboardingComplete,
    'adultConfirmed': adultConfirmed,
    'goals': goals.map((g) => g.name).toList(),
    'ageRange': ageRange?.name,
    'units': units.name,
    'progressTrackingEnabled': progressTrackingEnabled,
    'trackedMetrics': trackedMetrics.map((m) => m.name).toList(),
    'dailyRoutineEnabled': dailyRoutineEnabled,
    'themeMode': themeMode.name,
    'appLockEnabled': appLockEnabled,
    'discreetNotifications': discreetNotifications,
  };

  /// Tolerant parser: unknown or missing fields fall back to defaults.
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      onboardingComplete: json['onboardingComplete'] == true,
      adultConfirmed: json['adultConfirmed'] == true,
      goals: enumSetByNames(WellnessGoal.values, json['goals']),
      ageRange: enumByName(AgeRange.values, json['ageRange']),
      units: enumByName(Units.values, json['units']) ?? Units.metric,
      progressTrackingEnabled: json['progressTrackingEnabled'] == true,
      trackedMetrics: enumSetByNames(TrackedMetric.values, json['trackedMetrics']),
      dailyRoutineEnabled: json['dailyRoutineEnabled'] != false,
      themeMode: enumByName(AppThemeMode.values, json['themeMode']) ?? AppThemeMode.system,
      appLockEnabled: json['appLockEnabled'] == true,
      discreetNotifications: json['discreetNotifications'] != false,
    );
  }
}
