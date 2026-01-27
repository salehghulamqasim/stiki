// import 'package:flutter/material.dart';
// import 'dart:ui' as ui;
// import 'package:stiki/theme/app_colors.dart';

// class AuroraPainter extends CustomPainter {
//   final double progress;
//   final bool isDark;
//   final bool showRadialGradient;

//   AuroraPainter({
//     required this.progress,
//     required this.isDark,
//     required this.showRadialGradient,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Offset.zero & size;

//     // Background color
//     canvas.drawRect(
//       rect,
//       Paint()..color = isDark ? const Color(0xFF1A1A1A) : AppColors.background,
//     );

//     // Radial gradient in the center
//     if (showRadialGradient) {
//       final radialPaint = Paint()
//         ..shader = ui.Gradient.radial(
//           Offset(size.width / 2, size.height / 2), // Center
//           size.width * 0.8,
//           [
//             Colors.blue.withValues(alpha: 0.2),
//             Colors.purple.withValues(alpha: 0.1),
//             Colors.transparent,
//           ],
//           [0.0, 0.5, 1.0],
//         )
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

//       canvas.drawRect(rect, radialPaint);
//     }

//     // Add subtle animated movement
//     final movingGradient = Paint()
//       ..shader = ui.Gradient.linear(
//         Offset(size.width * progress, 0),
//         Offset(size.width * progress + 100, size.height),
//         [Colors.blue.withValues(alpha: 0.05), Colors.purple.withValues(alpha: 0.05)],
//         [0.0, 1.0],
//       )
//       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

//     canvas.drawRect(rect, movingGradient);
//   }

//   @override
//   bool shouldRepaint(AuroraPainter oldDelegate) {
//     return oldDelegate.progress != progress;
//   }
// }

// class AuroraBackground extends StatefulWidget {
//   final Widget child;
//   final bool showRadialGradient;

//   const AuroraBackground({
//     super.key,
//     required this.child,
//     this.showRadialGradient = true,
//   });

//   @override
//   State<AuroraBackground> createState() => _AuroraBackgroundState();
// }

// class _AuroraBackgroundState extends State<AuroraBackground>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 10),
//       vsync: this,
//     )..repeat(reverse: true);

//     _animation = Tween<double>(
//       begin: -0.2,
//       end: 1.2,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: Stack(
//         children: [
//           AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return CustomPaint(
//                 painter: AuroraPainter(
//                   progress: _animation.value,
//                   isDark: Theme.of(context).brightness == Brightness.dark,
//                   showRadialGradient: widget.showRadialGradient,
//                 ),
//                 size: Size.infinite,
//               );
//             },
//           ),
//           Center(child: widget.child),
//         ],
//       ),
//     );
//   }
// }
