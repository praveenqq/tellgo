import 'package:flutter/material.dart';

/// Pixel-perfect rebuild of the provided screenshot based on the measured
/// coordinates in the analysis.
///
/// IMPORTANT:
/// 1) Add these assets to pubspec.yaml:
///    - assets/images/promo_london.png
///    - assets/images/promo_usa.png
/// 2) If your exported images have different intrinsic aspect ratios,
///    keep the *layout size* fixed (below) and use BoxFit.cover (already).
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // ====== DESIGN REFERENCE (from screenshot) ======
  static const double _designW = 521.0; // Base design width (same as go_points_screen)

  // ====== COLORS (from screenshot sampling/estimation) ======
  static const Color bg = Color(0xFFFFFFFF);

  static const Color primaryPurple = Color(0xFF86219D);
  static const Color neutralButtonFill = Color(0xFF4D4D4D);

  static const Color dividerColor = Color(0xFFECECEC);

  static const Color textTitle = Color(0xFF000000);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textBody = Color(0xFF686868);
  static const Color textSecondary = Color(0xFF727272);

  static const Color buttonLabelOnDark = Color(0xFFA6A6A6);

  // ====== RADII ======
  static const double cardRadius = 12.0; // ~10–14, choose 12
  static const double buttonRadius = 10.0; // ~8–10, choose 10

  // ====== SHADOWS ======
  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 6,
      spreadRadius: 0,
      color: Color(0x1A000000), // ~10% opacity
    ),
  ];

  // ====== SCALE ======
  double _clampDouble(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final scale = w / _designW;

    double s(double px) => px * scale;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            // =======================
            // TOP BAR (custom, iOS-ish)
            // =======================
            SizedBox(
              height: s(44), // iOS-like compact header height
              child: Stack(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: s(12)),
                      child: InkResponse(
                        radius: s(24),
                        onTap: () => Navigator.maybePop(context),
                        child: SizedBox(
                          width: s(36),
                          height: s(36),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: s(20),
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center title
                  Center(
                    child: Text(
                      'Notification',
                      style: TextStyle(
                        fontSize: s(16),
                        fontWeight: FontWeight.w700,
                        height: 20 / 16,
                        color: textTitle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // =======================
            // BODY (scrollable)
            // =======================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Headline block
                    Padding(
                      // Measured left edge for text ≈ 33px.
                      // Provide symmetric right padding for robustness.
                      padding: EdgeInsets.fromLTRB(
                        s(33),
                        s(3), // tuned to match screenshot y ~47 after header
                        s(33),
                        0,
                      ),
                      child: Text(
                        'Your near to our branch! go and get\n20% off now!!',
                        style: TextStyle(
                          fontSize: s(18),
                          fontWeight: FontWeight.w700,
                          height: 24 / 18,
                          color: textPrimary,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: s(12)), // gap: headline bottom -> card top ~12

                    // Promo Card 1 (London)
                    Padding(
                      // Card left ≈ 29px, right ≈ 28px.
                      padding: EdgeInsets.fromLTRB(s(29), 0, s(28), 0),
                      child: _PromoCard(
                        width: s(207),
                        height: s(76),
                        radius: s(cardRadius),
                        assetPath: 'assets/images/promo_london.png',
                      ),
                    ),

                    SizedBox(height: s(1)), // card bottom -> button top ~1

                    // Primary Button (purple)
                    Center(
                      child: _CtaButton(
                        width: s(153), // bbox: 69 -> 221 (w=153)
                        height: s(35), // bbox: 155 -> 189 (h=35)
                        radius: s(buttonRadius),
                        fill: primaryPurple,
                        label: 'View',
                        labelStyle: TextStyle(
                          fontSize: s(14),
                          fontWeight: FontWeight.w600,
                          height: 20 / 14,
                          color: Colors.white,
                        ),
                        shadow: shadowSoft,
                        onTap: () {
                          // TODO: handle navigation
                        },
                      ),
                    ),

                    SizedBox(height: s(16)), // button bottom -> divider y ~205

                    // Divider #1 (inset: x=20 -> 245)
                    _InsetDivider(
                      left: s(20),
                      right: s(18), // 263-245=18
                      color: dividerColor,
                      thickness: s(1),
                    ),

                    SizedBox(height: s(14)), // divider -> paragraph top ~14

                    // Paragraph: "Scan your card..."
                    Padding(
                      padding: EdgeInsets.fromLTRB(s(33), 0, s(33), 0),
                      child: Text(
                        'Scan your card to earn or redeem\npoints every time you shop.',
                        style: TextStyle(
                          fontSize: s(14),
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                          color: textBody,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // There is a "section" area with lines and heading.
                    // The screenshot suggests another divider above the heading.
                    SizedBox(height: s(12)),

                    _InsetDivider(
                      left: s(20),
                      right: s(18),
                      color: dividerColor,
                      thickness: s(1),
                    ),

                    SizedBox(height: s(10)),

                    // Section heading: "Check our new Items!"
                    Padding(
                      padding: EdgeInsets.fromLTRB(s(33), 0, s(33), 0),
                      child: Text(
                        'Check our new Items!',
                        style: TextStyle(
                          fontSize: s(14),
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                          color: textBody,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: s(12)),

                    // Divider below heading (detected at y~282)
                    _InsetDivider(
                      left: s(20),
                      right: s(18),
                      color: dividerColor,
                      thickness: s(1),
                    ),

                    SizedBox(height: s(10)),

                    // Subtext: "Guss whats!..."
                    Padding(
                      padding: EdgeInsets.fromLTRB(s(33), 0, s(33), 0),
                      child: Text(
                        'Guss whats! You won 10% off!\nCheck it now.',
                        style: TextStyle(
                          fontSize: s(14),
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: s(11)), // subtext bottom -> card2 top ~11

                    // Promo Card 2 (USA)
                    Padding(
                      padding: EdgeInsets.fromLTRB(s(29), 0, s(28), 0),
                      child: _PromoCard(
                        width: s(207),
                        height: s(84),
                        radius: s(cardRadius),
                        assetPath: 'assets/images/promo_usa.png',
                      ),
                    ),

                    SizedBox(height: s(11)), // card2 bottom -> button2 top ~11

                    // Secondary Button (dark)
                    Center(
                      child: _CtaButton(
                        width: s(128), // detected bbox w=128; centered in screenshot
                        height: s(32), // normalize to match visual button padding
                        radius: s(buttonRadius),
                        fill: neutralButtonFill,
                        label: 'View',
                        labelStyle: TextStyle(
                          fontSize: s(14),
                          fontWeight: FontWeight.w600,
                          height: 20 / 14,
                          color: buttonLabelOnDark,
                        ),
                        shadow: shadowSoft,
                        onTap: () {
                          // TODO: handle navigation
                        },
                      ),
                    ),

                    SizedBox(height: s(24)), // bottom breathing room
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  final double left;
  final double right;
  final double thickness;
  final Color color;

  const _InsetDivider({
    required this.left,
    required this.right,
    required this.thickness,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: left, right: right),
      child: Container(
        height: thickness,
        color: color,
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final String assetPath;

  const _PromoCard({
    required this.width,
    required this.height,
    required this.radius,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color fill;
  final String label;
  final TextStyle labelStyle;
  final List<BoxShadow>? shadow;
  final VoidCallback onTap;

  const _CtaButton({
    required this.width,
    required this.height,
    required this.radius,
    required this.fill,
    required this.label,
    required this.labelStyle,
    required this.onTap,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadow,
          ),
          child: Center(
            child: Text(
              label,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
