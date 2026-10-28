import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../domain/article.dart';

/// Vertical list card for an article.
class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: ClaySurface(
        onTap: () => context.push(Routes.article(article.id)),
        semanticLabel: 'Article: ${article.title}. ${article.readMinutes} minute read.',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClayIconBadge(icon: article.category.icon, tone: article.category.tone, size: 46),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: context.text.titleMedium),
                  const SizedBox(height: Gap.xs),
                  Text(article.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
                  const SizedBox(height: Gap.sm),
                  Text('${article.category.label} · ${article.readMinutes} min read', style: context.text.labelMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact horizontal card for carousels.
class ArticleTile extends StatelessWidget {
  const ArticleTile({super.key, required this.article, this.width = 230});
  final Article article;
  final double width;

  @override
  Widget build(BuildContext context) {
    final tone = context.clay.tone(article.category.tone);
    return SizedBox(
      width: width,
      child: ClaySurface(
        color: tone.fill,
        onTap: () => context.push(Routes.article(article.id)),
        semanticLabel: 'Article: ${article.title}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(article.category.icon, color: tone.onFill),
            const Spacer(),
            Text(
              article.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleMedium!.copyWith(color: tone.onFill),
            ),
            const SizedBox(height: Gap.xs),
            Text('${article.readMinutes} min read', style: context.text.labelMedium!.copyWith(color: tone.onFill)),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.count});
  final ArticleCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tone = context.clay.tone(category.tone);
    return ClaySurface(
      color: tone.fill,
      onTap: () => context.push(Routes.category(category.name)),
      semanticLabel: '${category.label}, ${count == 1 ? '1 article' : '$count articles'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(category.icon, color: tone.onFill, size: 28),
          const Spacer(),
          const SizedBox(height: Gap.md),
          Text(
            category.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleMedium!.copyWith(color: tone.onFill).weight(800),
          ),
          Text(
            count == 1 ? '1 article' : '$count articles',
            style: context.text.labelMedium!.copyWith(color: tone.onFill),
          ),
        ],
      ),
    );
  }
}

/// Source citation list. Links open in the external browser so the app
/// itself never loads third-party pages.
class SourceList extends StatelessWidget {
  const SourceList({super.key, required this.sources});
  final List<Source> sources;

  Future<void> _open(BuildContext context, Source s) async {
    final ok = await launchUrl(Uri.parse(s.url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      await Clipboard.setData(ClipboardData(text: s.url));
      if (context.mounted) showClaySnack(context, 'Could not open a browser. Link copied.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, s) in sources.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.sm),
            child: ClaySurface(
              sunken: true,
              depth: 0.3,
              radius: ClayTheme.radiusSm,
              padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.md),
              onTap: () => _open(context, s),
              semanticLabel: 'Source ${i + 1}: ${s.title}, ${s.publisher}. Opens in browser.',
              child: Row(
                children: [
                  Text('${i + 1}', style: context.text.titleSmall!.copyWith(color: context.clay.accent)),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title, style: context.text.titleSmall),
                        Text(s.publisher, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new_rounded, size: 18, color: context.clay.textSecondary),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class BulletList extends StatelessWidget {
  const BulletList(this.items, {super.key, this.icon = Icons.circle, this.iconColor, this.iconSize = 7});
  final List<String> items;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 24,
                  child: Center(
                    child: Icon(icon, size: iconSize, color: iconColor ?? context.clay.accent),
                  ),
                ),
                const SizedBox(width: Gap.xs),
                Expanded(child: Text(item, style: context.text.bodyLarge)),
              ],
            ),
          ),
      ],
    );
  }
}
