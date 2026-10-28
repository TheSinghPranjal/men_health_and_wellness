import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative "books, lightbulb and leaves" artwork for the Learn screen.
///
/// Painted rather than bundled as an image so it stays crisp at any size and
/// adds nothing to the app download. Purely decorative: wrap callers in
/// [ExcludeSemantics].
class LearnIllustration extends StatelessWidget {
  const LearnIllustration({super.key, required this.width, this.onDark = false});

  final double width;

  /// Stronger glow and lighter page edges for use on the dark hero card.
  final bool onDark;

  /// Design-space size the painter draws in before scaling.
  static const _designSize = Size(160, 130);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * _designSize.height / _designSize.width,
      child: CustomPaint(painter: _LearnIllustrationPainter(onDark: onDark)),
    );
  }
}

class _LearnIllustrationPainter extends CustomPainter {
  _LearnIllustrationPainter({required this.onDark});

  final bool onDark;

  static const _pages = Color(0xFFF3E7CF);
  static const _bookA = Color(0xFF24476B);
  static const _bookB = Color(0xFF2F6F8F);
  static const _bookC = Color(0xFF1F3F66);
  static const _leafDark = Color(0xFF4E9460);
  static const _leafLight = Color(0xFF7CC08A);
  static const _ray = Color(0xFFF5B83D);

  @override
  void paint(Canvas canvas, Size size) {
    final d = LearnIllustration._designSize;
    canvas.save();
    canvas.scale(size.width / d.width, size.height / d.height);

    _leaves(canvas);
    _book(canvas, const Rect.fromLTWH(8, 100, 132, 24), _bookA);
    _book(canvas, const Rect.fromLTWH(20, 80, 112, 20), _bookB);
    _book(canvas, const Rect.fromLTWH(32, 62, 90, 18), _bookC);
    _bulb(canvas, const Offset(77, 30));

    canvas.restore();
  }

  void _leaves(Canvas canvas) {
    final stem = Paint()
      ..color = _leafDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(138, 118)
        ..quadraticBezierTo(146, 70, 136, 22),
      stem,
    );
    for (final (center, angle, color) in const [
      (Offset(150, 92), 0.7, _leafLight),
      (Offset(128, 76), -0.8, _leafDark),
      (Offset(150, 56), 0.5, _leafDark),
      (Offset(128, 40), -0.6, _leafLight),
      (Offset(140, 20), 0.1, _leafLight),
    ]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final leaf = Path()
        ..moveTo(0, -16)
        ..quadraticBezierTo(10, 0, 0, 16)
        ..quadraticBezierTo(-10, 0, 0, -16);
      canvas.drawPath(leaf, Paint()..color = color);
      canvas.drawLine(
        const Offset(0, -12),
        const Offset(0, 12),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
      canvas.restore();
    }
  }

  void _book(Canvas canvas, Rect r, Color cover) {
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: onDark ? 0.35 : 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRRect(RRect.fromRectAndRadius(r.shift(const Offset(0, 2)), const Radius.circular(4)), shadow);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), Paint()..color = cover);
    // Page block on the right with a few page lines.
    final pages = Rect.fromLTRB(r.right - r.width * 0.42, r.top + 3, r.right - 2, r.bottom - 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pages, const Radius.circular(2)),
      Paint()..color = onDark ? _pages : _pages.withValues(alpha: 0.95),
    );
    final line = Paint()
      ..color = cover.withValues(alpha: 0.18)
      ..strokeWidth = 0.8;
    for (var y = pages.top + 4; y < pages.bottom - 2; y += 4) {
      canvas.drawLine(Offset(pages.left + 2, y), Offset(pages.right - 2, y), line);
    }
    // Top highlight so the cover reads as rounded.
    canvas.drawLine(
      Offset(r.left + 4, r.top + 1.5),
      Offset(pages.left - 4, r.top + 1.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _bulb(Canvas canvas, Offset c) {
    const r = 17.0;
    canvas.drawCircle(
      c,
      r * (onDark ? 2.1 : 1.7),
      Paint()
        ..color = const Color(0xFFFFE07A).withValues(alpha: onDark ? 0.45 : 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, onDark ? 18 : 12),
    );
    final rays = Paint()
      ..color = _ray
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 7; i++) {
      final a = math.pi + i * math.pi / 6;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * (r + 6), c + dir * (r + 14), rays);
    }
    // Screw base resting on the top book.
    final base = Rect.fromCenter(center: Offset(c.dx, c.dy + r + 8), width: 14, height: 14);
    canvas.drawRRect(RRect.fromRectAndRadius(base, const Radius.circular(3)), Paint()..color = const Color(0xFF5E6B80));
    final thread = Paint()
      ..color = const Color(0xFF8A96A8)
      ..strokeWidth = 1.4;
    for (var y = base.top + 4; y < base.bottom; y += 4) {
      canvas.drawLine(Offset(base.left + 1, y), Offset(base.right - 1, y), thread);
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFFFFFBE0), Color(0xFFFFE27A), Color(0xFFF7BE3C)],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Filament.
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 5, c.dy + 6)
        ..quadraticBezierTo(c.dx - 6, c.dy - 2, c.dx, c.dy)
        ..quadraticBezierTo(c.dx + 6, c.dy - 2, c.dx + 5, c.dy + 6),
      Paint()
        ..color = const Color(0xFFC98A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(_LearnIllustrationPainter old) => old.onDark != onDark;
}
