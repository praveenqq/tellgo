import 'dart:math';

/// Simple responsive helpers (mobile/tablet/desktop)
class R {
  static bool isMobile(double w) => w < 600;
  static bool isTablet(double w) => w >= 600 && w < 1024;
  static bool isDesktop(double w) => w >= 1024;

  /// Design width reference (from pixel-perfect specs)
  static const double designWidth = 713.0;

  /// Scale factor based on design width (713px)
  /// Multiply all px values from design specs by this scale
  static double scale(double screenWidth) {
    final scale = screenWidth / designWidth;
    // Clamp scale to reasonable bounds
    return scale.clamp(0.85, isDesktop(screenWidth) ? 1.5 : 1.2);
  }

  /// Scale a pixel value from design specs
  static double sx(double screenWidth, double px) => scale(screenWidth) * px;

  /// Returns scale factor for given width (for legacy use: final scale = R.sxScale(w); then px * scale)
  static double sxScale(double screenWidth) => scale(screenWidth);

  /// Center column max width so layout looks great on wide screens.
  static double contentMaxWidth(double w) =>
      isDesktop(w) ? 1200 : (isTablet(w) ? 900 : min(w, 480));

  /// Horizontal page padding
  static double hPad(double w) => isDesktop(w) ? 32 : (isTablet(w) ? 24 : 16);

  /// Legacy scale factor for font sizes & a few paddings (baseline ~390px)
  /// For mobile, clamp more aggressively to prevent oversized UI
  static double sxLegacy(double w) {
    if (isMobile(w)) {
      final s = w / 390.0;
      return s.clamp(0.85, 1.0); // Mobile: keep smaller scale
    }
    final s = w / 390.0;
    return s.clamp(0.90, isDesktop(w) ? 1.60 : 1.25);
  }

  static double heroHeight(double w) =>
      isDesktop(w) ? 360 : (isTablet(w) ? 260 : 180);

  static double promoHeight(double w) =>
      isDesktop(w) ? 260 : (isTablet(w) ? 220 : 200);
}
