import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/utils/dates.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../../shared/models/enums.dart';
import '../../../daily_log/domain/daily_log.dart';
import '../../../daily_log/presentation/controllers/daily_log_controller.dart';
import '../../../education/presentation/controllers/library_controller.dart';
import '../../../habits/presentation/controllers/habit_controllers.dart';
import '../../../habits/presentation/widgets/habit_widgets.dart';
import '../../../settings/presentation/controllers/preferences_controller.dart';
import '../widgets/charts.dart';

class ProgressRangeController extends Notifier<int> {
  @override
  int build() => 7;
  void set(int days) => state = days;
}

final progressRangeProvider = NotifierProvider<ProgressRangeController, int>(ProgressRangeController.new);

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    if (!prefs.progressTrackingEnabled) {
      return ClayPage(
        title: 'Progress',
        showBack: false,
        children: [
          EmptyState(
            icon: Icons.insights_rounded,
            title: 'Tracking is off',
            message:
                'Progress tracking is optional. Choose only what you want to track — nothing about sexual activity is ever required.',
            action: 'Choose what to track',
            onAction: () => context.push(Routes.tracking),
          ),
          const SizedBox(height: Gap.lg),
          ClayListTile(
            title: 'Habits',
            subtitle: 'Build routines without tracking anything else',
            icon: Icons.add_task_rounded,
            tone: ClayTone.sage,
            onTap: () => context.push(Routes.habits),
          ),
        ],
      );
    }

    final today = ref.watch(clockProvider)();
    final range = ref.watch(progressRangeProvider);
    final logs = ref.watch(dailyLogProvider);
    final stats = ref.watch(habitStatsProvider);
    final habits = ref.watch(todaysHabitsProvider);
    final readOn = ref.watch(libraryProvider.select((s) => s.readOn));
    final days = Dates.lastNDays(today, range);
    final weekStart = Dates.startOfWeek(today);

    List<(DateTime, double?)> series(double? Function(DailyLog) pick) => [
      for (final d in days) (d, logs[Dates.key(d)] == null ? null : pick(logs[Dates.key(d)]!)),
    ];

    final weekLogs = [for (var i = 0; i < 7; i++) ?logs[Dates.key(weekStart.add(Duration(days: i)))]];
    final weekMinutes = weekLogs.fold<int>(0, (n, l) => n + (l.exerciseMinutes ?? 0));
    final weekRelax = weekLogs.fold<int>(0, (n, l) => n + l.relaxationSessions);
    final weekRead = readOn.values.where((k) => !Dates.parseKey(k).isBefore(weekStart)).length;
    final (habitDone, habitScheduled) = stats.weekProgress(today);

    return ClayPage(
      title: 'Progress',
      subtitle: 'Your habits and observations — no scores, no comparisons.',
      showBack: false,
      actions: [
        ClayIconButton(
          icon: Icons.tune_rounded,
          tooltip: 'Choose what to track',
          onPressed: () => context.push(Routes.tracking),
        ),
      ],
      children: [
        Row(
          children: [
            Expanded(
              child: ClayButton(
                label: 'Check in',
                icon: Icons.edit_note_rounded,
                onPressed: () => context.push(Routes.checkIn),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: ClayButton(
                label: 'History',
                icon: Icons.history_rounded,
                variant: ClayButtonVariant.secondary,
                onPressed: () => context.push(Routes.checkInHistory),
              ),
            ),
          ],
        ),
        const SectionHeader('This week'),
        Wrap(
          spacing: Gap.md,
          runSpacing: Gap.md,
          children: [
            if (prefs.tracks(TrackedMetric.wellnessActivities))
              _StatTile(
                label: 'Habits done',
                value: '$habitDone',
                detail: 'of $habitScheduled planned so far',
                metric: TrackedMetric.wellnessActivities,
              ),
            if (prefs.tracks(TrackedMetric.exercise))
              _StatTile(
                label: 'Active minutes',
                value: '$weekMinutes',
                detail: 'general guide: 150 a week',
                metric: TrackedMetric.exercise,
              ),
            if (prefs.tracks(TrackedMetric.stressSessions))
              _StatTile(
                label: 'Relaxation',
                value: '$weekRelax',
                detail: 'sessions',
                metric: TrackedMetric.stressSessions,
              ),
            if (prefs.tracks(TrackedMetric.learning))
              _StatTile(
                label: 'Articles read',
                value: '$weekRead',
                detail: 'new this week',
                metric: TrackedMetric.learning,
              ),
          ],
        ),
        SectionHeader('Today\'s habits', action: 'Manage', onAction: () => context.push(Routes.habits)),
        if (habits.isEmpty)
          EmptyState(
            icon: Icons.add_task_rounded,
            title: 'Nothing planned today',
            message: 'Rest days count too.',
            action: 'Add a habit',
            onAction: () => context.push(Routes.habitNew),
          )
        else
          for (final h in habits) HabitCard(habit: h),
        const SectionHeader('Trends'),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (final r in const [7, 30])
              ClayChoiceChip(
                label: '$r days',
                selected: range == r,
                onTap: () => ref.read(progressRangeProvider.notifier).set(r),
              ),
          ],
        ),
        const SizedBox(height: Gap.lg),
        if (prefs.tracks(TrackedMetric.energy))
          ChartCard(
            title: 'Energy',
            caption: 'Self-rated, 1 (drained) to 5 (energised)',
            unit: '/ 5',
            maxY: 5,
            points: series((l) => l.energy?.toDouble()),
          ),
        if (prefs.tracks(TrackedMetric.stress))
          ChartCard(
            title: 'Stress',
            caption: 'Self-rated, 1 (calm) to 5 (very stressed)',
            unit: '/ 5',
            maxY: 5,
            points: series((l) => l.stress?.toDouble()),
          ),
        if (prefs.tracks(TrackedMetric.sleep))
          ChartCard(
            title: 'Sleep quality',
            caption: 'Self-rated, 1 (poor) to 5 (great)',
            unit: '/ 5',
            maxY: 5,
            points: series((l) => l.sleepQuality?.toDouble()),
          ),
        if (prefs.tracks(TrackedMetric.desire))
          ChartCard(
            title: 'Desire',
            caption: 'Private, self-rated 1–5. Natural variation is normal.',
            unit: '/ 5',
            maxY: 5,
            points: series((l) => l.desire?.toDouble()),
          ),
        if (prefs.tracks(TrackedMetric.exercise))
          ChartCard(
            title: 'Active minutes',
            caption: 'Minutes you logged per day',
            unit: 'min',
            bars: true,
            points: series((l) => l.exerciseMinutes?.toDouble()),
          ),
        if (prefs.tracks(TrackedMetric.wellnessActivities))
          ChartCard(
            title: 'Habits completed',
            caption: 'Habits marked done per day',
            unit: 'habits',
            bars: true,
            points: [for (final (d, n) in stats.dailyCompletions(today, range)) (d, n.toDouble())],
          ),
        const SafetyPanel(
          title: 'Patterns, not proof',
          body:
              'Trends can show things moving together, but that does not prove one causes the other. Use them as prompts for reflection.',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.detail, required this.metric});
  final String label;
  final String value;
  final String detail;
  final TrackedMetric metric;

  @override
  Widget build(BuildContext context) {
    final tone = context.clay.tone(metric.tone);
    return LayoutBuilder(
      builder: (context, _) {
        final width = (MediaQuery.sizeOf(context).width - Gap.page * 2 - Gap.md) / 2;
        return SizedBox(
          width: width.clamp(140, 320),
          child: ClaySurface(
            color: tone.fill,
            semanticLabel: '$label: $value, $detail',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(metric.icon, color: tone.onFill),
                const SizedBox(height: Gap.sm),
                Text(value, style: context.text.headlineMedium!.copyWith(color: tone.onFill).weight(900)),
                Text(label, style: context.text.titleSmall!.copyWith(color: tone.onFill)),
                Text(detail, style: context.text.bodySmall!.copyWith(color: tone.onFill.withValues(alpha: 0.85))),
              ],
            ),
          ),
        );
      },
    );
  }
}
