import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/clay_tokens.dart';
import 'clay_buttons.dart';
import 'clay_surface.dart';

/// Standard page scaffold: clay background, large title, scrollable body.
class ClayPage extends StatelessWidget {
  const ClayPage({
    super.key,
    required this.title,
    required this.children,
    this.actions = const [],
    this.subtitle,
    this.bottom,
    this.showBack = true,
    this.controller,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final List<Widget> actions;
  final Widget? bottom;
  final bool showBack;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.of(context).canPop();
    final hasHeader = canPop || actions.isNotEmpty;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Pinned so back and actions stay reachable on long pages.
            if (hasHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.page, Gap.md, Gap.page, Gap.xs),
                child: Row(
                  children: [
                    if (canPop)
                      ClayIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    const Spacer(),
                    ...actions.expand((a) => [const SizedBox(width: Gap.sm), a]),
                  ],
                ),
              ),
            Expanded(
              child: CustomScrollView(
                controller: controller,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(Gap.page, hasHeader ? Gap.md : Gap.xl, Gap.page, Gap.sm),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(header: true, child: Text(title, style: context.text.headlineMedium)),
                          if (subtitle != null) ...[
                            const SizedBox(height: Gap.xs),
                            Text(
                              subtitle!,
                              style: context.text.bodyMedium!.copyWith(color: context.clay.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      Gap.page,
                      Gap.md,
                      Gap.page,
                      Gap.xxl + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: SliverList.list(children: children),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottom,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction, this.top = Gap.xl});

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: Gap.md),
      child: Row(
        children: [
          Expanded(
            child: Semantics(header: true, child: Text(title, style: context.text.titleLarge)),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: context.clay.accent, minimumSize: const Size(48, 44)),
              child: Text(action!, style: context.text.labelLarge!.copyWith(color: context.clay.accent)),
            ),
        ],
      ),
    );
  }
}

/// Multi- or single-select chip with clay styling.
class ClayChoiceChip extends StatelessWidget {
  const ClayChoiceChip({super.key, required this.label, required this.selected, required this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final fg = selected ? clay.onAccent : clay.textPrimary;
    return ClaySurface(
      color: selected ? clay.accent : clay.surface,
      radius: 18,
      depth: selected ? 0.8 : 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      semanticLabel: '$label${selected ? ', selected' : ''}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(selected ? Icons.check_circle_rounded : (icon ?? Icons.circle_outlined), size: 18, color: fg),
          const SizedBox(width: Gap.sm),
          Flexible(
            child: Text(label, style: context.text.labelLarge!.copyWith(color: fg).weight(700)),
          ),
        ],
      ),
    );
  }
}

/// A full-width selectable option used inside questionnaires.
class ClayOptionTile extends StatelessWidget {
  const ClayOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.multi = false,
  });

  final String label;
  final bool selected;
  final bool multi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final icon = multi
        ? (selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded)
        : (selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: ClaySurface(
        selected: selected,
        depth: selected ? 0.9 : 0.6,
        color: selected ? clay.tone(ClayTone.teal).fill : null,
        radius: 20,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        semanticLabel: '$label${selected ? ', selected' : ''}',
        child: Row(
          children: [
            Icon(icon, color: selected ? clay.accent : clay.textSecondary),
            const SizedBox(width: Gap.md),
            Expanded(child: Text(label, style: context.text.bodyLarge!.weight(selected ? 700 : 600))),
          ],
        ),
      ),
    );
  }
}

enum SafetyLevel { info, caution, urgent }

/// Callout used for safety information. Icon + label text mean colour is
/// never the only signal.
class SafetyPanel extends StatelessWidget {
  const SafetyPanel({
    super.key,
    required this.title,
    required this.body,
    this.level = SafetyLevel.info,
    this.action,
    this.onAction,
  });

  final String title;
  final String body;
  final SafetyLevel level;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final (fill, fg, icon, tag) = switch (level) {
      SafetyLevel.info => (
        clay.tone(ClayTone.blue).fill,
        clay.tone(ClayTone.blue).onFill,
        Icons.info_rounded,
        'Good to know',
      ),
      SafetyLevel.caution => (
        clay.tone(ClayTone.sand).fill,
        clay.tone(ClayTone.sand).onFill,
        Icons.warning_amber_rounded,
        'Caution',
      ),
      SafetyLevel.urgent => (clay.critical, clay.onCritical, Icons.emergency_rounded, 'Urgent'),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: ClaySurface(
        color: fill,
        depth: 0.8,
        semanticLabel: '$tag. $title. $body',
        child: ExcludeSemantics(
          excluding: onAction == null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: fg, size: 22),
                  const SizedBox(width: Gap.sm),
                  Text(tag.toUpperCase(), style: context.text.labelSmall!.copyWith(color: fg)),
                ],
              ),
              const SizedBox(height: Gap.sm),
              Text(title, style: context.text.titleMedium!.copyWith(color: fg).weight(800)),
              const SizedBox(height: Gap.xs),
              Text(body, style: context.text.bodyMedium!.copyWith(color: fg)),
              if (action != null && onAction != null) ...[
                const SizedBox(height: Gap.md),
                TextButton.icon(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: fg,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 44),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(action!, style: context.text.labelLarge!.copyWith(color: fg)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ClaySurface(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        children: [
          ClayIconBadge(icon: icon, tone: ClayTone.slate, size: 64),
          const SizedBox(height: Gap.lg),
          Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: Gap.xs),
          Text(message, style: context.text.bodySmall, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: Gap.lg),
            ClayButton(label: action!, onPressed: onAction, variant: ClayButtonVariant.secondary, expand: false),
          ],
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Something went wrong',
      message: message,
      action: onRetry == null ? null : 'Try again',
      onAction: onRetry,
    );
  }
}

/// Shimmer-free loading placeholder (respects reduced motion by default).
class LoadingPlaceholder extends StatelessWidget {
  const LoadingPlaceholder({super.key, this.height = 96});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: Padding(
        padding: const EdgeInsets.only(bottom: Gap.md),
        child: ClaySurface(sunken: true, depth: 0.3, child: SizedBox(height: height - Gap.lg * 2)),
      ),
    );
  }
}

/// A 1–5 self-rating control. Subjective by design; labels describe the ends.
class ScaleSelector extends StatelessWidget {
  const ScaleSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.lowLabel,
    required this.highLabel,
    this.optional = false,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  final String lowLabel;
  final String highLabel;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: ClaySurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: context.text.titleMedium)),
                if (optional && value != null)
                  TextButton(
                    onPressed: () => onChanged(null),
                    style: TextButton.styleFrom(minimumSize: const Size(48, 40)),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            if (optional) Text('Optional', style: context.text.bodySmall),
            const SizedBox(height: Gap.md),
            Row(
              children: [
                for (var i = 1; i <= 5; i++) ...[
                  Expanded(
                    child: ClaySurface(
                      radius: 16,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: value == i ? clay.accent : clay.surfaceSunken,
                      depth: value == i ? 0.8 : 0.2,
                      onTap: () => onChanged(i),
                      semanticLabel: '$label: $i of 5${value == i ? ', selected' : ''}',
                      child: Center(
                        child: Text(
                          '$i',
                          style: context.text.titleMedium!.copyWith(
                            color: value == i ? clay.onAccent : clay.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (i < 5) const SizedBox(width: Gap.sm),
                ],
              ],
            ),
            const SizedBox(height: Gap.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text('1 · $lowLabel', style: context.text.bodySmall)),
                const SizedBox(width: Gap.sm),
                Flexible(
                  child: Text('$highLabel · 5', textAlign: TextAlign.end, style: context.text.bodySmall),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A row inside a settings-style clay group.
class ClayListTile extends StatelessWidget {
  const ClayListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tone = ClayTone.slate,
    this.trailing,
    this.onTap,
    this.tinted = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final ClayTone tone;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Washes the tile in a light version of [tone].
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: ClaySurface(
        color: tinted ? Color.lerp(context.clay.tone(tone).fill, context.clay.surface, 0.5) : null,
        onTap: onTap,
        semanticLabel: onTap == null ? null : title,
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[ClayIconBadge(icon: icon!, tone: tone, size: 42), const SizedBox(width: Gap.md)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleMedium),
                  if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: context.text.bodySmall)],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: context.clay.textSecondary),
          ],
        ),
      ),
    );
  }
}

class ClayProgressRing extends StatelessWidget {
  const ClayProgressRing({super.key, required this.progress, required this.label, this.size = 72});

  final double progress;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    return Semantics(
      label: '$label, ${(progress * 100).round()} percent',
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: clay.surfaceSunken,
              color: clay.accent,
            ),
            Center(child: Text('${(progress * 100).round()}%', style: context.text.titleSmall)),
          ],
        ),
      ),
    );
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: destructive ? context.clay.critical : context.clay.brand,
            foregroundColor: destructive ? context.clay.onCritical : context.clay.onBrand,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showClaySnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Small rounded label, e.g. "Pending clinical review".
class ClayTag extends StatelessWidget {
  const ClayTag(this.label, {super.key, this.tone = ClayTone.slate, this.icon});
  final String label;
  final ClayTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final pair = context.clay.tone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: pair.fill, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: pair.onFill), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium!.copyWith(color: pair.onFill),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid whose rows size to their content (equal height per row), so cards
/// never overflow at large text sizes. Two columns on phones, three wider.
class ClayGrid extends StatelessWidget {
  const ClayGrid({super.key, required this.children, this.minTileHeight = 132});
  final List<Widget> children;
  final double minTileHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 600 ? 3 : 2;
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += columns) {
          final rowChildren = children.sublist(i, (i + columns).clamp(0, children.length));
          rows.add(
            Padding(
              padding: EdgeInsets.only(bottom: i + columns < children.length ? Gap.lg : 0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = 0; j < columns; j++) ...[
                      Expanded(
                        child: j < rowChildren.length
                            ? ConstrainedBox(
                                constraints: BoxConstraints(minHeight: minTileHeight),
                                child: rowChildren[j],
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (j < columns - 1) const SizedBox(width: Gap.lg),
                    ],
                  ],
                ),
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}
