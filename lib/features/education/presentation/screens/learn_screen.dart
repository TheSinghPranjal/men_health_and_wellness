import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../data/article_repository.dart';
import '../../domain/article.dart';
import '../controllers/library_controller.dart';
import '../widgets/article_widgets.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(articleRepositoryProvider);
    final bookmarks = ref.watch(bookmarkedArticlesProvider);

    return ClayPage(
      title: 'Learn',
      subtitle: '${repo.all().length} evidence-based guides, available offline',
      showBack: false,
      children: [
        ClaySearchEntry(onTap: () => context.push(Routes.search)),
        const SizedBox(height: Gap.lg),
        ClaySurface(
          color: context.clay.brand,
          depth: 1.2,
          onTap: () => context.push(Routes.myths),
          semanticLabel: 'Myths versus evidence',
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MYTH VS EVIDENCE',
                      style: context.text.labelSmall!.copyWith(color: context.clay.onBrand.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: Gap.xs),
                    Text(
                      '"Longer sex is always better." Is it?',
                      style: context.text.titleMedium!.copyWith(color: context.clay.onBrand),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Gap.md),
              Icon(Icons.arrow_forward_rounded, color: context.clay.onBrand),
            ],
          ),
        ),
        const SectionHeader('Topics'),
        ClayGrid(
          children: [
            for (final c in ArticleCategory.values) CategoryCard(category: c, count: repo.byCategory(c).length),
          ],
        ),
        if (bookmarks.isNotEmpty) ...[
          SectionHeader('Saved', action: 'See all', onAction: () => context.push(Routes.bookmarks)),
          for (final a in bookmarks.take(3)) ArticleCard(article: a),
        ],
      ],
    );
  }
}

/// Tappable search affordance that opens the search screen.
class ClaySearchEntry extends StatelessWidget {
  const ClaySearchEntry({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClaySurface(
      sunken: true,
      depth: 0.4,
      radius: 20,
      onTap: onTap,
      semanticLabel: 'Search articles',
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: 16),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: context.clay.textSecondary),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Text(
              'Search topics, e.g. "sleep"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium!.copyWith(color: context.clay.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.categoryName});
  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ArticleCategory.values.where((c) => c.name == categoryName).firstOrNull;
    if (category == null) {
      return const ClayPage(
        title: 'Topic',
        children: [
          EmptyState(icon: Icons.search_off_rounded, title: 'Topic not found', message: 'Try browsing from Learn.'),
        ],
      );
    }
    final articles = ref.watch(articleRepositoryProvider).byCategory(category);
    return ClayPage(
      title: category.label,
      subtitle: category.description,
      children: [
        Row(
          children: [ClayIconBadge(icon: category.icon, tone: category.tone, size: 56)],
        ),
        const SizedBox(height: Gap.lg),
        for (final a in articles) ArticleCard(article: a),
      ],
    );
  }
}

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkedArticlesProvider);
    return ClayPage(
      title: 'Saved articles',
      children: [
        if (bookmarks.isEmpty)
          const EmptyState(
            icon: Icons.bookmark_border_rounded,
            title: 'Nothing saved yet',
            message: 'Tap the bookmark icon on any article to keep it here.',
          )
        else
          for (final a in bookmarks) ArticleCard(article: a),
      ],
    );
  }
}

class MythsScreen extends ConsumerWidget {
  const MythsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myths = ref.watch(articleRepositoryProvider).myths();
    return ClayPage(
      title: 'Myth vs evidence',
      subtitle: 'Common beliefs, checked against trusted sources.',
      children: [for (final m in myths) _MythCard(myth: m)],
    );
  }
}

class _MythCard extends StatefulWidget {
  const _MythCard({required this.myth});
  final Myth myth;

  @override
  State<_MythCard> createState() => _MythCardState();
}

class _MythCardState extends State<_MythCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final m = widget.myth;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: ClaySurface(
        color: _revealed ? clay.tone(ClayTone.sage).fill : clay.tone(ClayTone.peach).fill,
        onTap: () => setState(() => _revealed = !_revealed),
        semanticLabel: _revealed
            ? 'Myth: ${m.myth}. Evidence: ${m.evidence}'
            : 'Myth: ${m.myth}. Tap to see the evidence.',
        child: AnimatedSize(
          duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClayTag(
                _revealed ? 'Evidence' : 'Myth',
                tone: _revealed ? ClayTone.sage : ClayTone.peach,
                icon: _revealed ? Icons.fact_check_rounded : Icons.chat_bubble_outline_rounded,
              ),
              const SizedBox(height: Gap.md),
              Text(
                m.myth,
                style: context.text.titleMedium!
                    .weight(800)
                    .copyWith(decoration: _revealed ? TextDecoration.lineThrough : null),
              ),
              if (_revealed) ...[
                const SizedBox(height: Gap.md),
                Text(m.evidence, style: context.text.bodyLarge),
                const SizedBox(height: Gap.md),
                Text('Source: ${m.sources.map((s) => s.publisher).join('; ')}', style: context.text.bodySmall),
                if (m.relatedArticle != null)
                  TextButton(
                    onPressed: () => context.push(Routes.article(m.relatedArticle!)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('Read more'),
                  ),
              ] else ...[
                const SizedBox(height: Gap.sm),
                Text('Tap to see what the evidence says', style: context.text.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
