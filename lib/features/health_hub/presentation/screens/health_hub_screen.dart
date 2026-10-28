import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_config.dart';
import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../education/data/article_repository.dart';
import '../../../education/presentation/widgets/article_widgets.dart';
import '../../../exercises/domain/exercise.dart';
import '../../../reflections/domain/reflection_catalog.dart';
import '../../../reflections/presentation/controllers/reflection_controllers.dart';
import '../../domain/health_topic.dart';

class HealthHubScreen extends ConsumerWidget {
  const HealthHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedCount = ref.watch(reflectionHistoryProvider).length;
    return ClayPage(
      title: 'My Health',
      subtitle: 'Explore topics, reflect privately, and know when to get help.',
      showBack: false,
      children: [
        const EmergencyBanner(),
        const SizedBox(height: Gap.lg),
        ClayGrid(minTileHeight: 156, children: [for (final t in HealthTopics.all) _TopicCard(topic: t)]),
        const SectionHeader('Private reflections'),
        Text(
          'Optional questions that help you organise your thoughts. Never a diagnosis.',
          style: context.text.bodySmall,
        ),
        const SizedBox(height: Gap.md),
        for (final r in ReflectionCatalog.all)
          ClayListTile(
            title: r.title,
            subtitle: r.subtitle,
            icon: r.icon,
            tone: r.tone,
            onTap: () => context.push(Routes.reflection(r.id)),
          ),
        ClayListTile(
          title: 'Saved reflections',
          subtitle: savedCount == 0 ? 'None saved' : '$savedCount saved on this device',
          icon: Icons.inventory_2_outlined,
          onTap: () => context.push(Routes.reflectionHistory),
        ),
        const SectionHeader('Care & support'),
        ClayListTile(
          title: 'Prepare for an appointment',
          subtitle: 'A private checklist to take to a clinician',
          icon: Icons.checklist_rounded,
          tone: ClayTone.blue,
          onTap: () => context.push(Routes.clinicianPrep),
        ),
        ClayListTile(
          title: 'When to see a clinician',
          subtitle: 'Signs that deserve a professional opinion',
          icon: Icons.medical_services_rounded,
          tone: ClayTone.rose,
          onTap: () => context.push(Routes.article('when-to-see-clinician')),
        ),
        if (AppConfig.standard.enablePersonalExperiment)
          ClayListTile(
            title: 'Personal experiment',
            subtitle: 'Set your own goal and observe privately',
            icon: Icons.science_outlined,
            tone: ClayTone.slate,
            onTap: () => context.push(Routes.experiment),
          ),
        const SectionHeader('Relax & reset'),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: Exercises.all.length,
            separatorBuilder: (_, _) => const SizedBox(width: Gap.lg),
            itemBuilder: (context, i) => ExerciseTile(exercise: Exercises.all[i]),
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});
  final HealthTopic topic;

  @override
  Widget build(BuildContext context) {
    final tone = context.clay.tone(topic.tone);
    return ClaySurface(
      color: tone.fill,
      onTap: () => context.push(Routes.topic(topic.id)),
      semanticLabel: '${topic.title}. ${topic.subtitle}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClayIconBadge(icon: topic.icon, tone: topic.tone, size: 44),
          const Spacer(),
          const SizedBox(height: Gap.md),
          Text(
            topic.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleMedium!.copyWith(color: tone.onFill).weight(800),
          ),
          const SizedBox(height: 2),
          Text(
            topic.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall!.copyWith(color: tone.onFill.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}

/// Always-visible route to emergency guidance; never gated.
class EmergencyBanner extends StatelessWidget {
  const EmergencyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    return ClaySurface(
      color: clay.tone(ClayTone.rose).fill,
      onTap: () => context.push(Routes.emergency),
      semanticLabel: 'Urgent help. Emergency warning signs.',
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
      child: Row(
        children: [
          Icon(Icons.emergency_rounded, color: clay.critical),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Text(
              'Urgent help: emergency warning signs',
              style: context.text.titleSmall!.copyWith(color: clay.tone(ClayTone.rose).onFill),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: clay.tone(ClayTone.rose).onFill),
        ],
      ),
    );
  }
}

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({super.key, required this.exercise});
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final tone = context.clay.tone(exercise.tone);
    return SizedBox(
      width: 200,
      child: ClaySurface(
        color: tone.fill,
        onTap: () => context.push(Routes.exercise(exercise.id)),
        semanticLabel: '${exercise.title}, ${exercise.minutes} minutes',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(exercise.icon, color: tone.onFill, size: 28),
            const Spacer(),
            Text(exercise.title, maxLines: 2, style: context.text.titleMedium!.copyWith(color: tone.onFill)),
            Text('${exercise.minutes} min', style: context.text.labelMedium!.copyWith(color: tone.onFill)),
          ],
        ),
      ),
    );
  }
}

class TopicScreen extends ConsumerWidget {
  const TopicScreen({super.key, required this.topicId});
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = HealthTopics.byId(topicId);
    if (topic == null) {
      return const ClayPage(
        title: 'Topic',
        children: [EmptyState(icon: Icons.search_off_rounded, title: 'Topic not found', message: 'Try My Health.')],
      );
    }
    final repo = ref.watch(articleRepositoryProvider);
    final articles = [for (final c in topic.categories) ...repo.byCategory(c)];
    final reflection = topic.reflectionId == null ? null : ReflectionCatalog.byId(topic.reflectionId!);
    final tone = context.clay.tone(topic.tone);

    return ClayPage(
      title: topic.title,
      subtitle: topic.subtitle,
      children: [
        ClaySurface(
          color: tone.fill,
          depth: 1.3,
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClayIconBadge(icon: topic.icon, tone: topic.tone, size: 56),
              const SizedBox(height: Gap.lg),
              Text(topic.intro, style: context.text.bodyLarge!.copyWith(color: tone.onFill)),
            ],
          ),
        ),
        if (reflection != null) ...[
          const SizedBox(height: Gap.lg),
          ClayButton(
            label: 'Start the ${reflection.title.toLowerCase()}',
            icon: Icons.psychology_rounded,
            onPressed: () => context.push(Routes.reflection(reflection.id)),
          ),
        ],
        if (topic.guide.isNotEmpty) ...[
          SectionHeader(topic.guideTitle ?? 'Guide'),
          ClaySurface(child: BulletList(topic.guide, icon: Icons.chat_bubble_outline_rounded, iconSize: 16)),
        ],
        if (topic.tools.isNotEmpty) ...[
          const SectionHeader('Tools'),
          for (final tool in topic.tools) _ToolTile(tool: tool),
        ],
        const SectionHeader('Read'),
        for (final a in articles) ArticleCard(article: a),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool});
  final TopicTool tool;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon, tone, route) = switch (tool) {
      TopicTool.clinicianPrep => (
        'Appointment checklist',
        'Prepare what to tell a clinician',
        Icons.checklist_rounded,
        ClayTone.blue,
        Routes.clinicianPrep,
      ),
      TopicTool.experiment => (
        'Personal experiment',
        'Your goal, your pace, no streaks',
        Icons.science_outlined,
        ClayTone.slate,
        Routes.experiment,
      ),
      TopicTool.checkIn => (
        'Daily check-in',
        'Log energy, stress, sleep and desire',
        Icons.edit_note_rounded,
        ClayTone.peach,
        Routes.checkIn,
      ),
      TopicTool.habit => (
        'Create a habit',
        'Build a realistic routine',
        Icons.add_task_rounded,
        ClayTone.sage,
        Routes.habitNew,
      ),
      TopicTool.breathing => (
        Exercises.breathing.title,
        Exercises.breathing.summary,
        Exercises.breathing.icon,
        Exercises.breathing.tone,
        Routes.exercise('breathing'),
      ),
      TopicTool.relaxation => (
        Exercises.relaxation.title,
        Exercises.relaxation.summary,
        Exercises.relaxation.icon,
        Exercises.relaxation.tone,
        Routes.exercise('relaxation'),
      ),
      TopicTool.grounding => (
        Exercises.grounding.title,
        Exercises.grounding.summary,
        Exercises.grounding.icon,
        Exercises.grounding.tone,
        Routes.exercise('grounding'),
      ),
    };
    return ClayListTile(title: title, subtitle: subtitle, icon: icon, tone: tone, onTap: () => context.push(route));
  }
}
