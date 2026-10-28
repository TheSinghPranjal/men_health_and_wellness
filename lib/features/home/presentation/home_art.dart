import 'package:flutter/material.dart';

/// Decorative sunrise over layered mountains for the home header. Fades
/// out towards its left and bottom edges so text can sit beside it.
class SunriseArt extends StatelessWidget {
  const SunriseArt({super.key, required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: width,
      height: width * 0.78,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (r) => const RadialGradient(
          center: Alignment(0.5, -0.3),
          radius: 0.95,
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0, 0.55, 1],
        ).createShader(r),
        child: CustomPaint(painter: _SunrisePainter(dark: dark)),
      ),
    );
  }
}

class _SunrisePainter extends CustomPainter {
  _SunrisePainter({required this.dark});
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF1E3550), Color(0xFF3A4A62), Color(0xFF5B5468)]
              : const [Color(0xFFCFE6EE), Color(0xFFF4E6CF), Color(0xFFFBD9A8)],
        ).createShader(rect),
    );

    final sun = Offset(w * 0.55, h * 0.5);
    canvas.drawCircle(
      sun,
      w * 0.22,
      Paint()
        ..color = const Color(0xFFFFE3A3).withValues(alpha: dark ? 0.35 : 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.08),
    );
    canvas.drawCircle(sun, w * 0.075, Paint()..color = const Color(0xFFFFF1C9));

    _ridge(canvas, size, [
      0.0,
      0.62,
      0.25,
      0.42,
      0.45,
      0.55,
      0.7,
      0.3,
      0.88,
      0.45,
      1.0,
      0.38,
    ], dark ? const Color(0xFF41597A) : const Color(0xFFA9C3D3));
    _ridge(canvas, size, [
      0.0,
      0.75,
      0.2,
      0.6,
      0.4,
      0.7,
      0.6,
      0.52,
      0.8,
      0.66,
      1.0,
      0.56,
    ], dark ? const Color(0xFF2F4762) : const Color(0xFF7FA3B8));
    _ridge(canvas, size, [
      0.0,
      0.88,
      0.3,
      0.78,
      0.55,
      0.86,
      0.75,
      0.74,
      1.0,
      0.8,
    ], dark ? const Color(0xFF223850) : const Color(0xFF5E879D));

    final pine = Paint()..color = dark ? const Color(0xFF1A3A36) : const Color(0xFF3F6E5E);
    for (final (x, s) in const [(0.72, 1.0), (0.79, 0.8), (0.86, 1.15), (0.93, 0.9)]) {
      final bx = w * x;
      final by = h * 0.86;
      final th = h * 0.16 * s;
      canvas.drawPath(
        Path()
          ..moveTo(bx, by - th)
          ..lineTo(bx + th * 0.28, by)
          ..lineTo(bx - th * 0.28, by)
          ..close(),
        pine,
      );
    }
  }

  /// Fills below a polyline of (x, y) fractions.
  void _ridge(Canvas canvas, Size size, List<double> pts, Color color) {
    final path = Path()..moveTo(0, size.height);
    for (var i = 0; i < pts.length; i += 2) {
      path.lineTo(pts[i] * size.width, pts[i + 1] * size.height);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SunrisePainter old) => old.dark != dark;
}

/// Small clipboard checklist with leaves, decorating the routine card.
class ChecklistArt extends StatelessWidget {
  const ChecklistArt({super.key, required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: SizedBox(
        width: width,
        child: AspectRatio(aspectRatio: 0.9, child: CustomPaint(painter: _ChecklistPainter())),
      ),
    );
  }
}

class _ChecklistPainter extends CustomPainter {
  static const _teal = Color(0xFF2F8C86);
  static const _leaf = Color(0xFF5FA36A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (final (dx, dy, angle) in const [(0.12, 0.72, -0.9), (0.2, 0.5, -0.4), (0.9, 0.72, 0.8)]) {
      canvas.save();
      canvas.translate(w * dx, h * dy);
      canvas.rotate(angle);
      canvas.drawPath(
        Path()
          ..moveTo(0, -h * 0.2)
          ..quadraticBezierTo(w * 0.12, 0, 0, h * 0.2)
          ..quadraticBezierTo(-w * 0.12, 0, 0, -h * 0.2),
        Paint()..color = _leaf.withValues(alpha: 0.8),
      );
      canvas.restore();
    }
    final board = Rect.fromLTWH(w * 0.24, h * 0.1, w * 0.52, h * 0.82);
    canvas.drawRRect(RRect.fromRectAndRadius(board, const Radius.circular(8)), Paint()..color = _teal);
    final paper = board.deflate(w * 0.04);
    canvas.drawRRect(RRect.fromRectAndRadius(paper, const Radius.circular(4)), Paint()..color = Colors.white);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(board.center.dx, board.top + 2), width: w * 0.2, height: h * 0.08),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1E5F5B),
    );
    final stroke = Paint()
      ..color = _teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = paper.top + paper.height * (0.25 + i * 0.27);
      final box = Rect.fromLTWH(paper.left + 5, y - 5, 10, 10);
      canvas.drawRect(box, stroke);
      canvas.drawPath(
        Path()
          ..moveTo(box.left + 2, box.center.dy)
          ..lineTo(box.center.dx, box.bottom - 2)
          ..lineTo(box.right + 2, box.top - 1),
        stroke,
      );
      canvas.drawLine(
        Offset(box.right + 6, y),
        Offset(paper.right - 5, y),
        Paint()
          ..color = _teal.withValues(alpha: 0.35)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ChecklistPainter old) => false;
}

/// Clipboard checklist beside a bullseye target, for the habit form header.
class GoalArt extends StatelessWidget {
  const GoalArt({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox.square(
        dimension: 200,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFFCDE7E3), const Color(0xFFCDE7E3).withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            const Positioned(left: 8, top: 22, child: ChecklistArt(width: 130)),
            const Positioned(
              right: 4,
              top: 48,
              child: CustomPaint(size: Size(96, 96), painter: _TargetPainter()),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetPainter extends CustomPainter {
  const _TargetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      c.translate(0, 4),
      r,
      Paint()
        ..color = const Color(0x33124A55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    for (final (f, color) in const [
      (1.0, Color(0xFF1C8BA8)),
      (0.74, Color(0xFFFFFFFF)),
      (0.52, Color(0xFF2AA3B8)),
      (0.3, Color(0xFFFFFFFF)),
      (0.14, Color(0xFF1C8BA8)),
    ]) {
      canvas.drawCircle(c, r * f, Paint()..color = color);
    }
    // Arrow landing in the bullseye.
    final tail = c + Offset(r * 0.95, -r * 0.95);
    canvas.drawLine(
      c,
      tail,
      Paint()
        ..color = const Color(0xFF124A55)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    final fletch = Paint()..color = const Color(0xFF2F8C86);
    canvas.drawPath(
      Path()
        ..moveTo(tail.dx, tail.dy)
        ..lineTo(tail.dx - 14, tail.dy - 2)
        ..lineTo(tail.dx - 6, tail.dy + 6)
        ..close(),
      fletch,
    );
    canvas.drawPath(
      Path()
        ..moveTo(tail.dx, tail.dy)
        ..lineTo(tail.dx + 2, tail.dy + 14)
        ..lineTo(tail.dx - 6, tail.dy + 6)
        ..close(),
      fletch,
    );
  }

  @override
  bool shouldRepaint(_TargetPainter old) => false;
}
