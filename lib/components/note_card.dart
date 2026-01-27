import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteCard extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const NoteCard({
    super.key,
    required this.text,
    required this.color,
    this.textColor = Colors.white,
  });

  double _calculateFontSize(BoxConstraints constraints, String text) {
    final double W = constraints.maxWidth;
    final double H = constraints.maxHeight;

    // N is strictly clamped to your 20-95 character range as requested
    final int N = text.length.clamp(20, 95);

    // C = 0.85 (Scale factor tuned for Serif/Stiki aesthetics)
    // L = 3.2  (Vertical safety divider to prevent clipping)
    const double C = 0.85;
    const double L = 3.2;

    // Area calculation for character density
    double areaScale = math.sqrt((W * H) / N) * C;

    // Height limit prevents vertical clipping in Wide Banner (4x2)
    double heightLimit = H / L;

    // Return the smaller of the two, clamped between a readable 12 and premium 28
    return math.min(areaScale, heightLimit).clamp(12.0, 28.0);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use provided constraints or fallback to a default size for rendering
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 200.0;
          final height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 200.0;
          final fontSize = _calculateFontSize(
            BoxConstraints.tight(Size(width, height)),
            text,
          );

          return Container(
            width: width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                // Nothing OS Style Red Dot (Top Right)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF0000), // Iconic red
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.9),
                      letterSpacing: -0.5,
                      height: 1.2, // Tighter line height for premium feel
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
