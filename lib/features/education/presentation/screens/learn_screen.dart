import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../data/article_repository.dart';
import '../../domain/article.dart';
import '../controllers/library_controller.dart';
import '../widgets/article_widgets.dart';
import '../widgets/learn_illustration.dart';
import '../widgets/topic_layout.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  /// Topics shown before "View all" expands the grid.
  static const _collapsedTopics = 8;

  /// Myths featured in the hero carousel, with a short teaser for each.
  static const _featuredMyths = [
    ('longer-better', 'Explore what research really says about duration and satisfaction.'),
    ('always-ready', 'Why desire and arousal naturally ebb and flow, and why that is normal.'),
    ('ed-inevitable', 'What really changes with age, and what stays within your control.'),
  ];

  bool _showAllTopics = false;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(articleRepositoryProvider);
    final bookmarks = ref.watch(bookmarkedArticlesProvider);
    final myths = repo.myths();
    final featured = [
      for (final (id, teaser) in _featuredMyths)
        if (myths.where((m) => m.id == id).firstOrNull case final m?) (m, teaser),
    ];
    final topics = _showAllTopics ? ArticleCategory.values : ArticleCategory.values.take(_collapsedTopics);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Gap.page, Gap.xl, Gap.page, 0),
              sliver: SliverList.list(
                children: [
                  _LearnHeader(guideCount: repo.all().length),
                  const SizedBox(height: Gap.lg),
                  ClaySearchEntry(onTap: () => context.push(Routes.search)),
                  const SizedBox(height: Gap.sm),
                ],
              ),
            ),
            // Full-bleed so neighbouring slides never peek into the page gutter.
            if (featured.isNotEmpty) SliverToBoxAdapter(child: _FeaturedCarousel(items: featured)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(Gap.page, 0, Gap.page, Gap.xxl + MediaQuery.paddingOf(context).bottom),
              sliver: SliverList.list(
                children: [
                  SectionHeader(
                    'Browse Topics',
                    top: Gap.sm,
                    action: ArticleCategory.values.length > _collapsedTopics
                        ? (_showAllTopics ? 'Show less' : 'View all')
                        : null,
                    onAction: () => setState(() => _showAllTopics = !_showAllTopics),
                  ),
                  ClayGrid(
                    children: [for (final c in topics) CategoryCard(category: c, count: repo.byCategory(c).length)],
                  ),
                  if (bookmarks.isNotEmpty) ...[
                    SectionHeader('Saved', action: 'See all', onAction: () => context.push(Routes.bookmarks)),
                    for (final a in bookmarks.take(3)) ArticleCard(article: a),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnHeader extends StatelessWidget {
  const _LearnHeader({required this.guideCount});
  final int guideCount;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final body = context.text.bodyMedium!.copyWith(color: clay.textSecondary, height: 1.45);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text('Learn', style: context.text.headlineMedium!.copyWith(fontSize: 34, height: 1.1)),
              ),
              const SizedBox(height: Gap.sm),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: clay.accent, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: Gap.md),
              Text('$guideCount evidence-based guides, available offline', style: body),
              Text('Learn, understand and build a healthier you.', style: body),
            ],
          ),
        ),
        const SizedBox(width: Gap.sm),
        const ExcludeSemantics(child: LearnIllustration(width: 112)),
      ],
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.items});
  final List<(Myth, String)> items;

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Grow with text size so the title and teaser never get clipped.
    final height = MediaQuery.textScalerOf(context).scale(250).clamp(250.0, 380.0);
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, i) {
          final (myth, teaser) = widget.items[i];
          return Padding(
            // Vertical room keeps the clay drop shadow inside the clip.
            padding: const EdgeInsets.fromLTRB(Gap.page, Gap.sm, Gap.page, Gap.xl),
            child: _MythHeroCard(myth: myth, teaser: teaser, index: i, count: widget.items.length, current: _page),
          );
        },
      ),
    );
  }
}

class _MythHeroCard extends StatelessWidget {
  const _MythHeroCard({
    required this.myth,
    required this.teaser,
    required this.index,
    required this.count,
    required this.current,
  });

  final Myth myth;
  final String teaser;
  final int index;
  final int count;
  final int current;

  // Fixed in both themes: the hero is always a deep, dark card.
  static const _deep = Color(0xFF14304A);
  static const _teal = Color(0xFF1D5C66);
  static const _mint = Color(0xFF8EE3CB);
  static const _onMint = Color(0xFF0E2E35);
  static const _ink = Color(0xFFF4F7F6);

  @override
  Widget build(BuildContext context) {
    final related = myth.relatedArticle;
    final radius = BorderRadius.circular(ClayTheme.radiusMd);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return ClaySurface(
      color: _deep,
      depth: 1.2,
      padding: EdgeInsets.zero,
      onTap: () => context.push(related == null ? Routes.myths : Routes.article(related)),
      semanticLabel: 'Myth versus evidence. ${myth.myth} Is it? $teaser Read guide. Slide ${index + 1} of $count.',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: radius,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_deep, _teal]),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final art = (constraints.maxWidth * 0.38).clamp(0.0, 140.0);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      right: Gap.sm,
                      bottom: Gap.xl,
                      child: LearnIllustration(width: art, onDark: true),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Gap.xl - 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MYTH VS EVIDENCE',
                            style: context.text.labelSmall!.copyWith(color: _mint, letterSpacing: 1.4).weight(800),
                          ),
                          const SizedBox(height: Gap.sm),
                          // Takes the space above the button; text truncates rather than overflowing.
                          Expanded(
                            child: SizedBox(
                              width: constraints.maxWidth - art - Gap.xl,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '\u201C${myth.myth}\u201D Is it?',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.titleLarge!.copyWith(color: _ink, fontSize: 21, height: 1.2),
                                    ),
                                  ),
                                  const SizedBox(height: Gap.sm),
                                  Flexible(
                                    child: Text(
                                      teaser,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.bodySmall!.copyWith(color: _ink.withValues(alpha: 0.82)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: Gap.md),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(color: _mint, borderRadius: BorderRadius.circular(999)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Read Guide',
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.labelLarge!.copyWith(color: _onMint).weight(800),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded, size: 18, color: _onMint),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (count > 1)
                      Positioned(
                        right: Gap.lg,
                        bottom: Gap.lg,
                        child: Row(
                          children: [
                            for (var i = 0; i < count; i++)
                              AnimatedContainer(
                                duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(left: 6),
                                width: i == current ? 18 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: i == current ? 0.95 : 0.35),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
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
      radius: 28,
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
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: Gap.md),
            color: context.clay.textSecondary.withValues(alpha: 0.3),
          ),
          Icon(Icons.tune_rounded, color: context.clay.textSecondary),
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
    return HeroHeaderPage(
      title: category.label,
      subtitle: category.description,
      art: TopicHeroArt(icon: category.icon, tone: category.tone),
      children: [
        TintedCallout(
          icon: Icons.menu_book_rounded,
          tone: ClayTone.teal,
          title: '${articles.length == 1 ? '1 article' : '${articles.length} articles'} in this topic',
          body: category.intro,
        ),
        for (final a in articles) TopicArticleCard(article: a),
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
    return HeroHeaderPage(
      title: 'Myth vs evidence',
      subtitle: 'Common beliefs, checked against trusted sources.',
      art: const _MythArt(),
      children: [for (final (i, m) in myths.indexed) _MythCard(myth: m, index: i)],
    );
  }
}

/// Thinking medallion flanked by "Myth" and "Evidence" speech bubbles.
class _MythArt extends StatelessWidget {
  const _MythArt();

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final teal = ClayTheme.light.tone(ClayTone.teal);
    final label = context.text.labelMedium!.copyWith(color: clay.textPrimary).weight(800);
    final question = context.text.headlineSmall!.copyWith(color: teal.onFill.withValues(alpha: 0.45));
    return FittedBox(
      child: SizedBox.square(
        dimension: 200,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [teal.fill, teal.fill.withValues(alpha: 0)]),
                ),
              ),
            ),
            Positioned(
              left: 52,
              top: 56,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.lerp(teal.fill, Colors.white, 0.6)!, teal.fill],
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
                  boxShadow: [BoxShadow(color: teal.onFill.withValues(alpha: 0.2), blurRadius: 24)],
                ),
                child: Icon(Icons.psychology_alt_rounded, size: 56, color: teal.onFill),
              ),
            ),
            Positioned(left: 4, top: 22, child: _bubble(const Color(0xFFE5606F), Icons.close_rounded, 'Myth', label)),
            Positioned(
              right: 0,
              top: 8,
              child: _bubble(const Color(0xFF2F8C76), Icons.check_rounded, 'Evidence', label),
            ),
            Positioned(left: 70, top: 14, child: Text('?', style: question)),
            Positioned(right: 30, top: 124, child: Text('?', style: question)),
          ],
        ),
      ),
    );
  }

  Widget _bubble(Color color, IconData icon, String text, TextStyle style) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 46,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 2),
        Text(text, style: style),
      ],
    );
  }
}

class _MythCard extends StatefulWidget {
  const _MythCard({required this.myth, required this.index});
  final Myth myth;
  final int index;

  @override
  State<_MythCard> createState() => _MythCardState();
}

class _MythCardState extends State<_MythCard> {
  bool _revealed = false;

  static const _looks = <String, (IconData, ClayTone)>{
    'ed-psychological': (Icons.psychology_rounded, ClayTone.rose),
    'ed-inevitable': (Icons.hourglass_bottom_rounded, ClayTone.sand),
    'libido-testosterone': (Icons.science_rounded, ClayTone.teal),
    'magic-food': (Icons.restaurant_rounded, ClayTone.blue),
    'everyone-quit-porn': (Icons.visibility_off_rounded, ClayTone.rose),
    'longer-better': (Icons.timer_rounded, ClayTone.lavender),
    'always-ready': (Icons.bolt_rounded, ClayTone.peach),
    'natural-safe': (Icons.eco_rounded, ClayTone.sage),
    'firmness-masculinity': (Icons.fitness_center_rounded, ClayTone.slate),
  };
  static const _fallbackTones = [ClayTone.rose, ClayTone.sand, ClayTone.teal, ClayTone.blue, ClayTone.lavender];

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final m = widget.myth;
    final (icon, baseTone) =
        _looks[m.id] ?? (Icons.chat_bubble_outline_rounded, _fallbackTones[widget.index % _fallbackTones.length]);
    final tone = _revealed ? ClayTone.sage : baseTone;
    final pair = clay.tone(tone);
    final tagColor = _revealed ? clay.positive : clay.tone(ClayTone.peach).onFill;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: ClaySurface(
        color: Color.lerp(pair.fill, clay.surface, 0.3),
        padding: const EdgeInsets.all(Gap.md),
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
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: clay.surface.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, size: 38, color: pair.onFill),
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _revealed ? Icons.fact_check_rounded : Icons.chat_bubble_outline_rounded,
                              size: 16,
                              color: tagColor,
                            ),
                            const SizedBox(width: Gap.xs),
                            Flexible(
                              child: Text(
                                _revealed ? 'Evidence' : 'Myth',
                                style: context.text.labelLarge!.copyWith(color: tagColor).weight(800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.myth,
                          style: context.text.titleMedium!
                              .weight(800)
                              .copyWith(decoration: _revealed ? TextDecoration.lineThrough : null),
                        ),
                        if (!_revealed) ...[
                          const SizedBox(height: 2),
                          Text('Tap to see what the evidence says.', style: context.text.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: clay.surface.withValues(alpha: 0.9), shape: BoxShape.circle),
                    child: Icon(
                      _revealed ? Icons.expand_less_rounded : Icons.chevron_right_rounded,
                      size: 22,
                      color: clay.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_revealed) ...[
                const SizedBox(height: Gap.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Gap.md),
                  decoration: BoxDecoration(
                    color: clay.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(ClayTheme.radiusSm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.evidence, style: context.text.bodyLarge),
                      const SizedBox(height: Gap.md),
                      Text('Source: ${m.sources.map((s) => s.publisher).join('; ')}', style: context.text.bodySmall),
                      if (m.relatedArticle != null)
                        TextButton(
                          onPressed: () => context.push(Routes.article(m.relatedArticle!)),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text('Read more'),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
