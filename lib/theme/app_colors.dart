import 'package:flutter/material.dart';

class AppColors {
  // Primary Theme Colors
  static const Color background = Color(0xFFEFE9E2); // warm, cozy paper tone
  static const Color darkBackground = Color(0xFF221A16); // unchanged dark

  // Text Colors
  //static const Color textPrimary = Color(0xFF2A211D); // warm dark brown
  static const Color textPrimary = Color(0xFF221A16); // warm dark brown
  static const Color textSecondary = Color(0xFF6B5F58); // soft warm gray
  static const Color textLight = Colors.white; // unchanged
  //static const Color textLight =   Color(0xFFEFE9E2);// unchanged

  // Widget/Card Colors
  static const Color yellowWidget = Color(0xFFFFF1A8); // cozy sticky note
  static const Color darkWidget = Color(0xFF221A16); // unchanged dark

  // Design Accent
  static const Color accentRed = Color(0xFFFF0000); // KEEP EXACTLY AS ORIGINAL

  // Helper for Shadow (cozy, soft shadows)
  static List<BoxShadow> get standardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06), // softer shadow
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

//  import 'package:flutter/material.dart';

// class AppColors {
//   // Primary Theme Colors
//   static const Color background = Color(0xFFF0EEE9);
//   static const Color darkBackground = Color(0xFF221A16);

//   // Text Colors
//   static const Color textPrimary = Color(0xFF121212);
//   static const Color textSecondary = Color(0xFF555555);
//   static const Color textLight = Colors.white;

//   // Widget/Card Colors (Existing ones kept but centralized)
//   static const Color yellowWidget = Color(0xFFFFF1A8);
//   static const Color darkWidget = Color(0xFF221A16);

//   // Design Accent
//   static const Color accentRed = Color(0xFFFF0000);

//   // Helper for Shadow (Matching QuoteCard)
//   static List<BoxShadow> get standardShadow => [
//     BoxShadow(
//       color: Colors.black.withOpacity(
//         0.04,
//       ), // Slightly lower opacity for softness
//       blurRadius: 20,
//       offset: const Offset(0, 8),
//     ),
//   ];
// }
