import 'package:flutter/material.dart';

import 'package:stiki/utils/haptic_helper.dart';

/// A collection of premium, cozy animations for the Stiki app.
/// Following the design philosophy of organic flow and subtle sophistication.

/// Global animation settings for performance optimization
/// On lower-end devices (like Infinix), reduce animation complexity
class AnimationSettings {
  static bool _reducedMotion = false;
  static int _maxStaggeredAnimations = 10;

  /// Enable reduced motion for better performance on lower-end devices
  static void setReducedMotion(bool value) {
    _reducedMotion = value;
  }

  /// Set maximum number of staggered animations to run simultaneously
  static void setMaxStaggeredAnimations(int value) {
    _maxStaggeredAnimations = value;
  }

  static bool get reducedMotion => _reducedMotion;
  static int get maxStaggeredAnimations => _maxStaggeredAnimations;

  /// Auto-detect if device needs reduced animations (call on app start)
  static void autoDetectPerformance() {
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final view = dispatcher.views.first;

    // Check screen size AND pixel density as proxy for device tier
    final shortestSide = view.physicalSize.shortestSide;
    final devicePixelRatio = view.devicePixelRatio;
    final logicalShortSide = shortestSide / devicePixelRatio;

    // Budget phones often have: small logical screen OR low pixel ratio
    // Infinix, Tecno, early Samsung A-series typically fall here
    if (shortestSide <= 720 ||
        logicalShortSide < 360 ||
        devicePixelRatio < 2.0) {
      _reducedMotion = true;
      _maxStaggeredAnimations = 4;
    } else if (shortestSide < 1080) {
      // Mid-range: keep animations but limit stagger count
      _maxStaggeredAnimations = 6;
    }
  }
}

class PremiumEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;
  final bool enableHaptic;

  const PremiumEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = const Duration(milliseconds: 150),
    this.duration = const Duration(milliseconds: 900),
    this.slideOffset = const Offset(0, 20),
    this.enableHaptic = false,
  });

  @override
  State<PremiumEntrance> createState() => _PremiumEntranceState();
}

class _PremiumEntranceState extends State<PremiumEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _skipAnimation = false;

  @override
  void initState() {
    super.initState();

    // Performance optimization: skip animation entirely on budget devices
    // or for items beyond stagger threshold
    if (AnimationSettings.reducedMotion ||
        widget.index >= AnimationSettings.maxStaggeredAnimations) {
      _skipAnimation = true;
      _controller = AnimationController(vsync: this, duration: Duration.zero);
      _opacityAnimation = AlwaysStoppedAnimation(1.0);
      _scaleAnimation = AlwaysStoppedAnimation(1.0);
      _slideAnimation = AlwaysStoppedAnimation(Offset.zero);
      return;
    }

    final effectiveDuration = widget.duration;

    _controller = AnimationController(vsync: this, duration: effectiveDuration);

    // Custom cubic bezier (0.16, 1, 0.3, 1) for smooth deceleration
    final curve = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(curve);

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(curve);

    final staggerDelay = 100;

    // Start with a staggered delay
    Future.delayed(
      widget.delay + Duration(milliseconds: widget.index * staggerDelay),
      () {
        if (mounted) {
          if (widget.enableHaptic) {
            HapticHelper.selection();
          }
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Skip animation completely for items beyond threshold
    if (_skipAnimation) {
      return RepaintBoundary(child: widget.child);
    }

    // Use FadeTransition instead of Opacity widget — much cheaper on GPU
    // Opacity creates an offscreen buffer; FadeTransition uses alpha blending directly
    return FadeTransition(
      opacity: _opacityAnimation,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: _slideAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          );
        },
        child: RepaintBoundary(child: widget.child),
      ),
    );
  }
}

class CozyTapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const CozyTapScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
  });

  @override
  State<CozyTapScale> createState() => _CozyTapScaleState();
}

class _CozyTapScaleState extends State<CozyTapScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return; //added this line at jan 21 by me saleh :)
    _controller.forward();
    HapticHelper.selection();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: RepaintBoundary(child: widget.child),
      ),
    );
  }
}

class CreationEntrance extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const CreationEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<CreationEntrance> createState() => _CreationEntranceState();
}

class _CreationEntranceState extends State<CreationEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curve = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(curve);
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    // Subtle rotation (2-3 degrees = ~0.04 radians)
    _rotationAnimation = Tween<double>(begin: 0.05, end: 0.0).animate(curve);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          );
        },
        child: RepaintBoundary(child: widget.child),
      ),
    );
  }
}

class GlowAnimation extends StatefulWidget {
  final Widget child;
  final bool isFocused;
  final Color glowColor;

  const GlowAnimation({
    super.key,
    required this.child,
    required this.isFocused,
    required this.glowColor,
  });

  @override
  State<GlowAnimation> createState() => _GlowAnimationState();
}

class _GlowAnimationState extends State<GlowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(GlowAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFocused) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(
                  alpha: 0.15 * _glowAnimation.value,
                ),
                blurRadius: 15 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SlideHide extends StatefulWidget {
  final Widget child;
  final bool isVisible;
  final Duration duration;

  const SlideHide({
    super.key,
    required this.child,
    required this.isVisible,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<SlideHide> createState() => _SlideHideState();
}

class _SlideHideState extends State<SlideHide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _sizeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    if (widget.isVisible) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SlideHide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SizeTransition(
        sizeFactor: _sizeAnimation,
        axisAlignment: 0.0,
        child: widget.child,
      ),
    );
  }
}

class PageTransitionHelper {
  static Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Cubic(0.16, 1.0, 0.3, 1.0);

        var slideTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: const Interval(0.0, 0.3)));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
