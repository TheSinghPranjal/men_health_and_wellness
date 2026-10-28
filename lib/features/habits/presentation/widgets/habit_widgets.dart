import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../domain/habit.dart';
import '../controllers/habit_controllers.dart';

/// A habit with a one-tap "done today" control.
class HabitCard extends ConsumerWidget {
  const HabitCard({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clay = context.clay;
    final today = ref.watch(clockProvider)();
    final done = ref.watch(habitStatsProvider).isDone(habit, today);
    final scheduled = habit.isScheduledOn(today);

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: ClaySurface(
        onTap: () => context.push(Routes.habitEdit(habit.id)),
        semanticLabel: 'Edit habit ${habit.title}',
        color: done ? clay.tone(ClayTone.sage).fill : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: context.text.titleMedium!.copyWith(color: habit.active ? null : clay.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      habit.scheduleLabel,
                      if (habit.reminder != null) 'Reminder ${habit.reminder!.format(context)}',
                      if (!habit.active) 'Paused',
                    ].join(' · '),
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            if (scheduled) _DoneButton(habit: habit, done: done),
          ],
        ),
      ),
    );
  }
}

class _DoneButton extends ConsumerWidget {
  const _DoneButton({required this.habit, required this.done});
  final Habit habit;
  final bool done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clay = context.clay;
    return Semantics(
      container: true,
      button: true,
      checked: done,
      label: done ? '${habit.title} done today. Tap to undo.' : 'Mark ${habit.title} done today',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: 52,
          child: ClaySurface(
            radius: 18,
            depth: done ? 0.9 : 0.5,
            color: done ? clay.positive : clay.surfaceSunken,
            padding: EdgeInsets.zero,
            onTap: () async {
              HapticFeedback.lightImpact();
              try {
                await ref.read(habitCompletionsProvider.notifier).toggle(habit, ref.read(clockProvider)());
              } catch (e) {
                if (context.mounted) showClaySnack(context, userMessageFor(e));
              }
            },
            child: Icon(
              done ? Icons.check_rounded : Icons.add_rounded,
              color: done ? clay.surface : clay.textSecondary,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

/// Seven toggles, Monday first.
class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({super.key, required this.selected, required this.onToggle});
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  static const _short = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _long = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    return Row(
      children: [
        for (var d = 1; d <= 7; d++) ...[
          Expanded(
            child: ClaySurface(
              radius: 18,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: selected.contains(d) ? const Color(0xFF1E6E66) : clay.surfaceSunken,
              depth: selected.contains(d) ? 0.8 : 0.2,
              onTap: () => onToggle(d),
              semanticLabel: '${_long[d - 1]}${selected.contains(d) ? ', selected' : ''}',
              child: Center(
                child: Text(
                  _short[d - 1],
                  style: context.text.titleSmall!.copyWith(
                    color: selected.contains(d) ? Colors.white : clay.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          if (d < 7) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
