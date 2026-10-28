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
import '../../domain/reflection.dart';

/// Renders a non-diagnostic reflection summary. Used for fresh results and
/// for saved sessions.
class OutcomeView extends ConsumerWidget {
  const OutcomeView({super.key, required this.outcome});
  final ReflectionOutcome outcome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clay = context.clay;
    final repo = ref.watch(articleRepositoryProvider);
    final articles = [for (final id in outcome.articleIds) ?repo.byId(id)];
    final careTone = switch (outcome.careLevel) {
      CareLevel.selfCare => ClayTone.sage,
      CareLevel.discuss => ClayTone.blue,
      CareLevel.appointment => ClayTone.sand,
      CareLevel.prompt => ClayTone.peach,
    };
    final careIcon = switch (outcome.careLevel) {
      CareLevel.selfCare => Icons.spa_rounded,
      CareLevel.discuss => Icons.chat_rounded,
      CareLevel.appointment => Icons.event_available_rounded,
      CareLevel.prompt => Icons.priority_high_rounded,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafetyPanel(
          title: 'This is not a diagnosis',
          body:
              'This summary reflects your answers only. It cannot diagnose a condition, and a reassuring summary does not rule one out.',
        ),
        ClaySurface(
          color: clay.tone(careTone).fill,
          depth: 1.2,
          padding: const EdgeInsets.all(Gap.xl),
          semanticLabel: '${outcome.careLevel.title}. ${outcome.careLevel.explanation}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(careIcon, color: clay.tone(careTone).onFill, size: 30),
              const SizedBox(height: Gap.md),
              Text(
                outcome.careLevel.title,
                style: context.text.titleLarge!.copyWith(color: clay.tone(careTone).onFill),
              ),
              const SizedBox(height: Gap.sm),
              Text(
                outcome.careLevel.explanation,
                style: context.text.bodyMedium!.copyWith(color: clay.tone(careTone).onFill),
              ),
              if (outcome.careReasons.isNotEmpty) ...[
                const SizedBox(height: Gap.md),
                for (final r in outcome.careReasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Icon(Icons.arrow_right_rounded, color: clay.tone(careTone).onFill),
                        ),
                        Expanded(
                          child: Text(
                            r,
                            style: context.text.bodyMedium!.copyWith(color: clay.tone(careTone).onFill).weight(700),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Gap.lg),
        if (outcome.careLevel == CareLevel.prompt)
          SafetyPanel(
            level: SafetyLevel.urgent,
            title: 'If symptoms are severe or happening now',
            body: 'Call your local emergency number or go to the nearest emergency department.',
            action: 'Emergency guidance',
            onAction: () => context.push(Routes.emergency),
          ),
        if (outcome.showMentalHealthSupport)
          const SafetyPanel(
            level: SafetyLevel.caution,
            title: 'Support for how you are feeling',
            body:
                'Low mood is common and treatable. A doctor can help, and so can talking to someone you trust. If you are struggling to cope or having thoughts of harming yourself, contact your local emergency number or a doctor now.',
          ),
        if (outcome.reflectionPoints.isNotEmpty) ...[
          const SectionHeader('Worth reflecting on', top: Gap.md),
          ClaySurface(child: BulletList(outcome.reflectionPoints, icon: Icons.lightbulb_outline_rounded, iconSize: 18)),
        ],
        if (outcome.showExperiment) ...[
          const SizedBox(height: Gap.lg),
          ClayButton(
            label: 'Open the personal experiment',
            icon: Icons.science_outlined,
            variant: ClayButtonVariant.secondary,
            onPressed: () => context.push(Routes.experiment),
          ),
        ],
        if (outcome.careLevel.index >= CareLevel.discuss.index) ...[
          const SizedBox(height: Gap.lg),
          ClayButton(
            label: 'Prepare for an appointment',
            icon: Icons.checklist_rounded,
            variant: ClayButtonVariant.secondary,
            onPressed: () => context.push(Routes.clinicianPrep),
          ),
        ],
        if (articles.isNotEmpty) ...[
          const SectionHeader('Suggested reading'),
          Text('Chosen from your answers using simple, transparent rules.', style: context.text.bodySmall),
          const SizedBox(height: Gap.md),
          for (final a in articles) ArticleCard(article: a),
        ],
        const SectionHeader('Your answers'),
        ClaySurface(
          sunken: true,
          depth: 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (q, a) in outcome.answerSummary) ...[
                Text(q, style: context.text.bodySmall),
                const SizedBox(height: 2),
                Text(a, style: context.text.titleSmall),
                const SizedBox(height: Gap.md),
              ],
              if (outcome.answerSummary.isEmpty) Text('No answers given.', style: context.text.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: Gap.lg),
        Text(AppConfig.disclaimer, style: context.text.bodySmall),
      ],
    );
  }
}
