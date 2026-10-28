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
import '../../education/domain/article.dart';
import '../../education/presentation/widgets/article_widgets.dart';
import '../../education/presentation/widgets/topic_layout.dart';
import '../../habits/presentation/controllers/habit_controllers.dart';
import '../../habits/presentation/widgets/habit_widgets.dart';
import '../../health_hub/domain/health_topic.dart';
import '../../settings/presentation/controllers/preferences_controller.dart';
import '../domain/daily_plan.dart';
import 'home_art.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Topics shown before "View all" expands the grid.
  static const _collapsedTopics = 6;
  bool _showAllTopics = false;

  String _greeting(DateTime now) => switch (now.hour) {
    < 5 => 'Good evening',
    < 12 => 'Good morning',
    < 18 => 'Good afternoon',
    _ => 'Good evening',
  };

  @override
  Widget build(BuildContext context) {
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

    final topics = _showAllTopics ? HealthTopics.all : HealthTopics.all.take(_collapsedTopics).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _HomeHeader(greeting: _greeting(now))),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(Gap.page, 0, Gap.page, Gap.xxl + MediaQuery.paddingOf(context).bottom),
              sliver: SliverList.list(
                children: [
                  if (prefs.progressTrackingEnabled) const _ProgressSummary(),
                  if (prefs.dailyRoutineEnabled) ...[const SizedBox(height: Gap.lg), _PlanHero(items: plan)],
                  SectionHeader(
                    'Explore your health',
                    action: HealthTopics.all.length > _collapsedTopics
                        ? (_showAllTopics ? 'Show less' : 'View all')
                        : null,
                    onAction: () => setState(() => _showAllTopics = !_showAllTopics),
                  ),
                  ClayGrid(minTileHeight: 150, children: [for (final t in topics) _TopicCard(topic: t)]),
                  if (continueReading.isNotEmpty) ...[
                    SectionHeader('Continue learning', action: 'Saved', onAction: () => context.push(Routes.bookmarks)),
                    for (final a in continueReading.take(3)) _ContinueCard(article: a),
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
                                style: context.text.titleMedium!.copyWith(
                                  color: context.clay.tone(ClayTone.blue).onFill,
                                ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.greeting});
  final String greeting;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    return LayoutBuilder(
      builder: (context, box) {
        final artWidth = (box.maxWidth * 0.55).clamp(180.0, 320.0);
        final textWidth = box.maxWidth - Gap.page * 2 - artWidth * 0.35;
        return Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: ExcludeSemantics(child: SunriseArt(width: artWidth)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.page, Gap.md, Gap.page, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ClayIconButton(
                        icon: Icons.search_rounded,
                        tooltip: 'Search',
                        onPressed: () => context.push(Routes.search),
                      ),
                      const SizedBox(width: Gap.sm),
                      ClayIconButton(
                        icon: Icons.emergency_rounded,
                        tooltip: 'Urgent help',
                        iconColor: clay.critical,
                        onPressed: () => context.push(Routes.emergency),
                      ),
                    ],
                  ),
                  Text('$greeting \u{1F44B}', style: context.text.bodyLarge!.copyWith(color: clay.textSecondary)),
                  const SizedBox(height: Gap.xs),
                  SizedBox(
                    width: textWidth,
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Your health.\nA stronger you.',
                        style: context.text.headlineMedium!.copyWith(fontSize: 32, height: 1.12),
                      ),
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                  SizedBox(
                    width: textWidth,
                    child: Text(
                      'Learn, build healthy habits and improve your sexual and overall well-being.',
                      style: context.text.bodyMedium!.copyWith(color: clay.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
          padding: const EdgeInsets.all(Gap.md),
          child: Column(
            children: [
              Stack(
                children: [
                  const Positioned(
                    right: 40,
                    top: 0,
                    bottom: 0,
                    child: ExcludeSemantics(child: ChecklistArt(width: 92)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(Gap.sm),
                    child: Row(
                      children: [
                        ClayProgressRing(
                          progress: scheduled == 0 ? 0 : done / scheduled,
                          label: 'Routine completed this week',
                          size: 76,
                        ),
                        const SizedBox(width: Gap.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Routine this week', style: context.text.titleMedium!.weight(800)),
                              const SizedBox(height: 2),
                              Text(
                                scheduled == 0 ? 'No habits planned yet' : '$done of $scheduled planned so far',
                                style: context.text.bodySmall,
                              ),
                              if (scheduled == 0) Text('Start with a small step today.', style: context.text.bodySmall),
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
                ],
              ),
              if (habits.isEmpty) ...[
                const SizedBox(height: Gap.sm),
                ClaySurface(
                  color: _routineTeal,
                  radius: 20,
                  depth: 0.9,
                  padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: 15),
                  onTap: () => context.push(Routes.habitNew),
                  semanticLabel: 'Create your first habit',
                  child: ExcludeSemantics(
                    child: Row(
                      children: [
                        const Spacer(),
                        const Icon(Icons.add_rounded, color: Colors.white),
                        const SizedBox(width: Gap.sm),
                        Flexible(
                          child: Text(
                            'Create your first habit',
                            style: context.text.labelLarge!.copyWith(color: Colors.white).weight(800),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.85)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (habits.isNotEmpty) ...[const SizedBox(height: Gap.md), for (final h in habits.take(3)) HabitCard(habit: h)],
      ],
    );
  }
}

/// Deep teal used for the routine call to action in both themes.
const _routineTeal = Color(0xFF1E5F5B);

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});
  final HealthTopic topic;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final tone = clay.tone(topic.tone);
    return ClaySurface(
      color: tone.fill,
      padding: EdgeInsets.zero,
      onTap: () => context.push(Routes.topic(topic.id)),
      semanticLabel: '${topic.title}. ${topic.subtitle}',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ClayTheme.radiusMd),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(tone.fill, clay.surface, 0.5)!, tone.fill],
              ),
            ),
            child: Stack(
              children: [
                // Oversized faded watermark of the topic icon.
                Positioned(
                  right: -14,
                  top: 4,
                  child: Icon(topic.icon, size: 96, color: tone.onFill.withValues(alpha: 0.07)),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopicBadge(icon: topic.icon, tone: topic.tone, size: 44),
                      const SizedBox(height: Gap.md),
                      Text(
                        topic.title,
                        maxLines: 2,
                        style: context.text.titleSmall!.copyWith(color: tone.onFill).weight(800),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              topic.subtitle,
                              style: context.text.bodySmall!.copyWith(color: tone.onFill.withValues(alpha: 0.8)),
                            ),
                          ),
                          const SizedBox(width: Gap.xs),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: clay.surface.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.chevron_right_rounded, size: 18, color: tone.onFill),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wide card for an article the user has opened or saved.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: ClaySurface(
        padding: EdgeInsets.zero,
        onTap: () => context.push(Routes.article(article.id)),
        semanticLabel: 'Continue reading: ${article.title}. ${article.readMinutes} minute read.',
        child: ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ClayTheme.radiusMd),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          TopicBadge(icon: article.category.icon, tone: article.category.tone, size: 44),
                          const SizedBox(width: Gap.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  article.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleSmall!.weight(800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${article.category.label} · ${article.readMinutes} min read',
                                  style: context.text.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ArticleArtTile(category: article.category, width: 84),
                      Positioned(
                        right: Gap.sm,
                        child: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
