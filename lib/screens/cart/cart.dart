import 'package:flutter/material.dart';
// If you use SVG assets for logos, uncomment the next line and add flutter_svg to pubspec.yaml.
// import 'package:flutter_svg/flutter_svg.dart';

/// ===============================================================
/// Cart Screen — Pixel-spec implementation (based on provided image)
/// Base width: 375px (responsive rules included)
/// ===============================================================

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  PaymentMethod _selected = PaymentMethod.applePay;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);

    return Scaffold(
      backgroundColor: t.colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            // Responsiveness rule:
            // - On large screens, keep content max width 430px and center it.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== App Bar Row (custom, not Flutter AppBar) =====
                  const SizedBox(height: 0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: t.spacing.s16),
                    child: SizedBox(
                      height: t.sizes.appBarHeight, // 56px
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _BackButton(
                              size: t.sizes.icon24,
                              color: t.colors.textPrimary,
                              onTap: () => Navigator.maybePop(context),
                            ),
                          ),
                          // Visually centered title (not offset by leading)
                          Text(
                            'Cart',
                            style: t.text.appBarTitle,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== Section: Pay with =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: t.spacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: t.spacing.s16), // top margin ~16
                        Text('Pay with', style: t.text.sectionHeader),
                        SizedBox(height: t.spacing.s12), // bottom margin ~12
                      ],
                    ),
                  ),

                  // ===== Payment Options List =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: t.spacing.s16),
                    child: Column(
                      children: [
                        PaymentOptionTile(
                          height: t.sizes.optionTileHeight, // 56
                          radius: t.radii.r12,
                          selected: _selected == PaymentMethod.applePay,
                          selectedColor: t.colors.primary,
                          unselectedColor: t.colors.surface,
                          borderColor: t.colors.border,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: t.spacing.s12),
                          leading: BrandIcon(
                            size: t.sizes.brandIcon, // 28
                            radius: t.radii.r6,
                            kind: BrandIconKind.applePay,
                          ),
                          title: 'Apple Pay',
                          titleStyle: _selected == PaymentMethod.applePay
                              ? t.text.optionTitleSelected
                              : t.text.optionTitle,
                          onTap: () => setState(() {
                            _selected = PaymentMethod.applePay;
                          }),
                        ),
                        SizedBox(height: t.spacing.s8),
                        PaymentOptionTile(
                          height: t.sizes.optionTileHeight,
                          radius: t.radii.r12,
                          selected: _selected == PaymentMethod.knet,
                          selectedColor: t.colors.primary,
                          unselectedColor: t.colors.surface,
                          borderColor: t.colors.border,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: t.spacing.s12),
                          leading: BrandIcon(
                            size: t.sizes.brandIcon,
                            radius: t.radii.r6,
                            kind: BrandIconKind.knet,
                          ),
                          title: 'KNET',
                          titleStyle: _selected == PaymentMethod.knet
                              ? t.text.optionTitleSelected
                              : t.text.optionTitle,
                          onTap: () => setState(() {
                            _selected = PaymentMethod.knet;
                          }),
                        ),
                        SizedBox(height: t.spacing.s8),
                        PaymentOptionTile(
                          height: t.sizes.optionTileHeight,
                          radius: t.radii.r12,
                          selected: _selected == PaymentMethod.masterCard1,
                          selectedColor: t.colors.primary,
                          unselectedColor: t.colors.surface,
                          borderColor: t.colors.border,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: t.spacing.s12),
                          leading: BrandIcon(
                            size: t.sizes.brandIcon,
                            radius: t.radii.r6,
                            kind: BrandIconKind.mastercard,
                          ),
                          title: 'Master Card',
                          titleStyle: _selected == PaymentMethod.masterCard1
                              ? t.text.optionTitleSelected
                              : t.text.optionTitle,
                          onTap: () => setState(() {
                            _selected = PaymentMethod.masterCard1;
                          }),
                        ),
                        SizedBox(height: t.spacing.s8),
                        PaymentOptionTile(
                          height: t.sizes.optionTileHeight,
                          radius: t.radii.r12,
                          selected: _selected == PaymentMethod.masterCard2,
                          selectedColor: t.colors.primary,
                          unselectedColor: t.colors.surface,
                          borderColor: t.colors.border,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: t.spacing.s12),
                          leading: BrandIcon(
                            size: t.sizes.brandIcon,
                            radius: t.radii.r6,
                            kind: BrandIconKind.mastercard,
                          ),
                          title: 'Master Card',
                          titleStyle: _selected == PaymentMethod.masterCard2
                              ? t.text.optionTitleSelected
                              : t.text.optionTitle,
                          onTap: () => setState(() {
                            _selected = PaymentMethod.masterCard2;
                          }),
                        ),
                        SizedBox(height: t.spacing.s8),
                        PaymentOptionTile(
                          height: t.sizes.optionTileHeight,
                          radius: t.radii.r12,
                          selected: _selected == PaymentMethod.masterCard3,
                          selectedColor: t.colors.primary,
                          unselectedColor: t.colors.surface,
                          borderColor: t.colors.border,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: t.spacing.s12),
                          leading: BrandIcon(
                            size: t.sizes.brandIcon,
                            radius: t.radii.r6,
                            kind: BrandIconKind.mastercard,
                          ),
                          title: 'Master Card',
                          titleStyle: _selected == PaymentMethod.masterCard3
                              ? t.text.optionTitleSelected
                              : t.text.optionTitle,
                          onTap: () => setState(() {
                            _selected = PaymentMethod.masterCard3;
                          }),
                        ),
                      ],
                    ),
                  ),

                  // ===== Section: Payment summary =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: t.spacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: t.spacing.s24),
                        Text('Payment summary', style: t.text.sectionHeader),
                        SizedBox(height: t.spacing.s8),
                      ],
                    ),
                  ),

                  // ===== Summary Table =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: t.spacing.s16),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Subtotal',
                          value: 'KD 123.000',
                          labelStyle: t.text.bodyLabel,
                          valueStyle: t.text.bodyValue,
                          height: t.sizes.summaryRowHeight, // ~22
                        ),
                        _SummaryRow(
                          label: 'Wallet',
                          value: 'KD -20.000',
                          labelStyle: t.text.bodyLabel,
                          valueStyle: t.text.bodyValue,
                          height: t.sizes.summaryRowHeight,
                        ),
                        _SummaryRow(
                          label: 'Points',
                          value: 'KD 0.000',
                          labelStyle: t.text.bodyLabel,
                          valueStyle: t.text.bodyValue,
                          height: t.sizes.summaryRowHeight,
                        ),
                        SizedBox(height: t.spacing.s8),
                        Divider(
                          height: t.sizes.dividerThickness, // visual thickness
                          thickness: t.sizes.dividerThickness,
                          color: t.colors.border,
                        ),
                        SizedBox(height: t.spacing.s8),
                        _SummaryRow(
                          label: 'Total Amount',
                          value: 'KD 104.000',
                          labelStyle: t.text.bodyTotalLabel,
                          valueStyle: t.text.bodyTotalValue,
                          height: t.sizes.summaryRowHeight + 2,
                        ),
                      ],
                    ),
                  ),

                  // ===== Primary CTA =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: t.spacing.s16),
                    child: Column(
                      children: [
                        SizedBox(height: t.spacing.s24),
                        PrimaryCtaButton(
                          height: t.sizes.ctaHeight, // 52
                          radius: t.radii.r16, // 16
                          backgroundColor: t.colors.primary,
                          text: 'Go To Payment',
                          textStyle: t.text.buttonText,
                          onTap: () {
                            // TODO: navigate to payment screen
                          },
                        ),
                        SizedBox(height: t.spacing.s32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================
/// Design Tokens / Theme
/// =======================

class AppTokens {
  final _Colors colors;
  final _Text text;
  final _Spacing spacing;
  final _Radii radii;
  final _Sizes sizes;

  const AppTokens._({
    required this.colors,
    required this.text,
    required this.spacing,
    required this.radii,
    required this.sizes,
  });

  static AppTokens of(BuildContext context) {
    // If you want, you can wire this to Theme extensions.
    return const AppTokens._(
      colors: _Colors(),
      text: _Text(),
      spacing: _Spacing(),
      radii: _Radii(),
      sizes: _Sizes(),
    );
  }
}

class _Colors {
  const _Colors();

  // Core
  final Color background = const Color(0xFFFFFFFF); // #FFFFFF
  final Color primary = const Color(0xFF7A2E9A); // approx #7A2E9A
  final Color surface = const Color(0xFFF6F6F6); // #F6F6F6
  final Color border = const Color(0xFFE5E5E5); // #E5E5E5

  // Text
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF6B6B6B);
  final Color textMuted = const Color(0xFF9A9A9A);

  // Selected text on primary
  final Color onPrimary = const Color(0xFFFFFFFF);

  // Brand fallback colors
  final Color black = const Color(0xFF000000);
}

class _Text {
  const _Text();

  // NOTE: If SF Pro isn't available, Flutter will fallback.
  // You can also set a global fontFamily in MaterialApp theme.

  TextStyle get appBarTitle => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 22 / 17,
        letterSpacing: 0,
        color: Color(0xFF111111),
      );

  TextStyle get sectionHeader => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0,
        color: Color(0xFF6B6B6B),
      );

  TextStyle get optionTitle => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 20 / 15,
        letterSpacing: 0,
        color: Color(0xFF111111),
      );

  TextStyle get optionTitleSelected => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 20 / 15,
        letterSpacing: 0,
        color: Color(0xFFFFFFFF),
      );

  TextStyle get bodyLabel => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18 / 13,
        letterSpacing: 0,
        color: Color(0xFF9A9A9A),
      );

  TextStyle get bodyValue => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 18 / 13,
        letterSpacing: 0,
        color: Color(0xFF111111),
      );

  TextStyle get bodyTotalLabel => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        letterSpacing: 0,
        color: Color(0xFF111111),
      );

  TextStyle get bodyTotalValue => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        letterSpacing: 0,
        color: Color(0xFF111111),
      );

  TextStyle get buttonText => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 20 / 15,
        letterSpacing: 0,
        color: Color(0xFFFFFFFF),
      );
}

class _Spacing {
  const _Spacing();

  final double s8 = 8;
  final double s12 = 12;
  final double s16 = 16;
  final double s24 = 24;
  final double s32 = 32;
}

class _Radii {
  const _Radii();

  final double r6 = 6; // for brand icon rounding (subtle)
  final double r12 = 12; // cards
  final double r16 = 16; // CTA button
}

class _Sizes {
  const _Sizes();

  final double appBarHeight = 56;
  final double icon24 = 24;

  final double optionTileHeight = 56;
  final double brandIcon = 28;

  final double summaryRowHeight = 22;
  final double dividerThickness = 1;

  final double ctaHeight = 52;
}

/// =======================
/// Widgets
/// =======================

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.size,
    required this.color,
    required this.onTap,
  });

  final double size;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // iOS-like: minimal splash
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.black.withOpacity(0.05),
          onTap: onTap,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.arrow_back_ios_new,
              size: size - 2, // visually closer to iOS back chevron
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentOptionTile extends StatelessWidget {
  const PaymentOptionTile({
    super.key,
    required this.height,
    required this.radius,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.borderColor,
    required this.contentPadding,
    required this.leading,
    required this.title,
    required this.titleStyle,
    required this.onTap,
  });

  final double height;
  final double radius;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color borderColor;
  final EdgeInsets contentPadding;
  final Widget leading;
  final String title;
  final TextStyle titleStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? selectedColor : unselectedColor;
    final border = selected
        ? Border.all(color: Colors.transparent, width: 0)
        : Border.all(color: borderColor, width: 1);

    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius),
              border: border,
            ),
            padding: contentPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // No trailing radio/chevron in screenshot
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
    required this.height,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // baseline-ish visually
        children: [
          Expanded(
            child: Text(
              label,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: valueStyle,
            maxLines: 1,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class PrimaryCtaButton extends StatefulWidget {
  const PrimaryCtaButton({
    super.key,
    required this.height,
    required this.radius,
    required this.backgroundColor,
    required this.text,
    required this.textStyle,
    required this.onTap,
  });

  final double height;
  final double radius;
  final Color backgroundColor;
  final String text;
  final TextStyle textStyle;
  final VoidCallback onTap;

  @override
  State<PrimaryCtaButton> createState() => _PrimaryCtaButtonState();
}

class _PrimaryCtaButtonState extends State<PrimaryCtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color bg =
        _pressed ? widget.backgroundColor.withOpacity(0.85) : widget.backgroundColor;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          alignment: Alignment.center,
          child: Text(widget.text, style: widget.textStyle),
        ),
      ),
    );
  }
}

/// =======================
/// Payment methods
/// =======================

enum PaymentMethod {
  applePay,
  knet,
  masterCard1,
  masterCard2,
  masterCard3,
}

/// =======================
/// Brand icons (logos)
/// - Replace placeholder widgets with your asset loaders.
/// =======================

enum BrandIconKind { applePay, knet, mastercard }

class BrandIcon extends StatelessWidget {
  const BrandIcon({
    super.key,
    required this.size,
    required this.radius,
    required this.kind,
  });

  final double size;
  final double radius;
  final BrandIconKind kind;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);

    // If you have real assets, replace placeholders with:
    // SvgPicture.asset('assets/icons/apple_pay.svg', width: size, height: size)
    // etc. Ensure they fit within 28x28 and preserve aspect ratio.

    switch (kind) {
      case BrandIconKind.applePay:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: t.colors.black,
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Pay',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        );

      case BrandIconKind.knet:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: t.colors.border, width: 1),
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: const Text(
            'KNET',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E5AA8),
              height: 1.0,
            ),
          ),
        );

      case BrandIconKind.mastercard:
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: size * 0.18,
                child: Container(
                  width: size * 0.48,
                  height: size * 0.48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEB001B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: size * 0.18,
                child: Container(
                  width: size * 0.48,
                  height: size * 0.48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF79E1B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
