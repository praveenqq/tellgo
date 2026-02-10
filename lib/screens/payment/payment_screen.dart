import 'package:flutter/material.dart';

/// Payment Screen rebuilt to match the provided screenshot as closely as possible.
/// Base design width assumed: 375px.
/// All measurements in px (logical pixels in Flutter).
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selected = PaymentMethod.wallet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          // The screenshot shows a scrollable body, with CTA below the card.
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(UISpacing.screenPadding16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CardSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PlanHeader(
                        onEdit: () {
                          // TODO: navigation/interaction
                        },
                      ),
                      const _SectionDivider(),

                      const _TotalPriceRow(),
                      const _SectionDivider(),

                      _DiscountRow(
                        title: 'Discount codes and Vouchers',
                        onTap: () {
                          // TODO: expand/collapse
                        },
                      ),
                      const _SectionDivider(),

                      _PaymentMethodsSection(
                        selected: _selected,
                        onChanged: (m) => setState(() => _selected = m),
                      ),
                      const _SectionDivider(),

                      const _PayableAmountRow(),
                    ],
                  ),
                ),

                const SizedBox(height: UISpacing.sectionGap24),

                _PrimaryButton(
                  text: 'Go To Payment',
                  onPressed: () {
                    // TODO: proceed to payment
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================
   TOKENS / CONSTANTS
   =========================== */

enum PaymentMethod { points, wallet }

class UIColors {
  // Approximated from screenshot (±5% tolerance). Adjust after comparing on-device.
  static const Color background = Color(0xFFF6F7F9); // page background
  static const Color surface = Color(0xFFFFFFFF); // card
  static const Color primary = Color(0xFF6A2FA1); // purple
  static const Color primaryPressed = Color(0xFF58248C); // darker purple
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color iconMuted = Color(0xFF6B7280);
  static const Color danger = Color(0xFFE11D48); // EDIT
}

class UISpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;

  static const double screenPadding16 = 16;
  static const double cardPadding16 = 16;
  static const double dividerVSpacing12 = 12;
  static const double sectionGap24 = 24;

  static const double rowHeight52 = 52;
  static const double discountRowHeight44 = 44;
  static const double buttonHeight52 = 52;
}

class UIRadius {
  static const double r8 = 8;
  static const double r12 = 12;
}

class UITextStyles {
  // Font: Inter preferred; on Android will typically fall back to Roboto unless Inter is bundled.
  // If you need Inter, add it to pubspec.yaml and set fontFamily in ThemeData.
  static const TextStyle titleSmall16Semibold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    color: UIColors.textPrimary,
  );

  static const TextStyle body14RegularSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 18 / 14,
    color: UIColors.textSecondary,
  );

  static const TextStyle body14MediumPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 18 / 14,
    color: UIColors.textPrimary,
  );

  static const TextStyle caption12RegularMuted = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 14 / 12,
    color: UIColors.textMuted,
  );

  static const TextStyle action12SemiboldDanger = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 14 / 12,
    color: UIColors.danger,
  );

  static const TextStyle button16SemiboldWhite = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    color: Colors.white,
  );

  static const TextStyle label12UpperSecondary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 14 / 12,
    letterSpacing: 0.1,
    color: UIColors.textSecondary,
  );
}

/* ===========================
   SCREEN SECTIONS / WIDGETS
   =========================== */

class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UISpacing.cardPadding16),
      decoration: BoxDecoration(
        color: UIColors.surface,
        borderRadius: BorderRadius.circular(UIRadius.r12),
        boxShadow: const [
          // subtle elevation from spec: 0px 1px 2px rgba(0,0,0,0.04)
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
            color: Color.fromRGBO(0, 0, 0, 0.04),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UISpacing.dividerVSpacing12),
      child: Container(
        height: 1,
        color: UIColors.divider,
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left content expands, right edit pinned.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('UAE Mobile', style: UITextStyles.titleSmall16Semibold),
              SizedBox(height: UISpacing.s4),
              Text(
                'Data 10GB | Validity 7 Days',
                style: UITextStyles.body14RegularSecondary,
              ),
              SizedBox(height: UISpacing.s4),
              _HeaderMetaRow(),
            ],
          ),
        ),
        const SizedBox(width: UISpacing.s12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onEdit,
          child: Padding(
            // Larger tap target without changing visual.
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text('EDIT', style: UITextStyles.action12SemiboldDanger),
          ),
        ),
      ],
    );
  }
}

class _HeaderMetaRow extends StatelessWidget {
  const _HeaderMetaRow();

  @override
  Widget build(BuildContext context) {
    // Screenshot shows "KD 2.500" and "QTY 1" on same line.
    return Row(
      children: const [
        Text('KD 2.500', style: UITextStyles.caption12RegularMuted),
        SizedBox(width: UISpacing.s12),
        Text('QTY 1', style: UITextStyles.caption12RegularMuted),
      ],
    );
  }
}

class _TotalPriceRow extends StatelessWidget {
  const _TotalPriceRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Text('TOTAL PRICE', style: UITextStyles.label12UpperSecondary),
        ),
        Text('KWD 123.000', style: UITextStyles.body14MediumPrimary),
      ],
    );
  }
}

class _DiscountRow extends StatelessWidget {
  const _DiscountRow({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: UISpacing.discountRowHeight44,
      child: InkWell(
        borderRadius: BorderRadius.circular(UIRadius.r8),
        onTap: onTap,
        child: Padding(
          // Keep content aligned with other rows (no extra leading padding).
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: UITextStyles.body14RegularSecondary.copyWith(
                    color: UIColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: UISpacing.s8),
              Icon(
                Icons.expand_more,
                size: 20,
                color: UIColors.iconMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodsSection extends StatelessWidget {
  const _PaymentMethodsSection({
    required this.selected,
    required this.onChanged,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 18 / 14,
            color: UIColors.textPrimary,
          ),
        ),
        const SizedBox(height: UISpacing.s8),

        // Points (unselected by default in screenshot)
        _PaymentMethodTile(
          method: PaymentMethod.points,
          selected: selected == PaymentMethod.points,
          onTap: () => onChanged(PaymentMethod.points),
          leadingIcon: Icons.stars_outlined,
          title: 'Points (41)',
          subtitle: 'Equivalent to 1.02 KWD',
        ),

        const SizedBox(height: UISpacing.s12),

        // Wallet (selected in screenshot)
        _PaymentMethodTile(
          method: PaymentMethod.wallet,
          selected: selected == PaymentMethod.wallet,
          onTap: () => onChanged(PaymentMethod.wallet),
          leadingIcon: Icons.account_balance_wallet_outlined,
          title: 'Wallet',
          subtitle: '20.00 KWD',
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;
  final IconData leadingIcon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? Colors.white : UIColors.textPrimary;
    final Color subFg = selected ? Colors.white : UIColors.textSecondary;
    final Color iconColor = selected ? Colors.white : UIColors.iconMuted;

    return SizedBox(
      height: UISpacing.rowHeight52,
      child: Material(
        color: selected ? UIColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(UIRadius.r12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UIRadius.r12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: UISpacing.s12),
            child: Row(
              children: [
                Icon(leadingIcon, size: 24, color: iconColor),
                const SizedBox(width: UISpacing.s12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 18 / 14,
                          color: fg,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 14 / 12,
                          color: subFg.withOpacity(selected ? 0.95 : 1.0),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: UISpacing.s12),

                _RadioIndicator(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    // Custom to match screenshot (20px, white on purple, muted on white).
    final Color stroke = selected ? Colors.white : UIColors.divider;
    final Color fill = selected ? Colors.white : Colors.transparent;
    final Color dot = selected ? UIColors.primary : Colors.transparent;

    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: stroke, width: 2),
              color: fill.withOpacity(selected ? 0.15 : 0.0),
            ),
          ),
          if (selected)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dot,
              ),
            ),
        ],
      ),
    );
  }
}

class _PayableAmountRow extends StatelessWidget {
  const _PayableAmountRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'Payable Amount:',
            style: UITextStyles.body14RegularSecondary,
          ),
        ),
        Text(
          'KWD 90.000',
          style: UITextStyles.body14MediumPrimary,
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        height: UISpacing.buttonHeight52,
        decoration: BoxDecoration(
          color: _pressed ? UIColors.primaryPressed : UIColors.primary,
          borderRadius: BorderRadius.circular(UIRadius.r12),
        ),
        alignment: Alignment.center,
        child: Text(widget.text, style: UITextStyles.button16SemiboldWhite),
      ),
    );
  }
}
