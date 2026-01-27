import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final int charCount = text.length;

    // Aspect ratio of the widget
    final aspectRatio = W / H;

    // Available space after padding
    final availableWidth = W - 32;
    final availableHeight = H - 32;

    // Estimate characters per line based on widget shape
    double charsPerLine;
    if (aspectRatio > 1.5) {
      // Wide widgets needs more characters per line
      charsPerLine = 20.0 + (aspectRatio - 1.5) * 8;
    } else if (aspectRatio < 0.7) {
      // Tall widgets needs fewer characters per line
      charsPerLine = 10.0 - (0.7 - aspectRatio) * 4;
    } else {
      // Balanced square-ish widgets
      charsPerLine = 14.0;
    }
    charsPerLine = charsPerLine.clamp(6.0, 30.0);

    // Estimate theoretical lines needed for the text
    final estimatedLines = (charCount / charsPerLine).ceil().clamp(1, 20);

    // Calculate font size based on width constraints (0.5 is approx char width ratio for Poppins)
    final fontSizeFromWidth = (availableWidth / charsPerLine) / 0.5;

    // Calculate font size based on height constraints (1.15 is line height multiplier)
    final fontSizeFromHeight = availableHeight / (estimatedLines * 1.15);

    // text must fit within both width and height, so take the smaller value
    double baseFontSize = math.min(fontSizeFromWidth, fontSizeFromHeight);

    // Adjust for extreme aspect ratios to prevent edge clipping
    if (aspectRatio > 2.0) {
      baseFontSize *= 0.95;
    } else if (aspectRatio < 0.5) {
      baseFontSize *= 0.90;
    }

    // --- STEP 7: Granular Character Count Scaling ---
    // Highest to lowest priority (Desc order mandatory for logic)

    // 1. EXTRA LONG (Emergency brake)
    if (charCount > 95) {
      baseFontSize *= 0.75;
    }
    // 2. VERY LONG
    else if (charCount > 80) {
      baseFontSize *= 0.80;
    }
    // 3. LONG
    else if (charCount > 70) {
      baseFontSize *= 0.88;
    }
    // 4. MEDIUM-LONG
    else if (charCount > 60) {
      baseFontSize *= 0.92;
    }
    // 5. SHORT (Boost factor)
    else if (charCount < 15) {
      baseFontSize *= 1.20; // Big pop for single words like "Focus."
    }
    // 6. MEDIUM-SHORT (Mild boost)
    else if (charCount < 30) {
      baseFontSize *= 1.10;
    }

    // Ensure font size stays within readable limits
    return baseFontSize.clamp(14.0, 32.0);
  }

  int _calculateMaxLines(double height, double fontSize) {
    // Account for padding (16 top + 16 bottom = 32)
    final availableHeight = height - 32;

    // Line height is fontSize * 1.2 (as set in Text style)
    final lineHeight = fontSize * 1.2;

    // Calculate maximum lines that can fit
    final maxLines = (availableHeight / lineHeight).floor();

    // Clamp between 2 and 30 lines (increased from 20)
    return maxLines.clamp(2, 30);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use provided constraints or fallback to default
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

          final maxLines = _calculateMaxLines(height, fontSize);

          return Container(
            width: width,
            height: height,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Stack(
              children: [
                // Nothing OS Style Red Dot (Top Right)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 6.w,
                    height: 6.h,
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
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: GoogleFonts.poppins(
                      fontSize: fontSize.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.9),
                      letterSpacing: -0.5,
                      height: 1.2,
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
