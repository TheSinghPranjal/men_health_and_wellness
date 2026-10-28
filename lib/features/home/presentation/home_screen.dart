import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/clay_tokens.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/widgets/clay_buttons.dart';
import '../../../core/widgets/clay_components.dart';
import '../../../core/widgets/clay_surface.dart';
import '../../education/data/article_repository.dart';
import '../../education/presentation/controllers/library_controller.dart';
import '../../education/presentation/widgets/article_widgets.dart';
import '../../habits/presentation/controllers/habit_controllers.dart';
import '../../habits/presentation/widgets/habit_widgets.dart';
import '../../health_hub/domain/health_topic.dart';
import '../../settings/presentation/controllers/preferences_controller.dart';
import '../domain/daily_plan.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(DateTime now) => switch (now.hour) {
    < 5 => 'Good evening',
    < 12 => 'Good morning',
    < 18 => 'Good afternoon',
    _ => 'Good evening',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    final prefs = ref.watch(preferencesProvider);
    final repo = ref.watch(articleRepositoryProvider);
    final recent = ref.watch(recentArticlesProvider);
    final bookmarks = ref.watch(bookmarkedArticlesProvider);
    final plan = DailyPlan.forDay(prefs.goals, now);
    final recommended = [
      for (final (g, id) in DailyPlan.recommendedArticles(prefs.goals))
        if (repo.byId(id) case final a?) (g, a),
    ];
    final continueReading = [...recent, ...bookmarks.where((b) => !recent.contains(b))].take(6).toList();

    return ClayPage(
      title: _greeting(now),
      subtitle: DailyPlan.messageFor(now),
      showBack: false,
      actions: [
        ClayIconButton(icon: Icons.search_rounded, tooltip: 'Search', onPressed: () => context.push(Routes.search)),
        ClayIconButton(
          icon: Icons.emergency_rounded,
          tooltip: 'Urgent help',
          iconColor: context.clay.critical,
          onPressed: () => context.push(Routes.emergency),
        ),
      ],
      children: [
        if (prefs.dailyRoutineEnabled) ...[_PlanHero(items: plan), const SizedBox(height: Gap.sm)],
        if (prefs.progressTrackingEnabled) const _ProgressSummary(),
        const SectionHeader('Explore your health'),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: HealthTopics.all.length,
            separatorBuilder: (_, _) => const SizedBox(width: Gap.lg),
            itemBuilder: (context, i) => _TopicChip(topic: HealthTopics.all[i]),
          ),
        ),
        if (continueReading.isNotEmpty) ...[
          SectionHeader('Continue learning', action: 'Saved', onAction: () => context.push(Routes.bookmarks)),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: continueReading.length,
              separatorBuilder: (_, _) => const SizedBox(width: Gap.lg),
              itemBuilder: (context, i) => ArticleTile(article: continueReading[i]),
            ),
          ),
        ],
        if (recommended.isNotEmpty) ...[
          const SectionHeader('Suggested for you'),
          for (final (g, a) in recommended.take(3)) ...[
            Padding(
              padding: const EdgeInsets.only(left: Gap.xs, bottom: Gap.xs),
              child: Text('Because you chose "${g.label.toLowerCase()}"', style: context.text.labelMedium),
            ),
            ArticleCard(article: a),
          ],
        ] else ...[
          const SectionHeader('Start here'),
          for (final id in const ['how-erections-work', 'desire-vs-arousal', 'performance-anxiety'])
            if (repo.byId(id) case final a?) ArticleCard(article: a),
        ],
        const SizedBox(height: Gap.md),
        ClaySurface(
          color: context.clay.tone(ClayTone.blue).fill,
          onTap: () => context.push(Routes.myths),
          semanticLabel: 'Myth versus evidence',
          child: Row(
            children: [
              ClayIconBadge(icon: Icons.fact_check_rounded, tone: ClayTone.blue),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Myth vs evidence',
                      style: context.text.titleMedium!.copyWith(color: context.clay.tone(ClayTone.blue).onFill),
                    ),
                    Text(
                      '"ED is inevitable with age." True?',
                      style: context.text.bodySmall!.copyWith(color: context.clay.tone(ClayTone.blue).onFill),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.clay.tone(ClayTone.blue).onFill),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanHero extends StatelessWidget {
  const _PlanHero({required this.items});
  final List<PlanItem> items;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    return ClaySurface(
      color: clay.brand,
      depth: 1.4,
      radius: ClayTheme.radiusLg,
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY\'S WELLNESS PLAN',
            style: context.text.labelSmall!.copyWith(color: clay.onBrand.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: Gap.xs),
          Text('A few small things, if you have time', style: context.text.titleLarge!.copyWith(color: clay.onBrand)),
          const SizedBox(height: Gap.lg),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: ClaySurface(
                color: clay.tone(item.tone).fill,
                radius: 20,
                depth: 0.8,
                padding: const EdgeInsets.all(Gap.md),
                onTap: () => context.push(item.route),
                semanticLabel: '${item.title}. ${item.detail}. ${item.reason ?? ''}',
                child: Row(
                  children: [
                    ClayIconBadge(icon: item.icon, tone: item.tone, size: 42),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: context.text.titleSmall!.copyWith(color: clay.tone(item.tone).onFill).weight(800),
                          ),
                          Text(
                            item.detail,
                            style: context.text.bodySmall!.copyWith(color: clay.tone(item.tone).onFill),
                          ),
                          if (item.reason != null)
                            Text(
                              item.reason!,
                              style: context.text.labelSmall!.copyWith(
                                color: clay.tone(item.tone).onFill.withValues(alpha: 0.75),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: clay.tone(item.tone).onFill),
                  ],
                ),
              ),
            ),
          Text(
            'Suggestions support general wellbeing; they are not a treatment.',
            style: context.text.bodySmall!.copyWith(color: clay.onBrand.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _ProgressSummary extends ConsumerWidget {
  const _ProgressSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(clockProvider)();
    final (done, scheduled) = ref.watch(habitStatsProvider).weekProgress(today);
    final habits = ref.watch(todaysHabitsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader('Routine', action: 'Progress', onAction: () => context.go(Routes.progress)),
        ClaySurface(
          child: Row(
            children: [
              ClayProgressRing(progress: scheduled == 0 ? 0 : done / scheduled, label: 'Routine completed this week'),
              const SizedBox(width: Gap.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Routine this week', style: context.text.titleMedium),
                    Text(
                      scheduled == 0 ? 'No habits planned yet' : '$done of $scheduled planned so far',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              ClayIconButton(
                icon: Icons.edit_note_rounded,
                tooltip: 'Check in',
                onPressed: () => context.push(Routes.checkIn),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.md),
        for (final h in habits.take(3)) HabitCard(habit: h),
        if (habits.isEmpty)
          ClayButton(
            label: 'Create your first habit',
            icon: Icons.add_rounded,
            variant: ClayButtonVariant.secondary,
            onPressed: () => context.push(Routes.habitNew),
          ),
      ],
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.topic});
  final HealthTopic topic;

  @override
  Widget build(BuildContext context) {
    final tone = context.clay.tone(topic.tone);
    return SizedBox(
      width: 150,
      child: ClaySurface(
        color: tone.fill,
        onTap: () => context.push(Routes.topic(topic.id)),
        semanticLabel: topic.title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClayIconBadge(icon: topic.icon, tone: topic.tone, size: 44),
            const Spacer(),
            Text(topic.title, maxLines: 2, style: context.text.titleSmall!.copyWith(color: tone.onFill).weight(800)),
          ],
        ),
      ),
    );
  }
}
