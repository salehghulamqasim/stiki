import 'package:flutter/material.dart';

class AppColors {
  // Primary Theme Colors
  static const Color background = Color(0xFFEFE9E2); // warm, cozy paper tone
  static const Color darkBackground = Color(0xFF221A16); // unchanged dark

  // Text Colors
  static const Color textPrimary = Color(0xFF221A16); // warm dark brown
  static const Color textSecondary = Color(0xFF6B5F58); // soft warm gray
  static const Color textLight = Colors.white; // unchanged

  // Widget/Card Colors
  static const Color yellowWidget = Color(0xFFFFF1A8); // cozy sticky note
  static const Color darkWidget = Color(0xFF221A16); // unchanged dark

  // Design Accent
  static const Color accentRed = Color(0xFFFF0000); // KEEP EXACTLY AS ORIGINAL

  // ══════════════════════════════════════════════════════════════════════════
  // 10 COZY WIDGET COLORS - Distinct, vibrant but warm palette
  // ══════════════════════════════════════════════════════════════════════════

  // 1. Honey - classic warm yellow
  static const Color honeyWidget = Color(0xFFFFF1A8);
  static const Color honeyTextColor = Color(0xFF3D3520);

  // 2. Sage - calming muted green
  static const Color sageWidget = Color(0xFFB8C9A8);
  static const Color sageTextColor = Color(0xFF2D3B2D);

  // 3. Coral - warm peachy red
  static const Color coralWidget = Color(0xFFE8A89C);
  static const Color coralTextColor = Color(0xFF4A2525);

  // 4. Sky - soft blue
  static const Color skyWidget = Color(0xFFA8C8E8);
  static const Color skyTextColor = Color(0xFF1E3A5F);

  // 5. Lavender - gentle purple
  static const Color lavenderWidget = Color(0xFFBEB0D8);
  static const Color lavenderTextColor = Color(0xFF3A2D5A);

  // 6. Mint - fresh green
  static const Color mintWidget = Color(0xFFA8E8D0);
  static const Color mintTextColor = Color(0xFF1E4A3A);

  // 7. Blush - soft pink
  static const Color blushWidget = Color(0xFFF0B8C8);
  static const Color blushTextColor = Color(0xFF5A2D3A);

  // 8. Peach - warm orange
  static const Color peachWidget = Color(0xFFF8C8A0);
  static const Color peachTextColor = Color(0xFF4A2D1E);

  // 9. Slate - cool sophisticated gray
  static const Color slateWidget = Color(0xFFB8C0C8);
  static const Color slateTextColor = Color(0xFF2D3540);

  // 10. Cream - warm off-white
  static const Color creamWidget = Color(0xFFF5F0E0);
  static const Color creamTextColor = Color(0xFF3D3830);

  // 11. Glass/Transparent - semi-transparent
  static const Color glassWidget = Color(0x80FFFFFF);
  static const Color glassTextColor = Color(0xFF221A16);

  // Dynamic color holder - will be set from main.dart
  static Color? _dynamicPrimary;
  static Color? _dynamicOnPrimary;
  static Color? _dynamicLightPrimary;
  static Color? _dynamicLightOnPrimary;

  static void setDynamicColors(Color? primary, Color? onPrimary) {
    _dynamicPrimary = primary;
    _dynamicOnPrimary = onPrimary;
  }

  static void setDynamicLightColors(Color? primary, Color? onPrimary) {
    _dynamicLightPrimary = primary;
    _dynamicLightOnPrimary = onPrimary;
  }

  /// Returns dynamic dark widget color if available, else fallback
  static Color get dynamicDarkWidget => _dynamicPrimary ?? darkWidget;
  static Color get dynamicDarkText => _dynamicOnPrimary ?? textLight;

  /// Returns dynamic light widget color if available, else fallback
  static Color get dynamicLightWidget => _dynamicLightPrimary ?? background;
  static Color get dynamicLightText => _dynamicLightOnPrimary ?? textPrimary;

  /// Check if device supports dynamic colors
  static bool get hasDynamicColors => _dynamicPrimary != null;

  // Helper for Shadow (cozy, soft shadows)
  static List<BoxShadow> get standardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06), // softer shadow
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
