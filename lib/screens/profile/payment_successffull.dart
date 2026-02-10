import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Drop-in demo app wrapper.
/// In your app, you likely only need [PaymentSuccessfulScreen].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const PaymentSuccessfulScreen(),
    );
  }
}

/// =======================
/// THEME + DESIGN CONSTANTS
/// =======================
class AppTheme {
  // Base design width taken from the provided screenshot bitmap width.
  static const double kDesignWidth = 264.0;

  // Colors (from analysis)
  static const Color bg = Color(0xFFFFFFFF);
  static const Color primaryPurple = Color(0xFF802898);
  static const Color secondaryBtn = Color(0xFF484848);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color successGreen = Color(0xFF60D870);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF787878);
  static const Color onDark = Color(0xFFFFFFFF);

  static const double radius8 = 8.0;

  // Base paddings/spacings (px in spec == logical px here)
  static const double padH = 24.0;

  static ThemeData build() {
    // We style most things explicitly, but keep a sensible baseline.
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Roboto', // If your app uses another family, update here.
      splashFactory: InkRipple.splashFactory,
    );
  }
}

/// Helper to scale all px values relative to the screenshot width.
/// - At 264w: scale = 1.0 (pixel-match to spec)
/// - Clamp prevents absurd scaling on very small/very large screens.
class _Scale {
  final double s;
  const _Scale(this.s);
  double v(double px) => px * s;
}

/// =======================
/// SCREEN
/// =======================
class PaymentSuccessfulScreen extends StatelessWidget {
  const PaymentSuccessfulScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Constrain max width on larger screens; center content.
            final double contentWidth =
                constraints.maxWidth > 400 ? 400 : constraints.maxWidth;

            final double rawScale = contentWidth / AppTheme.kDesignWidth;
            final double clampedScale = rawScale.clamp(0.85, 1.45);

            final _Scale sx = _Scale(clampedScale);

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sx.v(AppTheme.padH)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== Header row =====
                        SizedBox(height: sx.v(8)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Back icon
                            InkResponse(
                              radius: sx.v(24),
                              onTap: () => Navigator.maybePop(context),
                              child: Icon(
                                Icons.chevron_left,
                                size: sx.v(24),
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(width: sx.v(16)),
                            Text(
                              'Payment successful',
                              style: _TextStyles.appBarTitle(sx),
                            ),
                          ],
                        ),
                        SizedBox(height: sx.v(20)),

                        // ===== Product summary row =====
                        _ProductSummaryRow(scale: sx),

                        SizedBox(height: sx.v(18)),
                        _divider(sx),

                        // ===== Status / Order ID =====
                        SizedBox(height: sx.v(16)),
                        Text(
                          'CompleteMar 01 - 11:40pm',
                          style: _TextStyles.statusSuccess(sx),
                        ),
                        SizedBox(height: sx.v(8)),
                        Text(
                          'Order ID: 2048348343944',
                          style: _TextStyles.metaLine(sx),
                        ),
                        SizedBox(height: sx.v(16)),
                        _divider(sx),

                        // ===== Order Summary =====
                        SizedBox(height: sx.v(14)),
                        Text(
                          'Order Summary',
                          style: _TextStyles.sectionHeader(sx),
                        ),
                        SizedBox(height: sx.v(12)),

                        _OrderSummaryRow(
                          scale: sx,
                          label: 'Watch ultra black',
                          value: 'KD 123.000',
                          isTotal: false,
                        ),
                        SizedBox(height: sx.v(12)),
                        _OrderSummaryRow(
                          scale: sx,
                          label: 'Wallet',
                          value: 'KD -20.000',
                          isTotal: false,
                        ),
                        SizedBox(height: sx.v(12)),
                        _OrderSummaryRow(
                          scale: sx,
                          label: 'Points',
                          value: 'KD 0.000',
                          isTotal: false,
                        ),
                        SizedBox(height: sx.v(14)),
                        _OrderSummaryRow(
                          scale: sx,
                          label: 'Total Amount',
                          value: 'KD 104.000',
                          isTotal: true,
                        ),

                        // ===== Buttons block =====
                        SizedBox(height: sx.v(34)),

                        Center(
                          child: _FixedWidthButton(
                            scale: sx,
                            widthPx: 116,
                            heightPx: 32, // spec noted 28–32; using 32 for usability + consistency
                            background: AppTheme.secondaryBtn,
                            label: 'View receipt',
                            onPressed: () {
                              // TODO: Navigate to receipt screen/modal.
                            },
                          ),
                        ),
                        SizedBox(height: sx.v(8)),
                        Center(
                          child: _FixedWidthButton(
                            scale: sx,
                            widthPx: 164,
                            heightPx: 32,
                            background: AppTheme.primaryPurple,
                            label: 'Install Your eSim Now!',
                            onPressed: () {
                              // TODO: Start installation flow.
                            },
                          ),
                        ),

                        // ===== Bottom link =====
                        SizedBox(height: sx.v(54)),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navigate to Help/Support.
                            },
                            style: ButtonStyle(
                              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                (states) => states.contains(MaterialState.pressed)
                                    ? AppTheme.textPrimary.withOpacity(0.08)
                                    : null,
                              ),
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              minimumSize: MaterialStateProperty.all(Size.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Get Help',
                              style: _TextStyles.bottomLink(sx),
                            ),
                          ),
                        ),

                        // Small bottom padding so the last link isn't flush.
                        SizedBox(height: sx.v(16)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _divider(_Scale sx) {
    return Container(
      height: sx.v(1),
      color: AppTheme.divider,
    );
  }
}

/// =======================
/// TEXT STYLES (pixel-aligned)
/// =======================
class _TextStyles {
  static TextStyle appBarTitle(_Scale sx) => TextStyle(
        fontSize: sx.v(18),
        fontWeight: FontWeight.w700,
        height: 22 / 18, // lineHeight / fontSize (kept unscaled ratio)
        letterSpacing: 0,
        color: AppTheme.textPrimary,
      );

  static TextStyle productTitle(_Scale sx) => TextStyle(
        fontSize: sx.v(16),
        fontWeight: FontWeight.w700,
        height: 20 / 16,
        color: AppTheme.textPrimary,
      );

  static TextStyle productSubtitle(_Scale sx) => TextStyle(
        fontSize: sx.v(12),
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppTheme.textSecondary,
      );

  static TextStyle rightPrice(_Scale sx) => TextStyle(
        fontSize: sx.v(13),
        fontWeight: FontWeight.w600,
        height: 16 / 13,
        color: AppTheme.textPrimary,
      );

  static TextStyle statusSuccess(_Scale sx) => TextStyle(
        fontSize: sx.v(12),
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: AppTheme.successGreen,
      );

  static TextStyle metaLine(_Scale sx) => TextStyle(
        fontSize: sx.v(12),
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppTheme.textSecondary,
      );

  static TextStyle sectionHeader(_Scale sx) => TextStyle(
        fontSize: sx.v(16),
        fontWeight: FontWeight.w700,
        height: 20 / 16,
        color: AppTheme.textPrimary,
      );

  static TextStyle rowLabel(_Scale sx) => TextStyle(
        fontSize: sx.v(12),
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppTheme.textSecondary,
      );

  static TextStyle rowValue(_Scale sx) => TextStyle(
        fontSize: sx.v(12),
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppTheme.textSecondary,
      );

  static TextStyle totalRow(_Scale sx) => TextStyle(
        fontSize: sx.v(12),
        fontWeight: FontWeight.w700,
        height: 16 / 12,
        color: AppTheme.textPrimary,
      );

  static TextStyle buttonLabel(_Scale sx) => TextStyle(
        fontSize: sx.v(13),
        fontWeight: FontWeight.w600,
        height: 16 / 13,
        color: AppTheme.onDark,
      );

  static TextStyle bottomLink(_Scale sx) => TextStyle(
        fontSize: sx.v(13),
        fontWeight: FontWeight.w600,
        height: 16 / 13,
        color: AppTheme.textPrimary,
        decoration: TextDecoration.underline,
        decorationThickness: sx.v(1),
      );
}

/// =======================
/// COMPONENTS
/// =======================

class _ProductSummaryRow extends StatelessWidget {
  final _Scale scale;
  const _ProductSummaryRow({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // ensures right price is top-aligned
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(scale.v(AppTheme.radius8)),
          child: SizedBox(
            width: scale.v(44),
            height: scale.v(44),
            child: Image.asset(
              'assets/south_africa_esim.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFEFEFEF),
                alignment: Alignment.center,
                child: Icon(
                  Icons.image,
                  size: scale.v(18),
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: scale.v(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'South Africa eSIM',
                style: _TextStyles.productTitle(scale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: scale.v(4)),
              Text(
                'with high level of long\nbatry and mat color',
                style: _TextStyles.productSubtitle(scale),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: scale.v(12)),
        Align(
          alignment: Alignment.topRight,
          child: Text(
            'KWD 12.000',
            style: _TextStyles.rightPrice(scale),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  final _Scale scale;
  final String label;
  final String value;
  final bool isTotal;

  const _OrderSummaryRow({
    required this.scale,
    required this.label,
    required this.value,
    required this.isTotal,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle leftStyle = isTotal ? _TextStyles.totalRow(scale) : _TextStyles.rowLabel(scale);
    final TextStyle rightStyle = isTotal ? _TextStyles.totalRow(scale) : _TextStyles.rowValue(scale);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic, // baseline-align label/value
      children: [
        Expanded(
          child: Text(
            label,
            style: leftStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Keep value pinned to right edge (within outer padding).
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            value,
            style: rightStyle,
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}

class _FixedWidthButton extends StatelessWidget {
  final _Scale scale;
  final double widthPx;
  final double heightPx;
  final Color background;
  final String label;
  final VoidCallback? onPressed;

  const _FixedWidthButton({
    required this.scale,
    required this.widthPx,
    required this.heightPx,
    required this.background,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double w = scale.v(widthPx);
    final double h = scale.v(heightPx);

    return SizedBox(
      width: w,
      height: h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(background),
          foregroundColor: MaterialStateProperty.all(AppTheme.onDark),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(scale.v(AppTheme.radius8)),
            ),
          ),
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(MaterialState.pressed)) {
                // Subtle pressed state: black overlay ~10%
                return Colors.black.withOpacity(0.10);
              }
              return null;
            },
          ),
          // Keep tap target tight for pixel match (but note this reduces accessibility).
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: MaterialStateProperty.all(Size(w, h)),
        ),
        child: Text(
          label,
          style: _TextStyles.buttonLabel(scale),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
