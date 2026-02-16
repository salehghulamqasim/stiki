import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stiki/theme/app_colors.dart';
import 'package:stiki/animations/stiki_animations.dart';
import 'package:stiki/utils/haptic_helper.dart';

/// Model for a widget style option
class WidgetStyleOption {
  final String name;
  final String displayTitle;
  final Color backgroundColor;
  final Color textColor;
  final String androidWidgetName;
  final bool isDynamic; // Uses device's Material You colors

  const WidgetStyleOption({
    required this.name,
    required this.displayTitle,
    required this.backgroundColor,
    required this.textColor,
    required this.androidWidgetName,
    this.isDynamic = false,
  });
}

/// All available widget styles - 11 cozy options
class WidgetStyles {
  static List<WidgetStyleOption> get all => [
    // Dynamic styles - use Material You colors from device
    const WidgetStyleOption(
      name: 'dynamic_dark',
      displayTitle: 'Stiki Dark',
      backgroundColor: AppColors.darkBackground,
      textColor: AppColors.textLight,
      androidWidgetName: 'StikiWidgetDark',
      isDynamic: true,
    ),
    const WidgetStyleOption(
      name: 'dynamic_light',
      displayTitle: 'Stiki Light',
      backgroundColor: AppColors.background,
      textColor: AppColors.textPrimary,
      androidWidgetName: 'StikiWidgetLight',
      isDynamic: true,
    ),
    // Static cozy styles - distinct vibrant colors
    const WidgetStyleOption(
      name: 'honey',
      displayTitle: 'Honey',
      backgroundColor: AppColors.honeyWidget,
      textColor: AppColors.honeyTextColor,
      androidWidgetName: 'StikiWidgetLight',
    ),
    const WidgetStyleOption(
      name: 'sage',
      displayTitle: 'Sage',
      backgroundColor: AppColors.sageWidget,
      textColor: AppColors.sageTextColor,
      androidWidgetName: 'StikiWidgetLight',
    ),
    const WidgetStyleOption(
      name: 'mist',
      displayTitle: 'Mist',
      backgroundColor: AppColors.mistWidget,
      textColor: AppColors.mistTextColor,
      androidWidgetName: 'StikiWidgetLight',
    ),
    const WidgetStyleOption(
      name: 'ice',
      displayTitle: 'Ice',
      backgroundColor: AppColors.iceWidget,
      textColor: AppColors.iceTextColor,
      androidWidgetName: 'StikiWidgetLight',
    ),
    const WidgetStyleOption(
      name: 'lilac',
      displayTitle: 'Lilac',
      backgroundColor: AppColors.lilacWidget,
      textColor: AppColors.lilacTextColor,
      androidWidgetName: 'StikiWidgetLight',
    ),
    const WidgetStyleOption(
      name: 'rose',
      displayTitle: 'Rose',
      backgroundColor: AppColors.roseWidget,
      textColor: AppColors.roseTextColor,
      androidWidgetName: 'StikiWidgetLight',
    ),
    const WidgetStyleOption(
      name: 'peach',
      displayTitle: 'Peach',
      backgroundColor: AppColors.peachWidget,
      textColor: AppColors.peachTextColor,
      androidWidgetName: 'StikiWidgetLight',
    ),
    const WidgetStyleOption(
      name: 'sand',
      displayTitle: 'Sand',
      backgroundColor: AppColors.sandWidget,
      textColor: AppColors.sandTextColor,
      androidWidgetName: 'StikiWidgetLight',
    ),
    const WidgetStyleOption(
      name: 'cream',
      displayTitle: 'Cream',
      backgroundColor: AppColors.creamWidget,
      textColor: AppColors.creamTextColor,
      androidWidgetName: 'StikiWidgetLight',
    ),
    // Dark Options
    const WidgetStyleOption(
      name: 'midnight',
      displayTitle: 'Midnight',
      backgroundColor: AppColors.midnightWidget,
      textColor: AppColors.midnightTextColor,
      androidWidgetName: 'StikiWidgetDark',
    ),
    const WidgetStyleOption(
      name: 'forest',
      displayTitle: 'Forest',
      backgroundColor: AppColors.forestWidget,
      textColor: AppColors.forestTextColor,
      androidWidgetName: 'StikiWidgetDark',
    ),
    const WidgetStyleOption(
      name: 'espresso',
      displayTitle: 'Espresso',
      backgroundColor: AppColors.espressoWidget,
      textColor: AppColors.espressoTextColor,
      androidWidgetName: 'StikiWidgetDark',
    ),
    const WidgetStyleOption(
      name: 'charcoal',
      displayTitle: 'Charcoal',
      backgroundColor: AppColors.charcoalWidget,
      textColor: AppColors.charcoalTextColor,
      androidWidgetName: 'StikiWidgetDark',
    ),
    const WidgetStyleOption(
      name: 'rouge',
      displayTitle: 'Rouge',
      backgroundColor: AppColors.rougeWidget,
      textColor: AppColors.rougeTextColor,
      androidWidgetName: 'StikiWidgetDark',
    ),
  ];

  /// Get the first 4 styles for the home page slider
  static List<WidgetStyleOption> get featured => all.take(4).toList();
}

/// Horizontal slider for widget styles on home page
class WidgetGallerySlider extends StatelessWidget {
  final Function(WidgetStyleOption) onStyleSelected;
  final VoidCallback onViewAllTap;

  const WidgetGallerySlider({
    super.key,
    required this.onStyleSelected,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final styles = WidgetStyles.featured;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with title and "View All" button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Create New",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            CozyTapScale(
              onTap: () {
                HapticHelper.selection();
                onViewAllTap();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "More",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Horizontal scrollable list
        SizedBox(
          height: 160.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: styles.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final style = styles[index];
              return _WidgetStyleCard(
                style: style,
                index: index,
                onTap: () {
                  HapticHelper.light();
                  onStyleSelected(style);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual widget style card - matching original WidgetOptionCard2 design
class _WidgetStyleCard extends StatelessWidget {
  final WidgetStyleOption style;
  final int index;
  final VoidCallback onTap;

  const _WidgetStyleCard({
    required this.style,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve background color dynamically
    Color bgColor = style.backgroundColor;
    if (style.isDynamic) {
      if (style.name == 'dynamic_light') {
        bgColor = AppColors.dynamicLightWidget;
      } else if (style.name == 'dynamic_dark') {
        bgColor = AppColors.dynamicDarkWidget;
      }
    }

    // Adaptive Text Contrast: Determine if background is light or dark
    final isLightBg =
        ThemeData.estimateBrightnessForColor(bgColor) == Brightness.light;
    final adaptiveTextColor = isLightBg ? AppColors.textPrimary : Colors.white;

    // Determine circle and icon colors based on adaptive text color
    final circleColor = adaptiveTextColor.withValues(alpha: 0.1);
    final iconColor = adaptiveTextColor.withValues(alpha: 0.7);

    // Add subtle border for very light backgrounds to separate from app background
    final bool needsBorder =
        style.name == 'dynamic_light' ||
        style.name == 'honey' ||
        style.name == 'cream';

    return PremiumEntrance(
      index: index,
      child: CozyTapScale(
        onTap: onTap,
        child: Container(
          width: 165.w,
          height: 150.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: needsBorder
                ? Border.all(
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                    width: 1,
                  )
                : null,
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
              // + icon in circle at top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: iconColor, size: 20.sp),
                  ),
                ],
              ),
              const Spacer(),
              // Title at bottom left
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  style.displayTitle.toLowerCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: adaptiveTextColor,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full page for viewing all widget styles
class WidgetGalleryPage extends StatelessWidget {
  final Function(WidgetStyleOption) onStyleSelected;

  const WidgetGalleryPage({super.key, required this.onStyleSelected});

  @override
  Widget build(BuildContext context) {
    final styles = WidgetStyles.all;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  PremiumEntrance(
                    index: 0,
                    child: CozyTapScale(
                      onTap: () {
                        HapticHelper.selection();
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
                  SizedBox(width: 16.w),
                  PremiumEntrance(
                    index: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Widget Styles",
                          style: GoogleFonts.poppins(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          "Choose your favorite look",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // Grid of styles
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: styles.length,
                  itemBuilder: (context, index) {
                    final style = styles[index];
                    return PremiumEntrance(
                      index: index + 2,
                      child: _LargeWidgetStyleCard(
                        style: style,
                        onTap: () {
                          HapticHelper.medium();
                          onStyleSelected(style);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Larger card for the gallery page - matching original WidgetOptionCard2 design
class _LargeWidgetStyleCard extends StatelessWidget {
  final WidgetStyleOption style;
  final VoidCallback onTap;

  const _LargeWidgetStyleCard({required this.style, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Resolve background color dynamically
    Color bgColor = style.backgroundColor;
    if (style.isDynamic) {
      if (style.name == 'dynamic_light') {
        bgColor = AppColors.dynamicLightWidget;
      } else if (style.name == 'dynamic_dark') {
        bgColor = AppColors.dynamicDarkWidget;
      }
    }

    // Adaptive Text Contrast
    final isLightBg =
        ThemeData.estimateBrightnessForColor(bgColor) == Brightness.light;
    final adaptiveTextColor = isLightBg ? AppColors.textPrimary : Colors.white;

    // Determine circle and icon colors based on adaptive text color
    final circleColor = adaptiveTextColor.withValues(alpha: 0.1);
    final iconColor = adaptiveTextColor.withValues(alpha: 0.7);

    // Border for light backgrounds
    final bool needsBorder =
        style.name == 'dynamic_light' ||
        style.name == 'honey' ||
        style.name == 'cream';

    return CozyTapScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: needsBorder
              ? Border.all(
                  color: AppColors.textPrimary.withValues(alpha: 0.05),
                  width: 1,
                )
              : null,

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
            // + icon in circle at top right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: iconColor, size: 22.sp),
                ),
              ],
            ),

            const Spacer(),

            // Title at bottom left
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                style.displayTitle.toLowerCase(),
                style: GoogleFonts.outfit(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: adaptiveTextColor,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(height: 6.h),
          ],
        ),
      ),
    );
  }
}
