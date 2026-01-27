import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stiki/animations/stiki_animations.dart';
import 'package:stiki/models/widget_model.dart';
import 'package:stiki/services/widget_service.dart';
import 'package:stiki/utils/haptic_helper.dart';
import 'package:stiki/utils/storage_helper.dart';
import 'package:stiki/theme/app_colors.dart';

class WidgetEditScreen extends StatefulWidget {
  final QuoteWidget widget;

  const WidgetEditScreen({super.key, required this.widget});

  @override
  State<WidgetEditScreen> createState() => _WidgetEditScreenState();
}

class _WidgetEditScreenState extends State<WidgetEditScreen> {
  late String _selectedQuote;
  late String _selectedFrequency;

  @override
  void initState() {
    super.initState();
    _selectedQuote = widget.widget.quote;
    _selectedFrequency = widget.widget.frequency;
  }

  Future<void> _updateWidget() async {
    HapticHelper.heavy();

    // 1. Save to Storage
    await StorageHelper.saveQuote(
      _selectedQuote,
      id: widget.widget.id,
      frequency: _selectedFrequency,
      quotes: widget.widget.quotes,
      topic: widget.widget.topic,
      widgetName: widget.widget.widgetName,
    );

    // 2. Push update to Home Screen Widget
    final isDark = widget.widget.widgetName.contains('Dark');

    await WidgetService().updateStickyWidget(
      text: _selectedQuote,
      color: isDark ? AppColors.darkBackground : AppColors.yellowWidget,
      textColor: isDark ? AppColors.textLight : AppColors.textPrimary,
      androidWidgetName: widget.widget.widgetName,
      id: widget.widget.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Stiki Updated! ✨"),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PremiumEntrance(
                  index: 0,
                  child: CozyTapScale(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),
                PremiumEntrance(
                  index: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Modify Stiki",
                        style: GoogleFonts.poppins(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Topic: ${widget.widget.topic}",
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                PremiumEntrance(
                  index: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rotation Speed",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        children: ['hourly', 'daily', 'weekly'].map((freq) {
                          final isSel = _selectedFrequency == freq;
                          return CozyTapScale(
                            onTap: () {
                              setState(() => _selectedFrequency = freq);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: isSel
                                    ? null
                                    : Border.all(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                              ),
                              child: Text(
                                freq.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                Text(
                  "Update Quote✨",
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.widget.quotes.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final q = widget.widget.quotes[index];
                    final isSelected = _selectedQuote == q;
                    return PremiumEntrance(
                      index: 3 + index,
                      child: CozyTapScale(
                        onTap: () {
                          setState(() => _selectedQuote = q);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.darkBackground
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? []
                                : AppColors.standardShadow,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  q,
                                  style: GoogleFonts.merriweather(
                                    color: isSelected
                                        ? AppColors.textLight
                                        : AppColors.textPrimary,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? AppColors.textLight
                                    : AppColors.textPrimary.withValues(
                                        alpha: 0.2,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 32.h),

                CozyTapScale(
                  onTap: _updateWidget,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _updateWidget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBackground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "APPLY CHANGES",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
