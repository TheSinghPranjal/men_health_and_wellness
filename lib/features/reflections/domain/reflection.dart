import 'package:flutter/material.dart';

import '../../../app/theme/clay_tokens.dart';

enum QuestionType { single, multi }

@immutable
class ReflectionOption {
  const ReflectionOption(this.id, this.label, {this.exclusive = false});
  final String id;
  final String label;

  /// For multi-select: choosing this clears other options (e.g. "None").
  final bool exclusive;
}

@immutable
class ReflectionQuestion {
  const ReflectionQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    this.type = QuestionType.single,
    this.helper,
    this.optional = false,
  });

  final String id;
  final String prompt;
  final String? helper;
  final QuestionType type;
  final List<ReflectionOption> options;
  final bool optional;

  String labelFor(String optionId) =>
      options.firstWhere((o) => o.id == optionId, orElse: () => ReflectionOption(optionId, optionId)).label;
}

/// A private, optional self-reflection. Not a validated clinical
/// questionnaire and never produces a diagnosis or severity score.
@immutable
class Reflection {
  const Reflection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.icon,
    required this.tone,
    required this.questions,
  });

  final String id;
  final String title;
  final String subtitle;
  final String intro;
  final IconData icon;
  final ClayTone tone;
  final List<ReflectionQuestion> questions;
}

typedef ReflectionAnswers = Map<String, Set<String>>;

/// How strongly the summary suggests involving a clinician. These are care
/// navigation levels, not clinical severity.
enum CareLevel {
  selfCare(
    'Learning and self-care may be a good place to start',
    'Nothing in your answers stood out as needing a clinician right now. That is not the same as ruling out a health condition — if things change or you are worried, a clinician can help.',
  ),
  discuss(
    'Consider mentioning this at your next check-up',
    'Some answers suggest it could be worth raising with a clinician when convenient.',
  ),
  appointment(
    'Consider booking an appointment with a clinician',
    'Some of your answers are the kind of thing guidelines suggest discussing with a clinician.',
  ),
  prompt(
    'Seek medical advice soon',
    'One or more answers relate to symptoms that should be checked promptly. If symptoms are happening right now or are severe, use the emergency guidance.',
  );

  const CareLevel(this.title, this.explanation);
  final String title;
  final String explanation;
}

@immutable
class ReflectionOutcome {
  const ReflectionOutcome({
    required this.answerSummary,
    required this.reflectionPoints,
    required this.careLevel,
    required this.careReasons,
    required this.articleIds,
    this.showMentalHealthSupport = false,
    this.showExperiment = false,
  });

  /// (question prompt, chosen labels) in question order.
  final List<(String, String)> answerSummary;
  final List<String> reflectionPoints;
  final CareLevel careLevel;
  final List<String> careReasons;
  final List<String> articleIds;
  final bool showMentalHealthSupport;
  final bool showExperiment;
}

/// A saved reflection. Only answers are stored; the summary is recomputed
/// so improved rules apply to past entries without storing derived data.
@immutable
class ReflectionSession {
  const ReflectionSession({
    required this.id,
    required this.reflectionId,
    required this.completedAt,
    required this.answers,
  });

  final String id;
  final String reflectionId;
  final DateTime completedAt;
  final ReflectionAnswers answers;

  Map<String, dynamic> toJson() => {
    '_v': 1,
    'id': id,
    'reflectionId': reflectionId,
    'completedAt': completedAt.toIso8601String(),
    'answers': answers.map((k, v) => MapEntry(k, v.toList())),
  };

  static ReflectionSession? fromJson(Map<String, dynamic> json) {
    try {
      return ReflectionSession(
        id: json['id'] as String,
        reflectionId: json['reflectionId'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String),
        answers: (json['answers'] as Map).map((k, v) => MapEntry(k as String, (v as List).whereType<String>().toSet())),
      );
    } catch (_) {
      return null;
    }
  }
}
