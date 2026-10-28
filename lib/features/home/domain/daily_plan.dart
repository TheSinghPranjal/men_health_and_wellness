import 'package:flutter/material.dart';

import '../../../app/route_names.dart';
import '../../../app/theme/clay_tokens.dart';
import '../../../shared/models/enums.dart';

@immutable
class PlanItem {
  const PlanItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.icon,
    required this.tone,
    required this.route,
    this.reason,
  });
  final String id;
  final String title;
  final String detail;
  final IconData icon;
  final ClayTone tone;
  final String route;

  /// Shown to the user so personalisation is never a black box.
  final String? reason;

  PlanItem because(String r) =>
      PlanItem(id: id, title: title, detail: detail, icon: icon, tone: tone, route: route, reason: r);
}

/// Transparent, rule-based suggestions. Completing them supports general
/// wellbeing; they are not presented as treatment.
abstract final class DailyPlan {
  static const _walk = PlanItem(
    id: 'walk',
    title: 'Take a brisk walk',
    detail: '10–30 minutes, at a pace that warms you up',
    icon: Icons.directions_walk_rounded,
    tone: ClayTone.sage,
    route: '/article/exercise-for-sexual-health',
  );
  static const _breathe = PlanItem(
    id: 'breathe',
    title: 'Three minutes of slow breathing',
    detail: 'Settle the stress response',
    icon: Icons.air_rounded,
    tone: ClayTone.teal,
    route: '/exercise/breathing',
  );
  static const _sleep = PlanItem(
    id: 'sleep',
    title: 'Plan a wind-down tonight',
    detail: 'Screens off 30 minutes before bed',
    icon: Icons.bedtime_rounded,
    tone: ClayTone.lavender,
    route: '/article/sleep-and-sexual-wellbeing',
  );
  static const _talk = PlanItem(
    id: 'talk',
    title: 'Review a conversation tip',
    detail: 'Low-pressure ways to talk about intimacy',
    icon: Icons.forum_rounded,
    tone: ClayTone.teal,
    route: '/article/talking-with-partner',
  );
  static const _checkIn = PlanItem(
    id: 'checkin',
    title: 'Quick check-in',
    detail: 'Energy, stress and sleep — 30 seconds',
    icon: Icons.edit_note_rounded,
    tone: ClayTone.peach,
    route: Routes.checkIn,
  );
  static const _ground = PlanItem(
    id: 'ground',
    title: 'Refocus on the senses',
    detail: 'A tool for stepping out of "monitoring mode"',
    icon: Icons.center_focus_strong_rounded,
    tone: ClayTone.sand,
    route: '/exercise/grounding',
  );
  static const _prep = PlanItem(
    id: 'prep',
    title: 'Start an appointment checklist',
    detail: 'Organise what to tell a clinician',
    icon: Icons.checklist_rounded,
    tone: ClayTone.blue,
    route: Routes.clinicianPrep,
  );

  static String _articleFor(WellnessGoal g) => switch (g) {
    WellnessGoal.erections => 'how-erections-work',
    WellnessGoal.desire => 'libido-variation',
    WellnessGoal.ejaculation => 'understanding-pe',
    WellnessGoal.anxiety => 'performance-anxiety',
    WellnessGoal.energy => 'fatigue-and-energy',
    WellnessGoal.intimacy => 'foreplay-and-arousal',
    WellnessGoal.fitness => 'eating-for-vascular-health',
    WellnessGoal.care => 'when-to-see-clinician',
  };

  /// Suggested article for each selected goal, in goal order.
  static List<(WellnessGoal, String)> recommendedArticles(Set<WellnessGoal> goals) => [
    for (final g in WellnessGoal.values)
      if (goals.contains(g)) (g, _articleFor(g)),
  ];

  /// Up to [max] suggestions for [day], rotated daily so the plan stays fresh.
  static List<PlanItem> forDay(Set<WellnessGoal> goals, DateTime day, {int max = 3}) {
    final candidates = <PlanItem>[];
    void add(PlanItem item, String reason) {
      if (candidates.every((c) => c.id != item.id)) candidates.add(item.because(reason));
    }

    for (final g in WellnessGoal.values.where(goals.contains)) {
      final why = 'Because you chose "${g.label.toLowerCase()}"';
      switch (g) {
        case WellnessGoal.erections:
        case WellnessGoal.fitness:
          add(_walk, why);
        case WellnessGoal.anxiety:
        case WellnessGoal.ejaculation:
          add(_breathe, why);
          add(_ground, why);
        case WellnessGoal.energy:
        case WellnessGoal.desire:
          add(_sleep, why);
          add(_checkIn, why);
        case WellnessGoal.intimacy:
          add(_talk, why);
        case WellnessGoal.care:
          add(_prep, why);
      }
    }
    if (candidates.length < max) {
      for (final item in [_walk, _breathe, _sleep]) {
        add(item, 'A general wellbeing basic');
      }
    }
    final dayIndex = day.difference(DateTime(day.year)).inDays;
    final offset = candidates.isEmpty ? 0 : dayIndex % candidates.length;
    final rotated = [...candidates.skip(offset), ...candidates.take(offset)];
    return rotated.take(max).toList();
  }

  static const messages = [
    'Small, steady steps count. There is no finish line here.',
    'Bodies vary day to day. Be as kind to yourself as you would to a friend.',
    'Curiosity beats criticism. Notice, don\'t judge.',
    'Sleep, movement and calm support almost everything — including intimacy.',
    'Asking for help is a strength, and clinicians discuss this every day.',
    'Connection matters more than performance.',
    'Rest days are part of the routine.',
  ];

  static String messageFor(DateTime day) => messages[day.difference(DateTime(day.year)).inDays % messages.length];
}
