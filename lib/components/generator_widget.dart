import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stiki/theme/app_colors.dart';
import 'package:stiki/animations/stiki_animations.dart';
import 'package:stiki/utils/haptic_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GeneratorWidget extends StatefulWidget {
  final bool isLoading;
  final String quote;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final String frequency;
  final Function(String)? onFrequencyChanged;
  final bool isDeepMode; //if enabled or not
  final ValueChanged<bool>? onDeepModeChanged; //if deep mode is toggled or not

  const GeneratorWidget({
    super.key,
    required this.quote,
    required this.backgroundColor,
    this.onTap,
    this.controller,
    this.frequency = "daily",
    this.onFrequencyChanged,
    this.isDeepMode = false,
    this.onDeepModeChanged,
    this.isLoading = false,
  });

  @override
  State<GeneratorWidget> createState() => _GeneratorWidgetState();
}

class _GeneratorWidgetState extends State<GeneratorWidget> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.backgroundColor.computeLuminance() < 0.5;
    final Color contentColor = isDark
        ? AppColors.textLight
        : AppColors.textPrimary;
    final Color labelColor = contentColor.withValues(alpha: 0.6);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Topic",
            style: GoogleFonts.varelaRound(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          SizedBox(height: 12.h),

          TextField(
            controller: widget.controller,
            style: GoogleFonts.poppins(fontSize: 16.sp, color: contentColor),
            decoration: InputDecoration(
              hintText: "e.g. Health & Fitness quotes",
              hintStyle: TextStyle(color: contentColor.withValues(alpha: 0.3)),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: contentColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          Text(
            "Frequency",
            style: GoogleFonts.varelaRound(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          SizedBox(height: 12.h),

          Row(
            children: [
              _buildFrequencyOption(
                context,
                "hourly",
                "Hourly",
                isDark,
                contentColor,
              ),
              SizedBox(width: 8.w),
              _buildFrequencyOption(
                context,
                "daily",
                "Daily",
                isDark,
                contentColor,
              ),
              SizedBox(width: 8.w),
              _buildFrequencyOption(
                context,
                "weekly",
                "Weekly",
                isDark,
                contentColor,
              ),
            ],
          ),

          SizedBox(height: 32.h),
          Row(
            children: [
              GestureDetector(
                onTap: widget.onDeepModeChanged == null
                    ? null
                    : () {
                        HapticHelper.heavy();
                        widget.onDeepModeChanged!.call(!widget.isDeepMode);
                      },
                child: _buildDeepModeToggle(
                  isDeepMode: widget.isDeepMode,
                  isDarkTheme: isDark,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "DEEP MODE",
                style: GoogleFonts.varelaRound(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: labelColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),

          // FIXED: Button with proper loading animation
          CozyTapScale(
            // Disable the tap if already loading
            onTap: widget.isLoading ? null : widget.onTap,
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.textLight
                      : AppColors.darkBackground,
                  foregroundColor: isDark
                      ? AppColors.darkBackground
                      : AppColors.textLight,
                  // ADDED: Keep the same colors when button is disabled (loading state)
                  disabledBackgroundColor: isDark
                      ? AppColors.textLight
                      : AppColors.darkBackground,
                  disabledForegroundColor: isDark
                      ? AppColors.darkBackground
                      : AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                // ADDED: AnimatedSwitcher for smooth transition between text and loading
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: widget.isLoading
                      ? LoadingAnimationWidget.staggeredDotsWave(
                          // ADDED: Key to help AnimatedSwitcher distinguish between states
                          key: const ValueKey('loading'),
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.textLight,
                          // INCREASED: Size from 28 to 32 for better visibility
                          size: 38.sp,
                        )
                      : Text(
                          "Inspire Me ✨",
                          // ADDED: Key to help AnimatedSwitcher distinguish between states
                          key: const ValueKey('text'),
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeepModeToggle({
    required bool isDeepMode,
    required bool isDarkTheme,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 48.0.w,
      height: 28.0.h,
      padding: EdgeInsets.all(4.0.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99.0),
        color: isDeepMode
            ? (isDarkTheme ? AppColors.textLight : AppColors.darkBackground)
            : (isDarkTheme
                  ? const Color(0xFF44403C) // Stone-700 for dark theme inactive
                  : Colors.black.withValues(alpha: 0.1)),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: isDeepMode ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20.0.w,
          height: 20.0.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDarkTheme && isDeepMode)
                ? AppColors
                      .darkBackground // Dark background when active in dark mode
                : AppColors.textLight,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 2,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyOption(
    BuildContext context,
    String val,
    String label,
    bool isDark,
    Color contentColor,
  ) {
    bool isActive = widget.frequency == val;
    return CozyTapScale(
      onTap: () {
        widget.onFrequencyChanged?.call(val);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                    ? AppColors.textLight
                    : AppColors.darkBackground.withValues(alpha: 0.1))
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
          border: isActive && !isDark
              ? Border.all(
                  color: AppColors.darkBackground.withValues(alpha: 0.1),
                )
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive
                ? (isDark ? AppColors.darkBackground : AppColors.textPrimary)
                : contentColor.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
