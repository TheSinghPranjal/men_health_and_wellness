import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../domain/article.dart';
import 'article_widgets.dart';

/// Page with a large editorial header: back/actions row, title block and
/// decorative artwork bleeding off the top-right corner. The whole header
/// scrolls with the content.
class HeroHeaderPage extends StatelessWidget {
  const HeroHeaderPage({
    super.key,
    required this.title,
    required this.art,
    required this.children,
    this.eyebrow,
    this.subtitle,
    this.meta,
    this.actions = const [],
  });

  final String title;
  final Widget art;
  final List<Widget> children;

  /// Shown above the title; an accent bar is used when absent.
  final Widget? eyebrow;
  final String? subtitle;
  final Widget? meta;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, box) {
                  final artSize = (box.maxWidth * 0.52).clamp(150.0, 260.0);
                  // Text may run under the art's soft left edge, never its centre.
                  final textWidth = box.maxWidth - Gap.page * 2 - artSize * 0.42;
                  return Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: -artSize * 0.06,
                        child: ExcludeSemantics(
                          child: SizedBox.square(dimension: artSize, child: art),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: artSize),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(Gap.page, Gap.md, Gap.page, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (canPop || actions.isNotEmpty) ...[
                                SizedBox(
                                  height: 48,
                                  child: Row(
                                    children: [
                                      if (canPop)
                                        ClayIconButton(
                                          icon: Icons.arrow_back_rounded,
                                          tooltip: 'Back',
                                          onPressed: () => Navigator.of(context).maybePop(),
                                        ),
                                      const Spacer(),
                                      ...actions,
                                    ],
                                  ),
                                ),
                                const SizedBox(height: Gap.xl),
                              ] else
                                const SizedBox(height: Gap.lg),
                              eyebrow ??
                                  Container(
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: clay.accent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                              const SizedBox(height: Gap.md),
                              SizedBox(
                                width: textWidth,
                                child: Semantics(
                                  header: true,
                                  child: Text(
                                    title,
                                    style: context.text.headlineMedium!.copyWith(fontSize: 30, height: 1.15),
                                  ),
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: Gap.sm),
                                SizedBox(
                                  width: textWidth,
                                  child: Text(
                                    subtitle!,
                                    style: context.text.bodyMedium!.copyWith(color: clay.textSecondary, height: 1.4),
                                  ),
                                ),
                              ],
                              if (meta != null) ...[const SizedBox(height: Gap.md), meta!],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(Gap.page, Gap.lg, Gap.page, Gap.xxl + MediaQuery.paddingOf(context).bottom),
              sliver: SliverList.list(children: children),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative header artwork: a soft glow, a large topic medallion, two
/// floating bubbles and a sprig of leaves. Purely decorative.
class TopicHeroArt extends StatelessWidget {
  const TopicHeroArt({super.key, required this.icon, required this.tone, this.bubbleIcon = Icons.psychology_rounded});

  final IconData icon;
  final ClayTone tone;
  final IconData bubbleIcon;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final pair = clay.tone(tone);
    // Bubbles use the light palette in both themes so they always glow.
    final blue = ClayTheme.light.tone(ClayTone.blue);
    final rose = ClayTheme.light.tone(ClayTone.rose);
    return FittedBox(
      child: SizedBox.square(
        dimension: 200,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [pair.fill.withValues(alpha: 0.9), pair.fill.withValues(alpha: 0)]),
                ),
              ),
            ),
            const Positioned(
              right: 0,
              bottom: 0,
              child: CustomPaint(size: Size(90, 110), painter: _SprigPainter()),
            ),
            Positioned(
              left: 44,
              top: 40,
              child: _Orb(
                size: 112,
                colors: [Color.lerp(pair.fill, clay.surface, 0.6)!, pair.fill],
                glow: pair.fill,
                child: Icon(icon, size: 54, color: pair.onFill.withValues(alpha: 0.85)),
              ),
            ),
            Positioned(
              right: 6,
              top: 14,
              child: _Orb(
                size: 58,
                colors: [const Color(0xFFE6F2FF), blue.fill],
                glow: const Color(0xFF8CC3F0),
                child: Icon(bubbleIcon, size: 30, color: blue.onFill),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 26,
              child: _Orb(
                size: 46,
                colors: [const Color(0xFFFFEEF1), rose.fill],
                glow: const Color(0xFFF2A3B3),
                child: const Icon(Icons.favorite_rounded, size: 22, color: Color(0xFFD9445E)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.colors, required this.glow, required this.child});
  final double size;
  final List<Color> colors;
  final Color glow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        boxShadow: [BoxShadow(color: glow.withValues(alpha: 0.55), blurRadius: size * 0.4, spreadRadius: 1)],
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Center(child: child),
    );
  }
}

class _SprigPainter extends CustomPainter {
  const _SprigPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = const Color(0x997CB89A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.7, size.height)
        ..quadraticBezierTo(size.width * 0.8, size.height * 0.5, size.width * 0.55, size.height * 0.05),
      stem,
    );
    for (final (dx, dy, angle, alpha) in const [
      (0.86, 0.72, 0.8, 0.55),
      (0.5, 0.58, -0.9, 0.45),
      (0.82, 0.38, 0.6, 0.5),
      (0.45, 0.22, -0.7, 0.4),
    ]) {
      canvas.save();
      canvas.translate(size.width * dx, size.height * dy);
      canvas.rotate(angle);
      canvas.drawPath(
        Path()
          ..moveTo(0, -20)
          ..quadraticBezierTo(13, 0, 0, 20)
          ..quadraticBezierTo(-13, 0, 0, -20),
        Paint()..color = const Color(0xFF6FB59A).withValues(alpha: alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SprigPainter old) => false;
}

/// Section heading with a short accent underline.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Gap.lg, bottom: Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: context.text.titleLarge)),
          const SizedBox(height: 6),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(color: context.clay.accent, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }
}

/// Light, tinted callout with an icon disc, e.g. "Key takeaway".
class TintedCallout extends StatelessWidget {
  const TintedCallout({super.key, required this.icon, required this.tone, required this.title, required this.body});
  final IconData icon;
  final ClayTone tone;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final pair = clay.tone(tone);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: ClaySurface(
        color: Color.lerp(pair.fill, clay.surface, 0.35),
        depth: 0.8,
        padding: const EdgeInsets.all(Gap.lg),
        semanticLabel: '$title. $body',
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopicBadge(icon: icon, tone: tone, size: 46, round: true),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleSmall!.copyWith(color: pair.onFill).weight(800)),
                    const SizedBox(height: Gap.xs),
                    Text(body, style: context.text.bodyMedium!.copyWith(height: 1.45)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single statement on its own soft tile with a check mark.
class CheckRow extends StatelessWidget {
  const CheckRow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: ClaySurface(
        depth: 0.4,
        radius: ClayTheme.radiusSm,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_rounded, size: 22, color: context.clay.positive),
            const SizedBox(width: Gap.md),
            Expanded(child: Text(text, style: context.text.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

/// Tinted card explaining one concept, used side by side for comparisons.
class ConceptCardView extends StatelessWidget {
  const ConceptCardView({super.key, required this.card});
  final ConceptCard card;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final pair = clay.tone(card.tone);
    return ClaySurface(
      color: pair.fill,
      padding: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ClayTheme.radiusMd),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(pair.fill, clay.surface, 0.6)!, Color.lerp(pair.fill, clay.surface, 0.2)!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TopicBadge(icon: card.icon, tone: card.tone, size: 42, round: true),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            card.title,
                            style: context.text.titleMedium!.copyWith(color: pair.onFill).weight(800),
                          ),
                        ),
                        Text(card.subtitle, style: context.text.labelMedium!.copyWith(color: pair.onFill)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Text(card.body, style: context.text.bodySmall!.copyWith(color: clay.textPrimary, height: 1.4)),
              if (card.examples.isNotEmpty) ...[
                const Spacer(),
                const SizedBox(height: Gap.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Gap.md),
                  decoration: BoxDecoration(
                    color: clay.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(ClayTheme.radiusSm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Examples', style: context.text.labelLarge!.copyWith(color: pair.onFill).weight(800)),
                      const SizedBox(height: Gap.xs),
                      for (final e in card.examples)
                        Padding(
                          padding: const EdgeInsets.only(top: Gap.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Icon(Icons.circle, size: 6, color: pair.onFill),
                              ),
                              const SizedBox(width: Gap.sm),
                              Expanded(
                                child: Text(e, style: context.text.bodySmall!.copyWith(color: pair.onFill)),
                              ),
                            ],
                          ),
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

/// Reading-depth label derived from length, so it never goes stale.
(String, ClayTone, IconData) readingDepth(Article article) => switch (article.readMinutes) {
  <= 1 => ('Quick read', ClayTone.lavender, Icons.bolt_rounded),
  >= 3 => ('In-depth guide', ClayTone.rose, Icons.menu_book_rounded),
  _ => ('Key concept', ClayTone.teal, Icons.lightbulb_rounded),
};

/// Rich article card for topic screens: art tile, title, summary and meta.
class TopicArticleCard extends StatelessWidget {
  const TopicArticleCard({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final (depth, depthTone, depthIcon) = readingDepth(article);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: ClaySurface(
        padding: const EdgeInsets.all(Gap.md),
        onTap: () => context.push(Routes.article(article.id)),
        semanticLabel: 'Article: ${article.title}. ${article.readMinutes} minute read. $depth.',
        child: ExcludeSemantics(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ArticleArtTile(category: article.category, width: 96),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TopicBadge(icon: depthIcon, tone: depthTone, size: 34),
                          const SizedBox(width: Gap.sm),
                          Expanded(
                            child: Text(
                              article.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleSmall!.weight(800),
                            ),
                          ),
                          const SizedBox(width: Gap.xs),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(color: clay.surfaceSunken, shape: BoxShape.circle),
                            child: Icon(Icons.chevron_right_rounded, size: 20, color: clay.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.summary,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall!.copyWith(height: 1.4),
                      ),
                      const SizedBox(height: Gap.sm),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: Gap.sm,
                        runSpacing: Gap.xs,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_rounded, size: 16, color: clay.textSecondary),
                              const SizedBox(width: Gap.xs),
                              Flexible(
                                child: Text('${article.readMinutes} min read', style: context.text.labelMedium),
                              ),
                            ],
                          ),
                          ClayTag(depth, tone: depthTone),
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

/// Dark, glowing artwork tile representing an article's topic.
class ArticleArtTile extends StatelessWidget {
  const ArticleArtTile({super.key, required this.category, this.width = 96});
  final ArticleCategory category;
  final double width;

  static const _night = Color(0xFF0E1C38);

  @override
  Widget build(BuildContext context) {
    // Light-palette tones so the glow reads on the dark tile in both themes.
    final glow = ClayTheme.light.tone(category.tone).fill;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 112),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_night, Color.lerp(_night, ClayTheme.light.tone(category.tone).onFill, 0.55)!],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: width * 0.8,
              height: width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [glow.withValues(alpha: 0.55), glow.withValues(alpha: 0)]),
              ),
            ),
            Icon(
              category.icon,
              size: width * 0.42,
              color: glow,
              shadows: [Shadow(color: glow, blurRadius: 16)],
            ),
          ],
        ),
      ),
    );
  }
}
