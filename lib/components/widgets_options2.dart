import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stiki/animations/stiki_animations.dart';
import 'package:stiki/theme/app_colors.dart';

class WidgetOptionCard2 extends StatelessWidget {
  final String title;
  final Color backgroundColor; // Card background
  final Color circleColor; // Circle background
  final Color iconColor; // + Icon color
  final Color textColor; // Title text color
  final VoidCallback? onTap;

  const WidgetOptionCard2({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.circleColor = const Color(0xFFFDF4D1), // Default yellow circle
    this.iconColor = const Color(0xFF6D4C41), // Default brown icon
    this.textColor = AppColors.textPrimary, // Default dark text
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CozyTapScale(
      onTap: onTap,
      child: Container(
        width: 165, // Absolute width for stability
        height: 150,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: iconColor, size: 20),
                ),
              ],
            ),

            const Spacer(),

            // Using FittedBox to prevent text overflow in the fixed-width card
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
