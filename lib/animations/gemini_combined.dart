import 'package:flutter/material.dart';
import 'dart:math' as math;

class UnifiedStarAnimation extends StatefulWidget {
  final Color color;
  final double size;
  final Duration totalDuration;

  const UnifiedStarAnimation({
    super.key,
    this.color = Colors.pink,
    this.size = 50.0,
    this.totalDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<UnifiedStarAnimation> createState() => _UnifiedStarAnimationState();
}

class _UnifiedStarAnimationState extends State<UnifiedStarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;
  late Animation<double> _blur;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.totalDuration,
      vsync: this,
    )..repeat(reverse: true);

    _setupAnimations();
  }

  void _setupAnimations() {
    _rotation = Tween<double>(
      begin: 0.0,
      end: math.pi / 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scale = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _blur = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glow = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Transform.rotate(
              angle: _rotation.value,
              child: Transform.scale(
                scale: _scale.value,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: EnhancedStarPainter(
                    primaryColor: widget.color,
                    blur: _blur.value,
                    glowIntensity: _glow.value,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EnhancedStarPainter extends CustomPainter {
  final Color primaryColor;
  final double blur;
  final double glowIntensity;

  EnhancedStarPainter({
    required this.primaryColor,
    required this.blur,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final starPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: glowIntensity * 0.7)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * 2);

    final starPath = _createStarPath(center, size.width / 2 * 0.8);

    for (var i = 2; i > 0; i--) {
      canvas.drawPath(
        starPath,
        Paint()
          ..color = primaryColor.withValues(alpha: glowIntensity * 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * i),
      );
    }

    canvas.drawPath(starPath, glowPaint);
    canvas.drawPath(starPath, starPaint);
  }

  Path _createStarPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2);
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final controlX =
            center.dx + math.cos(angle - math.pi / 4) * (radius * 0.5);
        final controlY =
            center.dy + math.sin(angle - math.pi / 4) * (radius * 0.5);
        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }
    final lastControlX = center.dx + math.cos(-math.pi / 4) * (radius * 0.5);
    final lastControlY = center.dy + math.sin(-math.pi / 4) * (radius * 0.5);
    path.quadraticBezierTo(
      lastControlX,
      lastControlY,
      center.dx + radius,
      center.dy,
    );
    return path;
  }

  @override
  bool shouldRepaint(EnhancedStarPainter oldDelegate) => true;
}
