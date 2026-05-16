import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AuthBlobAnimationWidget extends StatefulWidget {
  const AuthBlobAnimationWidget({super.key});

  @override
  State<AuthBlobAnimationWidget> createState() =>
      _AuthBlobAnimationWidgetState();
}

class _AuthBlobAnimationWidgetState extends State<AuthBlobAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(painter: _BlobPainter(_controller.value));
        },
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double progress;
  _BlobPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppTheme.accent.withAlpha(20)
      ..style = PaintingStyle.fill;
    final paint2 = Paint()
      ..color = AppTheme.primary.withAlpha(15)
      ..style = PaintingStyle.fill;

    final t = progress * 2 * math.pi;

    // First blob
    final cx1 = size.width * 0.8 + math.cos(t * 0.7) * 30;
    final cy1 = size.height * 0.15 + math.sin(t * 0.5) * 20;
    final r1 = 120.0 + math.sin(t * 1.2) * 20;
    final path1 = _morphBlob(cx1, cy1, r1, t, 5);
    canvas.drawPath(path1, paint1);

    // Second blob
    final cx2 = size.width * 0.15 + math.cos(t * 0.4) * 20;
    final cy2 = size.height * 0.85 + math.sin(t * 0.6) * 25;
    final r2 = 90.0 + math.cos(t * 0.9) * 15;
    final path2 = _morphBlob(cx2, cy2, r2, t + math.pi, 4);
    canvas.drawPath(path2, paint2);

    // Third small accent blob
    final cx3 = size.width * 0.5 + math.cos(t * 0.3) * 40;
    final cy3 = size.height * 0.4 + math.sin(t * 0.8) * 30;
    final r3 = 55.0 + math.sin(t * 1.5) * 10;
    final path3 = _morphBlob(cx3, cy3, r3, t * 1.3, 6);
    canvas.drawPath(path3, paint1);
  }

  Path _morphBlob(double cx, double cy, double r, double t, int points) {
    final path = Path();
    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * 2 * math.pi;
      final noise = 1.0 + 0.25 * math.sin(angle * 3 + t);
      final x = cx + r * noise * math.cos(angle);
      final y = cy + r * noise * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_BlobPainter old) => true;
}
