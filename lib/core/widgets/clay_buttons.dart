import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/clay_tokens.dart';
import 'clay_surface.dart';

enum ClayButtonVariant { primary, secondary, quiet, danger }

class ClayButton extends StatelessWidget {
  const ClayButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ClayButtonVariant.primary,
    this.expand = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ClayButtonVariant variant;
  final bool expand;

  /// Shows a spinner and blocks taps to prevent duplicate submissions.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final enabled = onPressed != null && !loading;
    final (bg, fg) = switch (variant) {
      ClayButtonVariant.primary => (clay.brand, clay.onBrand),
      ClayButtonVariant.secondary => (clay.surface, clay.textPrimary),
      ClayButtonVariant.quiet => (clay.surfaceSunken, clay.textPrimary),
      ClayButtonVariant.danger => (clay.critical, clay.onCritical),
    };

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
        else if (icon != null)
          Icon(icon, size: 20, color: fg),
        if (loading || icon != null) const SizedBox(width: Gap.sm),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.text.labelLarge!.copyWith(color: fg).weight(800),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: ClaySurface(
          color: bg,
          radius: 20,
          depth: variant == ClayButtonVariant.quiet ? 0.4 : 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          onTap: enabled ? onPressed : null,
          semanticLabel: label,
          child: content,
        ),
      ),
    );
  }
}

/// Round clay icon button with a 48dp minimum target.
class ClayIconButton extends StatelessWidget {
  const ClayIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 48,
        child: ClaySurface(
          color: color,
          radius: 18,
          depth: 0.7,
          padding: EdgeInsets.zero,
          onTap: onPressed,
          semanticLabel: tooltip,
          child: Center(child: Icon(icon, size: 22, color: iconColor ?? context.clay.textPrimary)),
        ),
      ),
    );
  }
}

/// Small rounded "pill" of clay holding an icon, used to colour-code topics.
class ClayIconBadge extends StatelessWidget {
  const ClayIconBadge({super.key, required this.icon, required this.tone, this.size = 48});

  final IconData icon;
  final ClayTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pair = context.clay.tone(tone);
    return SizedBox.square(
      dimension: size,
      child: ClaySurface(
        color: pair.fill,
        radius: size * 0.36,
        depth: 0.5,
        padding: EdgeInsets.zero,
        child: Center(
          child: Icon(icon, color: pair.onFill, size: size * 0.48),
        ),
      ),
    );
  }
}
