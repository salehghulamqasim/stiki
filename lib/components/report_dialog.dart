import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stiki/animations/stiki_animations.dart';
import 'package:stiki/theme/app_colors.dart';
import 'package:stiki/utils/haptic_helper.dart';

class ReportDialog extends StatefulWidget {
  final String quote;

  const ReportDialog({super.key, required this.quote});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final List<String> _reasons = [
    "Inappropriate content",
    "Harmful or hateful",
    "Off-topic or weird",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: PremiumEntrance(
        index: 0,
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppColors.standardShadow,
          ),
          child: Stack(
            children: [
              // X Icon on top right
              Positioned(
                right: 0,
                top: 0,
                child: CozyTapScale(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18.sp,
                      color: AppColors.textPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Report Quote",
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Help us improve the AI by reporting issues.",
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ..._reasons.map((reason) {
                    final isSelected = _selectedReason == reason;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: CozyTapScale(
                        onTap: () {
                          setState(() => _selectedReason = reason);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.textSecondary.withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.textSecondary.withValues(
                                      alpha: 0.2,
                                    )
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reason,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.textSecondary,
                                  size: 20.sp,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 32.h),
                  // Centered Submit Button
                  Center(
                    child: CozyTapScale(
                      onTap: _selectedReason == null
                          ? null
                          : () async {
                              // Smoothly close after a short delay
                              HapticHelper.light();

                              // Show generic success before closing
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Reported! Thank you for the feedback. ✨",
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // Store navigator before async gap
                              final navigator = Navigator.of(context);
                              await Future.delayed(
                                const Duration(milliseconds: 400),
                              );
                              if (mounted) {
                                navigator.pop();
                              }
                            },
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _selectedReason == null ? 0.3 : 1.0,
                        child: Container(
                          width: 200.w,
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 12,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "SUBMIT",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
