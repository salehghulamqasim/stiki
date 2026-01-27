import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stiki/theme/app_colors.dart';

class DoorSplashScreen extends StatefulWidget {
  final Widget child; // The content behind the splash (HomePage)
  final Duration animationDuration;

  const DoorSplashScreen({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<DoorSplashScreen> createState() => _DoorSplashScreenState();
}

class _DoorSplashScreenState extends State<DoorSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController scaleController;
  late Animation<double> scaleAnimation;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();

    scaleController =
        AnimationController(vsync: this, duration: widget.animationDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _isFinished = true;
              });
            }
          });

    scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.easeInOutExpo),
    );

    // Auto-start after a brief delay
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If animation is done, just show the child (Home Page) directly
    if (_isFinished) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background (Home Page)
          widget.child,

          // Splash Overlay
          AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, child) {
              return ClipPath(
                clipper: InvertedCircleClipper(scaleAnimation.value),
                child: Container(
                  color: AppColors.background,
                  child: Center(
                    child: Opacity(
                      opacity: (1.0 - scaleController.value * 3).clamp(
                        0.0,
                        1.0,
                      ),
                      child: Transform.scale(
                        scale: 1.0 + scaleController.value * 0.5,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkBackground.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class InvertedCircleClipper extends CustomClipper<Path> {
  final double scale;
  InvertedCircleClipper(this.scale);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Base radius
    final maxRadius =
        (size.width > size.height ? size.width : size.height) / 1.5;

    // As scale goes from 0 to 1.5, radius expands
    final currentRadius = maxRadius * scale;

    // Cut out the hole
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: currentRadius,
      ),
    );

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(InvertedCircleClipper oldClipper) =>
      oldClipper.scale != scale;
}
