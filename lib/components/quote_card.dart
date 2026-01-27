import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stiki/theme/app_colors.dart';

class QuoteCard extends StatelessWidget {
  final String quote;
  final String author;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const QuoteCard({
    super.key,
    required this.quote,
    this.author = '', // Optional author
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(36), // Rounded corners like image
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with badge and quote mark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "DAILY QUOTE" Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "DAILY QUOTE",
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.6),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // Quote mark image
              Image.asset(
                'assets/quote.png',
                height: 52,
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // The Quote Text
          Text(
            '"$quote"',
            style: GoogleFonts.merriweather(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary, // Dark charcoal
              height: 1.4, // Good line height for readability
            ),
          ),

          // The Author (if provided)
          if (author.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              "— $author",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary, // Softer grey for author
              ),
            ),
          ],
        ],
      ),
    );
  }
}
