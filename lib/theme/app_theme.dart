import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Design System Colors - Based on pixel-perfect specifications

  // Core Colors
  static const Color primaryPurple = Color(0xFF74459B); // RGB 116,69,155
  static const Color borderMid = Color(0xFF9F7FBA); // RGB 159,127,186
  static const Color borderLight = Color(0xFFD8CAE3); // RGB 216,202,227
  static const Color borderLighter = Color(0xFFDED3E7); // RGB 222,211,231

  // Surfaces
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceHero = Color(0xFFEBEBEB); // RGB 235,235,235
  static const Color surfaceSearch = Color(0xFFF1F1F1); // RGB 241,241,241
  static const Color surfaceList = Color(0xFFF7F7F8); // RGB 247,247,248

  // Text Colors
  static const Color textPrimary = Color(0xFF1F1F1F); // near-black
  static const Color textSecondary = Color(0xFF969696); // RGB ~150
  static const Color textMuted = Color(0xFFA8A8A8); // icons/lines
  static const Color textGreetingLight = Color(0xFF6B6B6B); // "Hello," text
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status / Badge
  static const Color badgeRed = Color(0xFFED1C24); // RGB 237,28,36

  // Chips (Tabs)
  static const Color chipGreen = Color(0xFF73C243); // Local eSIMs
  static const Color chipOrange = Color(0xFFF99A2B); // Regional eSIMs
  static const Color chipGradientStart = Color(
    0xFF55C1E6,
  ); // tellgo+ gradient start
  static const Color chipGradientMid = Color(
    0xFF5F81BF,
  ); // tellgo+ gradient mid
  static const Color chipGradientEnd = Color(
    0xFF6461AC,
  ); // tellgo+ gradient end

  // Legacy compatibility
  static const Color primaryPurpleDark = Color(0xFF5F3D85);
  static const Color primaryPurpleLight = Color(0xFF8B6BB5);
  static const Color secondaryColor = Color(0xFF00D2FF);
  static const Color accentYellow = Color(0xFFFFD700);
  static const Color accentRed = badgeRed;
  static const Color accentGreen = chipGreen;
  static const Color surfaceColor = surfaceSearch;
  static const Color cardColor = backgroundColor;
  static const Color textHint = textSecondary;
  static const Color borderColor = borderLight;
  static const Color dividerColor = borderLight;
  static const Color errorColor = badgeRed;

  // Spacing Constants
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing18 = 18.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;

  // Border Radius (from design specs)
  static const double radiusHero = 18.0; // hero card
  static const double radiusSearch = 20.0; // search field
  static const double radiusChip = 14.0; // chips/tabs
  static const double radiusListItem = 14.0; // list items
  static const double radiusButton = 12.0; // primary button
  static const double radiusNotification =
      26.0; // notification circle (52px diameter)
  static const double radiusBadge = 9.0; // badge (18px diameter)

  // Legacy compatibility
  static const double radiusSmall = radiusButton;
  static const double radiusMedium = radiusChip;
  static const double radiusLarge = radiusSearch;
  static const double radiusXLarge = radiusHero;
  static const double radiusRound = radiusNotification;

  // Typography - Using Poppins as specified
  static TextStyle get headingLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static TextStyle get headingMedium => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get headingSmall => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );

  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );

  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textOnPrimary,
    height: 1.2,
  );

  // Design System Typography Styles
  static TextStyle h1SectionTitle(double scale) => GoogleFonts.poppins(
    fontSize: 26 * scale,
    fontWeight: FontWeight.w700,
    height: 32 / 26,
    color: textPrimary,
  );

  static TextStyle headerGreeting(double scale) => GoogleFonts.poppins(
    fontSize: 22 * scale,
    fontWeight: FontWeight.w400,
    height: 28 / 22,
    color: textGreetingLight,
  );

  static TextStyle headerGreetingBold(double scale) => GoogleFonts.poppins(
    fontSize: 22 * scale,
    fontWeight: FontWeight.w700,
    height: 28 / 22,
    color: textPrimary,
  );

  static TextStyle headerSubtext(double scale) => GoogleFonts.poppins(
    fontSize: 12 * scale,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: textSecondary,
  );

  static TextStyle balanceText(double scale) => GoogleFonts.poppins(
    fontSize: 18 * scale,
    fontWeight: FontWeight.w600,
    height: 22 / 18,
    color: primaryPurple,
  );

  static TextStyle searchPlaceholder(double scale) => GoogleFonts.poppins(
    fontSize: 16 * scale,
    fontWeight: FontWeight.w400,
    height: 20 / 16,
    color: textSecondary,
  );

  static TextStyle chipLabel(double scale) => GoogleFonts.poppins(
    fontSize: 18 * scale,
    fontWeight: FontWeight.w700,
    color: textOnPrimary,
  );

  static TextStyle listItemCountry(double scale) => GoogleFonts.poppins(
    fontSize: 18 * scale,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle listItemPrice(double scale) => GoogleFonts.poppins(
    fontSize: 18 * scale,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle primaryButtonText(double scale) => GoogleFonts.poppins(
    fontSize: 18 * scale,
    fontWeight: FontWeight.w700,
    color: textOnPrimary,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryPurple,
        primaryContainer: primaryPurpleLight,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: textOnPrimary,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: headingSmall.copyWith(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing8,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing32,
            vertical: spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing32,
            vertical: spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          side: const BorderSide(color: primaryPurple, width: 1.5),
          textStyle: button.copyWith(color: primaryPurple),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing12,
          ),
          textStyle: button.copyWith(color: primaryPurple),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: bodyMedium.copyWith(color: textHint),
        labelStyle: bodyMedium.copyWith(color: textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
