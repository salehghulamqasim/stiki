import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "DAILY QUOTE",
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.6),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // Quote mark image
              Image.asset(
                'assets/quote.png',
                height: 52.h,
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // The Quote Text
          Text(
            '"$quote"',
            style: GoogleFonts.merriweather(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary, // Dark charcoal
              height: 1.4, // Good line height for readability
            ),
          ),

          // The Author (if provided)
          if (author.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              "— $author",
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
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
