import 'package:flutter/material.dart';

import '../../app/theme/clay_tokens.dart';

/// The base claymorphic surface: a rounded, softly lifted, "inflated" panel.
///
/// Flutter's [BoxShadow] cannot be inset, so the inner highlight and inner
/// shade are painted by [_InnerShadowPainter] on top of the fill.
class ClaySurface extends StatefulWidget {
  const ClaySurface({
    super.key,
    required this.child,
    this.color,
    this.radius = ClayTheme.radiusMd,
    this.padding = const EdgeInsets.all(Gap.lg),
    this.depth = 1,
    this.onTap,
    this.semanticLabel,
    this.sunken = false,
    this.selected = false,
  });

  final Widget child;
  final Color? color;
  final double radius;
  final EdgeInsetsGeometry padding;

  /// 0 = flat, 1 = standard card, 1.5 = hero.
  final double depth;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// Pressed-in look used for inputs and selected tiles.
  final bool sunken;
  final bool selected;

  @override
  State<ClaySurface> createState() => _ClaySurfaceState();
}

class _ClaySurfaceState extends State<ClaySurface> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final sunken = widget.sunken || _pressed;
    final fill = widget.color ?? (widget.sunken ? clay.surfaceSunken : clay.surface);
    final depth = sunken ? widget.depth * 0.25 : widget.depth;
    final radius = BorderRadius.circular(widget.radius);

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: widget.selected ? Border.all(color: clay.accent, width: 2) : null,
        boxShadow: depth == 0
            ? null
            : [
                BoxShadow(
                  color: clay.dropShadow,
                  offset: Offset(0, 10 * depth),
                  blurRadius: 24 * depth,
                  spreadRadius: -6,
                ),
                BoxShadow(
                  color: clay.dropShadow.withValues(alpha: clay.dropShadow.a * 0.5),
                  offset: Offset(0, 2 * depth),
                  blurRadius: 6 * depth,
                  spreadRadius: -2,
                ),
              ],
      ),
      child: CustomPaint(
        foregroundPainter: _InnerShadowPainter(
          radius: widget.radius,
          // A bright highlight on a dark fill reads as a smudge; soften it.
          highlight: fill.computeLuminance() < 0.15
              ? clay.innerHighlight.withValues(alpha: clay.innerHighlight.a * 0.25)
              : clay.innerHighlight,
          shade: clay.innerShade,
          inverted: sunken,
        ),
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );

    if (widget.onTap != null) {
      surface = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: surface,
        ),
      );
      surface = Semantics(
        container: true,
        button: true,
        label: widget.semanticLabel,
        selected: widget.selected,
        child: FocusableActionDetector(
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onTap!();
                return null;
              },
            ),
          },
          child: surface,
        ),
      );
    } else if (widget.semanticLabel != null) {
      surface = Semantics(container: true, label: widget.semanticLabel, child: surface);
    }

    return surface;
  }
}

class _InnerShadowPainter extends CustomPainter {
  _InnerShadowPainter({required this.radius, required this.highlight, required this.shade, required this.inverted});

  final double radius;
  final Color highlight;
  final Color shade;
  final bool inverted;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    canvas.save();
    canvas.clipRRect(rrect);
    // Top-left highlight gives the "inflated" look; bottom-right shade adds
    // volume. Swapped when pressed so the surface reads as pushed in.
    _inner(canvas, rrect, inverted ? shade : highlight, const Offset(5, 5), 10);
    _inner(canvas, rrect, inverted ? highlight : shade, const Offset(-6, -6), 12);
    canvas.restore();
  }

  void _inner(Canvas canvas, RRect rrect, Color color, Offset offset, double blur) {
    final outer = Rect.fromLTRB(-200, -200, rrect.width + 200, rrect.height + 200);
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(outer)
      ..addRRect(rrect.shift(offset));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur / 2),
    );
  }

  @override
  bool shouldRepaint(_InnerShadowPainter old) =>
      old.radius != radius || old.highlight != highlight || old.shade != shade || old.inverted != inverted;
}
