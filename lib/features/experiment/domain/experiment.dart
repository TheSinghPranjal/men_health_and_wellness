import 'package:flutter/foundation.dart';

@immutable
class Observation {
  const Observation({required this.at, required this.text});
  final DateTime at;
  final String text;

  Map<String, dynamic> toJson() => {'at': at.toIso8601String(), 'text': text};
  static Observation? fromJson(Object? json) {
    if (json is! Map) return null;
    final at = DateTime.tryParse(json['at'] as String? ?? '');
    final text = json['text'];
    return at == null || text is! String ? null : Observation(at: at, text: text);
  }
}

/// A self-directed, voluntary experiment. There are deliberately no streaks
/// or success/failure states: the user sets the goal and decides what it means.
@immutable
class Experiment {
  const Experiment({
    required this.id,
    required this.goal,
    required this.startedAt,
    this.endedAt,
    this.observations = const [],
  });

  static const maxGoalLength = 200;
  static const maxObservationLength = 500;

  final String id;
  final String goal;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<Observation> observations;

  bool get active => endedAt == null;

  Experiment copyWith({DateTime? endedAt, List<Observation>? observations}) => Experiment(
    id: id,
    goal: goal,
    startedAt: startedAt,
    endedAt: endedAt ?? this.endedAt,
    observations: observations ?? this.observations,
  );

  Map<String, dynamic> toJson() => {
    '_v': 1,
    'id': id,
    'goal': goal,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'observations': observations.map((o) => o.toJson()).toList(),
  };

  static Experiment? fromJson(Map<String, dynamic> json) {
    try {
      return Experiment(
        id: json['id'] as String,
        goal: json['goal'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] == null ? null : DateTime.parse(json['endedAt'] as String),
        observations: [for (final o in (json['observations'] as List? ?? const [])) ?Observation.fromJson(o)],
      );
    } catch (_) {
      return null;
    }
  }

  static String? validateGoal(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty) return 'Describe your goal in your own words';
    if (v.length > maxGoalLength) return 'Keep it under $maxGoalLength characters';
    return null;
  }

  static String? validateObservation(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty) return 'Write a short observation';
    if (v.length > maxObservationLength) return 'Keep it under $maxObservationLength characters';
    return null;
  }
}
