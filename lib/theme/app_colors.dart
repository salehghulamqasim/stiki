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

  // 2. Sage - calming green
  static const Color sageWidget = Color(0xFFD7E8CD);
  static const Color sageTextColor = Color(0xFF2E462F);

  // 3. Mist - sophisticated blue-grey (Replacing Slate)
  static const Color mistWidget = Color(0xFFCFD8DC);
  static const Color mistTextColor = Color(0xFF37474F);

  // 4. Ice - fresh cool blue
  static const Color iceWidget = Color(0xFFE1F5FE);
  static const Color iceTextColor = Color(0xFF0277BD);

  // 5. Lilac - romantic purple
  static const Color lilacWidget = Color(0xFFF3E5F5);
  static const Color lilacTextColor = Color(0xFF7B1FA2);

  // 6. Rose - soft pink
  static const Color roseWidget = Color(0xFFFFEBEE);
  static const Color roseTextColor = Color(0xFFC62828);

  // 7. Peach - warm glow
  static const Color peachWidget = Color(0xFFFFCCBC);
  static const Color peachTextColor = Color(0xFFBF360C);

  // 8. Sand - earthy neutral
  static const Color sandWidget = Color(0xFFD7CCC8);
  static const Color sandTextColor = Color(0xFF4E342E);

  // 9. Cream - clean minimalist
  static const Color creamWidget = Color(0xFFFAFAFA);
  static const Color creamTextColor = Color(0xFF212121);

  // 10. Midnight - deep aesthetic blue
  static const Color midnightWidget = Color(0xFF283593);
  static const Color midnightTextColor = Colors.white;

  // 11. Forest - rich green
  static const Color forestWidget = Color(0xFF2E7D32);
  static const Color forestTextColor = Colors.white;

  // 12. Espresso - dark coffee
  static const Color espressoWidget = Color(0xFF4E342E);
  static const Color espressoTextColor = Colors.white;

  // 13. Charcoal - modern dark
  static const Color charcoalWidget = Color(0xFF37474F);
  static const Color charcoalTextColor = Colors.white;

  // 14. Rouge - vintage dark red
  static const Color rougeWidget = Color(0xFFC62828);
  static const Color rougeTextColor = Colors.white;

  // Glass - semi-transparent
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
