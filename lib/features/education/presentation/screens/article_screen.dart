import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_config.dart';
import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../data/article_repository.dart';
import '../../domain/article.dart';
import '../controllers/library_controller.dart';
import '../widgets/article_widgets.dart';

class ArticleScreen extends ConsumerStatefulWidget {
  const ArticleScreen({super.key, required this.articleId});
  final String articleId;

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(articleRepositoryProvider).byId(widget.articleId) == null) return;
      // Viewing history is best-effort; a storage failure must not block reading.
      ref.read(libraryProvider.notifier).markViewed(widget.articleId).catchError((_) {});
    });
  }

  Future<void> _toggleBookmark() async {
    try {
      final wasBookmarked = ref.read(libraryProvider).isBookmarked(widget.articleId);
      await ref.read(libraryProvider.notifier).toggleBookmark(widget.articleId);
      if (mounted) showClaySnack(context, wasBookmarked ? 'Removed from saved' : 'Saved for later');
    } catch (e) {
      if (mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(articleRepositoryProvider);
    final article = repo.byId(widget.articleId);
    if (article == null) {
      return const ClayPage(
        title: 'Article',
        children: [
          EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Article not found',
            message: 'This article may have been moved or removed.',
          ),
        ],
      );
    }
    final bookmarked = ref.watch(libraryProvider.select((s) => s.isBookmarked(article.id)));
    final tone = context.clay.tone(article.category.tone);
    final related = repo.related(article);

    return ClayPage(
      title: article.title,
      actions: [
        ClayIconButton(
          icon: bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark article',
          iconColor: bookmarked ? context.clay.accent : null,
          onPressed: _toggleBookmark,
        ),
      ],
      children: [
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            ClayTag(article.category.label, tone: article.category.tone, icon: article.category.icon),
            ClayTag('${article.readMinutes} min read', icon: Icons.schedule_rounded),
            ClayTag(
              article.reviewStatus.label,
              tone: article.reviewStatus == ReviewStatus.clinicallyReviewed ? ClayTone.sage : ClayTone.sand,
              icon: Icons.verified_outlined,
            ),
          ],
        ),
        const SizedBox(height: Gap.lg),
        ClaySurface(
          color: tone.fill,
          depth: 1.2,
          padding: const EdgeInsets.all(Gap.xl),
          child: Text(article.summary, style: context.text.titleMedium!.copyWith(color: tone.onFill, height: 1.45)),
        ),
        const SizedBox(height: Gap.lg),
        for (final w in article.safetyWarnings)
          SafetyPanel(
            title: 'Safety information',
            body: w,
            level: w.toLowerCase().contains('emergency') || w.toLowerCase().contains('urgent')
                ? SafetyLevel.urgent
                : SafetyLevel.caution,
          ),
        for (final section in article.sections) _SectionBlock(section: section),
        _InfoCard(
          title: 'What the evidence supports',
          icon: Icons.fact_check_rounded,
          tone: ClayTone.sage,
          items: article.evidenceSupports,
        ),
        if (article.uncertain.isNotEmpty)
          _InfoCard(
            title: 'What remains uncertain',
            icon: Icons.help_outline_rounded,
            tone: ClayTone.sand,
            items: article.uncertain,
          ),
        _InfoCard(
          title: 'Practical next steps',
          icon: Icons.directions_rounded,
          tone: ClayTone.teal,
          items: article.nextSteps,
        ),
        _InfoCard(
          title: 'When to talk to a clinician',
          icon: Icons.medical_services_rounded,
          tone: ClayTone.blue,
          items: article.seeClinician,
          footer: TextButton(
            onPressed: () => context.push(Routes.clinicianPrep),
            child: const Text('Prepare for an appointment'),
          ),
        ),
        const SizedBox(height: Gap.sm),
        Text(AppConfig.disclaimer, style: context.text.bodySmall),
        const SectionHeader('Sources'),
        SourceList(sources: article.sources),
        const SizedBox(height: Gap.sm),
        Text(
          'Written ${article.authoredOn} · Next review due ${article.nextReviewOn} · Version ${article.version}',
          style: context.text.bodySmall,
        ),
        if (related.isNotEmpty) ...[
          const SectionHeader('Related reading'),
          for (final r in related) ArticleCard(article: r),
        ],
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});
  final ArticleSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(section.heading, style: context.text.titleLarge)),
          const SizedBox(height: Gap.md),
          for (final p in section.paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: Text(p, style: context.text.bodyLarge),
            ),
          if (section.bullets.isNotEmpty) BulletList(section.bullets),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.icon, required this.tone, required this.items, this.footer});
  final String title;
  final IconData icon;
  final ClayTone tone;
  final List<String> items;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: ClaySurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClayIconBadge(icon: icon, tone: tone, size: 40),
                const SizedBox(width: Gap.md),
                Expanded(child: Text(title, style: context.text.titleMedium!.weight(800))),
              ],
            ),
            const SizedBox(height: Gap.md),
            BulletList(items, iconColor: context.clay.tone(tone).onFill),
            ?footer,
          ],
        ),
      ),
    );
  }
}
