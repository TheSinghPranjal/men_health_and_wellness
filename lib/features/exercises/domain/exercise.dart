import 'package:flutter/material.dart';

import '../../../app/theme/clay_tokens.dart';

enum ExerciseKind { pacedBreathing, steps }

@immutable
class Exercise {
  const Exercise({
    required this.id,
    required this.title,
    required this.summary,
    required this.minutes,
    required this.kind,
    required this.icon,
    required this.tone,
    this.steps = const [],
    this.inhaleSeconds = 4,
    this.exhaleSeconds = 6,
  });

  final String id;
  final String title;
  final String summary;
  final int minutes;
  final ExerciseKind kind;
  final IconData icon;
  final ClayTone tone;
  final List<String> steps;
  final int inhaleSeconds;
  final int exhaleSeconds;
}

/// Optional relaxation practices. Based on general NHS stress guidance;
/// they support wellbeing but do not treat any condition.
abstract final class Exercises {
  static const breathing = Exercise(
    id: 'breathing',
    title: 'Slow breathing',
    summary: 'A gentle 3-minute paced breath to settle the stress response.',
    minutes: 3,
    kind: ExerciseKind.pacedBreathing,
    icon: Icons.air_rounded,
    tone: ClayTone.teal,
  );

  static const relaxation = Exercise(
    id: 'relaxation',
    title: 'Progressive muscle relaxation',
    summary: 'Tense and release muscle groups to notice and let go of tension.',
    minutes: 6,
    kind: ExerciseKind.steps,
    icon: Icons.accessibility_new_rounded,
    tone: ClayTone.lavender,
    steps: [
      'Sit or lie somewhere comfortable. Breathe slowly for a few breaths.',
      'Curl your toes and tense your feet for about 5 seconds, then release for 10 seconds.',
      'Tense your calves and thighs, then release. Notice the difference.',
      'Gently tighten your stomach and lower back, then release.',
      'Make fists and tense your arms, then release.',
      'Lift your shoulders towards your ears, then let them drop.',
      'Scrunch your face gently, then soften your jaw and forehead.',
      'Take three slow breaths and notice how your body feels now.',
    ],
  );

  static const grounding = Exercise(
    id: 'grounding',
    title: 'Refocus on the senses',
    summary: 'Step out of "monitoring mode" by bringing attention back to sensation.',
    minutes: 3,
    kind: ExerciseKind.steps,
    icon: Icons.center_focus_strong_rounded,
    tone: ClayTone.sand,
    steps: [
      'Pause and take one slow breath.',
      'Notice five things you can see.',
      'Notice four things you can physically feel — warmth, texture, pressure.',
      'Notice three things you can hear.',
      'Notice two things you can smell, and one you can taste.',
      'When worried thoughts appear, label them "thinking" and return to a sensation.',
      'With a partner, this can mean focusing on touch and warmth instead of how you are "doing".',
    ],
  );

  static const all = [breathing, relaxation, grounding];
  static Exercise? byId(String id) => all.where((e) => e.id == id).firstOrNull;
}
