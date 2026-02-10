import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pixel-perfect rebuild of the provided "Black Friday" screen.
/// Baseline design: 375w (iPhone 8-ish). Sizes are scaled by effective width,
/// and content is constrained to maxWidth=390 for large screens.
///
/// ASSET REQUIRED:
/// - assets/images/black_friday_banner.png  (the London promo banner)
class BlackFridayScreen extends StatelessWidget {
  const BlackFridayScreen({super.key});

  // ---- Design baseline ----
  static const double _designW = 375.0;
  static const double _maxContentW = 390.0;

  // ---- Colors (from analysis) ----
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF000000);
  static const Color _primaryPurple = Color(0xFF85209C);
  static const Color _couponFill = Color(0xFFF1F1F1);
  static const Color _couponBorder = Color(0xFFD9C1E0);
  static const Color _expiryRed = Color(0xFFFF0021);

  // ---- Hard pixel measurements (baseline @ 375w) ----
  static const double _navBarH = 44.0;
  static const double _backHit = 44.0;
  static const double _backInsetL = 16.0;

  static const double _contentLeft = 44.0; // left padding for text blocks
  static const double _contentRight = 44.0;

  static const double _gapAfterNavToAnnouncement = 27.0;

  static const double _gapAnnouncementToBanner = 16.0;
  static const double _gapBannerToSectionTitle = 32.0;
  static const double _gapTitleToParagraph = 24.0;
  static const double _gapParagraphToCoupon = 24.0;
  static const double _gapCouponToExpiry = 28.0;

  static const double _bannerW = 294.0;
  static const double _bannerH = 118.0;
  static const double _bannerR = 12.0;

  static const double _couponW = 234.0;
  static const double _couponH = 40.0;
  static const double _couponR = 8.0;
  static const double _couponBorderW = 1.0;

  static const double _buttonW = 183.0;
  static const double _buttonH = 27.0;
  static const double _buttonR = 8.0;
  static const double _buttonBottomPad = 82.0;

  // Typography (baseline)
  static const double _navTitleSize = 17.0;
  static const double _sectionTitleSize = 16.0;
  static const double _bodySize = 14.0;
  static const double _couponTextSize = 14.0;
  static const double _expirySize = 12.0;
  static const double _buttonTextSize = 12.0;

  @override
  Widget build(BuildContext context) {
    // Lock text scaling for pixel-perfect fidelity.
    final media = MediaQuery.of(context);
    final noScaleMedia = media.copyWith(textScaler: TextScaler.noScaling);

    return MediaQuery(
      data: noScaleMedia,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          // NOTE: Top safe area is disabled to match the provided screenshot
          // (no visible status bar region). Set to true if your app needs it.
          top: false,
          bottom: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentW),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final effectiveW = constraints.maxWidth;
                  final scale = effectiveW / _designW;
                  double s(double v) => v * scale;

                  final navTitleStyle = TextStyle(
                    color: _textPrimary,
                    fontSize: s(_navTitleSize),
                    fontWeight: FontWeight.w600,
                    height: 20.0 / _navTitleSize, // ~20px line box
                  );

                  final bodyStyle = TextStyle(
                    color: _textPrimary,
                    fontSize: s(_bodySize),
                    fontWeight: FontWeight.w400,
                    height: 18.0 / _bodySize,
                  );

                  final sectionTitleStyle = TextStyle(
                    color: _textPrimary,
                    fontSize: s(_sectionTitleSize),
                    fontWeight: FontWeight.w600,
                    height: 20.0 / _sectionTitleSize,
                  );

                  final couponStyle = TextStyle(
                    color: _textPrimary,
                    fontSize: s(_couponTextSize),
                    fontWeight: FontWeight.w600,
                    height: 18.0 / _couponTextSize,
                  );

                  final expiryStyle = TextStyle(
                    color: _expiryRed,
                    fontSize: s(_expirySize),
                    fontWeight: FontWeight.w500,
                    height: 14.0 / _expirySize,
                  );

                  final buttonTextStyle = TextStyle(
                    color: Colors.white,
                    fontSize: s(_buttonTextSize),
                    fontWeight: FontWeight.w600,
                    height: 14.0 / _buttonTextSize,
                  );

                  // Scroll container that still allows bottom alignment when content fits.
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ---- Custom iOS-like nav bar (44px) ----
                            SizedBox(
                              height: s(_navBarH),
                              child: Stack(
                                children: [
                                  // Back hit target (44x44)
                                  Positioned(
                                    left: s(_backInsetL),
                                    top: 0,
                                    bottom: 0,
                                    child: SizedBox(
                                      width: s(_backHit),
                                      height: s(_backHit),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(s(22)),
                                          onTap: () => Navigator.maybePop(context),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Icon(
                                              CupertinoIcons.back,
                                              color: _textPrimary,
                                              // Use a slightly smaller icon to mimic the thin chevron glyph.
                                              size: s(20.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Center title (must remain centered regardless of leading)
                                  Center(
                                    child: Text(
                                      'Black Friday',
                                      style: navTitleStyle,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Gap from nav bar to first text block (≈27px)
                            SizedBox(height: s(_gapAfterNavToAnnouncement)),

                            // ---- Announcement (2 lines) ----
                            Padding(
                              padding: EdgeInsets.only(
                                left: s(_contentLeft),
                                right: s(_contentRight),
                              ),
                              child: Text(
                                'Your near to our branch! go and get\n20% off now!!',
                                style: bodyStyle,
                                textAlign: TextAlign.left,
                              ),
                            ),

                            SizedBox(height: s(_gapAnnouncementToBanner)),

                            // ---- Banner image card (centered, 294x118, r=12) ----
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(s(_bannerR)),
                                clipBehavior: Clip.hardEdge,
                                child: SizedBox(
                                  width: s(_bannerW),
                                  height: s(_bannerH),
                                  child: Image.asset(
                                    'assets/images/black_friday_banner.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: s(_gapBannerToSectionTitle)),

                            // ---- Section Title ----
                            Padding(
                              padding: EdgeInsets.only(
                                left: s(_contentLeft),
                                right: s(_contentRight),
                              ),
                              child: Text(
                                'Black friday offer!',
                                style: sectionTitleStyle,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            SizedBox(height: s(_gapTitleToParagraph)),

                            // ---- Paragraph (2 lines) ----
                            Padding(
                              padding: EdgeInsets.only(
                                left: s(_contentLeft),
                                right: s(_contentRight),
                              ),
                              child: Text(
                                '20% Discount on all accesories, use\ncode bellow and get the discount',
                                style: bodyStyle,
                                textAlign: TextAlign.left,
                              ),
                            ),

                            SizedBox(height: s(_gapParagraphToCoupon)),

                            // ---- Coupon code box (centered, 234x40, fill/border/r=8) ----
                            Center(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(s(_couponR)),
                                  onTap: () async {
                                    await Clipboard.setData(const ClipboardData(text: 'Rom20'));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Coupon code copied'),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(milliseconds: 900),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: s(_couponW),
                                    height: s(_couponH),
                                    decoration: BoxDecoration(
                                      color: _couponFill,
                                      borderRadius: BorderRadius.circular(s(_couponR)),
                                      border: Border.all(
                                        color: _couponBorder,
                                        width: math.max(1.0, s(_couponBorderW)),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Rom20',
                                      style: couponStyle,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: s(_gapCouponToExpiry)),

                            // ---- Expiry line (red, left aligned) ----
                            Padding(
                              // Slightly smaller left inset in the screenshot (~41px);
                              // Keep text padding consistent but nudge left by 3px for closer match.
                              padding: EdgeInsets.only(
                                left: math.max(0, s(_contentLeft - 3)),
                                right: s(_contentRight),
                              ),
                              child: Text(
                                'Expired in 20 Apr 2024',
                                style: expiryStyle,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Spacer to push CTA to bottom when content fits.
                            const Spacer(),

                            // ---- Bottom CTA (centered, 183x27, bottom pad ~82) ----
                            Padding(
                              padding: EdgeInsets.only(bottom: s(_buttonBottomPad)),
                              child: Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(s(_buttonR)),
                                    onTap: () {
                                      // TODO: Navigate to checkout/purchase flow.
                                    },
                                    child: Container(
                                      width: s(_buttonW),
                                      height: s(_buttonH),
                                      decoration: BoxDecoration(
                                        color: _primaryPurple,
                                        borderRadius: BorderRadius.circular(s(_buttonR)),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Buy Now',
                                        style: buttonTextStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
