import 'package:flutter/material.dart';

/// Junior (6-8) specific design system with pastel colors and rounded shapes
class JuniorTheme {
  // Pastel color palette
  static const Color primaryGreen = Color(0xFF8FBC8F); // Soft green
  static const Color primaryYellow = Color(0xFFFFE4B5); // Mellow yellow
  static const Color primaryOrange = Color(0xFFFFB366); // Warm orange
  static const Color primaryPink = Color(0xFFFFB6C1); // Light pink
  static const Color primaryBlue = Color(0xFFB0E0E6); // Powder blue
  static const Color primaryPurple = Color(0xFFDDA0DD); // Plum

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5DC); // Beige
  static const Color backgroundCard = Color(0xFFFFFFFF); // White
  static const Color backgroundOverlay =
      Color(0x80FFFFFF); // Semi-transparent white

  // Text colors
  static const Color textPrimary = Color(0xFF2F4F4F); // Dark slate gray
  static const Color textSecondary = Color(0xFF696969); // Dim gray
  static const Color textLight = Color(0xFFA9A9A9); // Dark gray

  // Accent colors
  static const Color accentGold = Color(0xFFFFD700); // Gold for coins/XP
  static const Color accentSilver = Color(0xFFC0C0C0); // Silver
  static const Color accentBronze = Color(0xFFCD7F32); // Bronze
  static const Color primaryBrown =
      Color(0xFF8B4513); // Saddle brown for sticks/wood

  // Status colors
  static const Color success = Color(0xFF90EE90); // Light green
  static const Color warning = Color(0xFFFFE4B5); // Mellow yellow
  static const Color error = Color(0xFFFFB6C1); // Light pink

  // Border radius values (very rounded)
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 30.0;
  static const double radiusXLarge = 40.0;
  static const double radiusCircular = 50.0;

  // Spacing values (larger for easier tapping)
  static const double spacingXSmall = 8.0;
  static const double spacingSmall = 16.0;
  static const double spacingMedium = 24.0;
  static const double spacingLarge = 32.0;
  static const double spacingXLarge = 48.0;

  // Font sizes (larger for readability)
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 18.0;
  static const double fontSizeLarge = 24.0;
  static const double fontSizeXLarge = 32.0;
  static const double fontSizeXXLarge = 48.0;

  // Icon sizes
  static const double iconSmall = 24.0;
  static const double iconMedium = 32.0;
  static const double iconLarge = 48.0;
  static const double iconXLarge = 64.0;
  static const double iconXXLarge = 96.0;

  // Button heights (larger for easier tapping)
  static const double buttonHeightSmall = 48.0;
  static const double buttonHeightMedium = 56.0;
  static const double buttonHeightLarge = 64.0;
  static const double buttonHeightXLarge = 72.0;

  // Card dimensions
  static const double cardMinHeight = 120.0;
  static const double cardMaxHeight = 200.0;
  static const double cardWidth = 300.0;

  // Avatar dimensions
  static const double avatarSizeSmall = 80.0;
  static const double avatarSizeMedium = 120.0;
  static const double avatarSizeLarge = 160.0;
  static const double avatarSizeXLarge = 200.0;

  // Progress bar dimensions
  static const double progressBarHeight = 16.0;
  static const double progressBarRadius = 8.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // Shadow styles
  static const List<BoxShadow> shadowLight = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8.0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16.0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowHeavy = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24.0,
      offset: Offset(0, 8),
    ),
  ];

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryYellow],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundCard, Color(0xFFF8F8FF)],
  );

  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryGreen, primaryYellow],
  );

  // Text styles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'Nunito',
    fontSize: fontSizeXXLarge,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'Nunito',
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 1.0,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'Nunito',
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.8,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Nunito',
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Nunito',
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Nunito',
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    letterSpacing: 0.2,
  );

  static const TextStyle coinText = TextStyle(
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.bold,
    color: accentGold,
    letterSpacing: 1.0,
  );

  static const TextStyle taskTitle = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.8,
  );

  // Decoration helpers
  static BoxDecoration getCardDecoration() {
    return BoxDecoration(
      color: backgroundCard,
      borderRadius: BorderRadius.circular(radiusLarge),
      boxShadow: shadowMedium,
      gradient: cardGradient,
    );
  }

  static BoxDecoration getButtonDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? primaryGreen,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: shadowLight,
    );
  }

  static BoxDecoration getProgressBarDecoration() {
    return BoxDecoration(
      color: backgroundLight,
      borderRadius: BorderRadius.circular(progressBarRadius),
    );
  }

  static BoxDecoration getProgressFillDecoration() {
    return BoxDecoration(
      gradient: progressGradient,
      borderRadius: BorderRadius.circular(progressBarRadius),
    );
  }

  // Animation curves
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOut;
  static const Curve springCurve = Curves.elasticInOut;
}
