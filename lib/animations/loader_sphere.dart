// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// class BouncingSquare extends StatefulWidget {
//   final double size;
//   final Color color;

//   const BouncingSquare({super.key, this.size = 100, this.color = Colors.black});

//   @override
//   State<BouncingSquare> createState() => _BouncingSquareState();
// }

// class _BouncingSquareState extends State<BouncingSquare>
//     with TickerProviderStateMixin {
//   late AnimationController _mainController;
//   late AnimationController _radiusController;
//   late Animation<double> _jumpAnimation;
//   late Animation<double> _rotationAnimation;
//   late Animation<double> _cornerRadiusAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _shadowSizeAnimation;
//   late Animation<double> _shadowOpacityAnimation;

//   int _bottomCorner = 0;
//   double _currentRotation = math.pi / 4;

//   void _updateRotationAnimation() {
//     _rotationAnimation = Tween<double>(
//       begin: _currentRotation,
//       end: _currentRotation + math.pi / 2,
//     ).animate(_mainController);
//   }

//   @override
//   void initState() {
//     super.initState();

//     _mainController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _radiusController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _mainController.forward();
//     _radiusController.repeat();

//     _mainController.addListener(() {
//       if (_jumpAnimation.value == 0 || _jumpAnimation.value > -50) {
//         _radiusController.forward();
//       } else {
//         _radiusController.reverse();
//       }

//       if (_mainController.status == AnimationStatus.completed) {
//         setState(() {
//           _bottomCorner = (_bottomCorner - 1 < 0) ? 3 : _bottomCorner - 1;
//           _currentRotation += math.pi / 2;
//           _updateRotationAnimation();
//           _mainController.forward(from: 0);
//         });
//       }
//     });

//     _jumpAnimation = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween<double>(
//           begin: 0,
//           end: -100,
//         ).chain(CurveTween(curve: Curves.easeOut)),
//         weight: 50,
//       ),
//       TweenSequenceItem(
//         tween: Tween<double>(
//           begin: -100,
//           end: 0,
//         ).chain(CurveTween(curve: Curves.easeIn)),
//         weight: 50,
//       ),
//     ]).animate(_mainController);

//     _scaleAnimation = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween<double>(
//           begin: 1.0,
//           end: 1.2,
//         ).chain(CurveTween(curve: Curves.easeOut)),
//         weight: 50,
//       ),
//       TweenSequenceItem(
//         tween: Tween<double>(
//           begin: 1.2,
//           end: 1.0,
//         ).chain(CurveTween(curve: Curves.easeIn)),
//         weight: 50,
//       ),
//     ]).animate(_mainController);

//     _shadowSizeAnimation = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween<double>(
//           begin: 200,
//           end: 40,
//         ).chain(CurveTween(curve: Curves.easeOut)),
//         weight: 50,
//       ),
//       TweenSequenceItem(
//         tween: Tween<double>(
//           begin: 40,
//           end: 200,
//         ).chain(CurveTween(curve: Curves.easeIn)),
//         weight: 50,
//       ),
//     ]).animate(_mainController);

//     _shadowOpacityAnimation = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween<double>(
//           begin: 0.1,
//           end: 0.05,
//         ).chain(CurveTween(curve: Curves.easeOut)),
//         weight: 50,
//       ),
//       TweenSequenceItem(
//         tween: Tween<double>(
//           begin: 0.05,
//           end: 0.1,
//         ).chain(CurveTween(curve: Curves.easeIn)),
//         weight: 50,
//       ),
//     ]).animate(_mainController);

//     _rotationAnimation = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween<double>(
//           begin: _currentRotation,
//           end: _currentRotation + math.pi / 2,
//         ),
//         weight: 100,
//       ),
//     ]).animate(_mainController);

//     _cornerRadiusAnimation = Tween<double>(begin: 0, end: 80).animate(
//       CurvedAnimation(parent: _radiusController, curve: Curves.easeInOut),
//     );

//     _updateRotationAnimation();
//   }

//   @override
//   void dispose() {
//     _mainController.dispose();
//     _radiusController.dispose();
//     super.dispose();
//   }

//   BorderRadius getCornerRadius() {
//     final radiusValue = _cornerRadiusAnimation.value;

//     switch (_bottomCorner) {
//       case 0:
//         return BorderRadius.only(bottomRight: Radius.circular(radiusValue));
//       case 1:
//         return BorderRadius.only(bottomLeft: Radius.circular(radiusValue));
//       case 2:
//         return BorderRadius.only(topLeft: Radius.circular(radiusValue));
//       case 3:
//         return BorderRadius.only(topRight: Radius.circular(radiusValue));
//       default:
//         return BorderRadius.zero;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Scale factor based on default size of 100
//     final double scale = widget.size / 100.0;

//     return SizedBox(
//       width: widget.size * 2, // Allow space for shadow
//       height: widget.size * 2.5, // Allow space for jump
//       child: AnimatedBuilder(
//         animation: Listenable.merge([_mainController, _radiusController]),
//         builder: (context, child) {
//           return Stack(
//             alignment: Alignment.center,
//             children: [
//               // Animated shadow
//               Transform.translate(
//                 offset: Offset(0, 80 * scale),
//                 child: Transform.scale(
//                   scaleX: 0.7,
//                   scaleY: 0.2,
//                   child: Container(
//                     width: _shadowSizeAnimation.value * scale,
//                     height: _shadowSizeAnimation.value * scale,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(
//                         _shadowOpacityAnimation.value,
//                       ),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(
//                             _shadowOpacityAnimation.value,
//                           ),
//                           blurRadius: 20 * scale,
//                           spreadRadius: 5 * scale,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               // Bouncing square
//               Transform.translate(
//                 offset: Offset(0, _jumpAnimation.value * scale),
//                 child: Transform.rotate(
//                   angle: _rotationAnimation.value,
//                   child: Transform.scale(
//                     scale: _scaleAnimation.value,
//                     child: Container(
//                       width: widget.size,
//                       height: widget.size,
//                       decoration: BoxDecoration(
//                         color: widget.color,
//                         // Scale the border radius
//                         borderRadius: BorderRadius.only(
//                           bottomRight: (_bottomCorner == 0)
//                               ? Radius.circular(
//                                   _cornerRadiusAnimation.value * scale,
//                                 )
//                               : Radius.zero,
//                           bottomLeft: (_bottomCorner == 1)
//                               ? Radius.circular(
//                                   _cornerRadiusAnimation.value * scale,
//                                 )
//                               : Radius.zero,
//                           topLeft: (_bottomCorner == 2)
//                               ? Radius.circular(
//                                   _cornerRadiusAnimation.value * scale,
//                                 )
//                               : Radius.zero,
//                           topRight: (_bottomCorner == 3)
//                               ? Radius.circular(
//                                   _cornerRadiusAnimation.value * scale,
//                                 )
//                               : Radius.zero,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
