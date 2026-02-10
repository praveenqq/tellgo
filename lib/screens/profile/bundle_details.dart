import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Pixel-focused implementation of the provided screen.
/// Notes:
/// - Targets iOS-like layout (Dynamic Island safe area).
/// - Scrollable body + fixed bottom navigation (3 tabs; middle selected).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: AppColors.headerBg,
      fontFamilyFallback: const [
        // iOS-ish
        'SF Pro Display',
        'SF Pro Text',
        // Android fallback
        'Roboto',
        'Inter',
      ],
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimary),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const EsimScreen(),
    );
  }
}

class EsimScreen extends StatelessWidget {
  const EsimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;

    // Responsiveness rules:
    // - Use 20px side padding normally.
    // - Reduce to 16px on very small widths (< 360).
    final horizontalPad = w < 360 ? 16.0 : 20.0;

    // Cap content width at 420px and center on large screens.
    final maxContentWidth = 420.0;

    // Bottom nav height (visual): ~96px + SafeArea bottom inset
    const navVisualHeight = 96.0;

    return Scaffold(
      backgroundColor: AppColors.headerBg,
      bottomNavigationBar: const _BottomNav(selectedIndex: 1),
      body: SafeArea(
        top: true,
        bottom: false, // bottom handled by nav bar + body padding
        child: Column(
          children: [
            _TopHeader(horizontalPad: horizontalPad),
            Expanded(
              child: Container(
                color: AppColors.bodyBg,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final contentWidth =
                        math.min(constraints.maxWidth, maxContentWidth);

                    return Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: contentWidth,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPad,
                              16,
                              horizontalPad,
                              navVisualHeight + mq.padding.bottom + 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                _PackageSummaryCard(),
                                SizedBox(height: 16),
                                _SectionTitle("eSIM Installation"),
                                SizedBox(height: 10),
                                _PrimaryCTAButton(
                                  label: "Direct Install eSIM",
                                  height: 45,
                                ),
                                SizedBox(height: 8),
                                _PrimaryCTAButton(
                                  label: "Activate by QR code",
                                  height: 45,
                                ),
                                SizedBox(height: 16),
                                _EsimDetailsCard(),
                                SizedBox(height: 18),
                                _DetailsPanel(),
                                SizedBox(height: 24),
                                _TopUpButton(),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================
/// DESIGN TOKENS
/// =====================

class AppColors {
  static const primary = Color(0xFF74459B); // #74459B
  static const headerBg = Color(0xFFFFFFFF);
  static const bodyBg = Color(0xFFF4F4F5);

  static const cardBg = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF777777);

  static const dividerLight = Color(0xFFEDEDED);
  static const dividerMedium = Color(0xFFF0F0F0);

  static const pendingDot = Color(0xFFF5DE06);
  static const badgeRed = Color(0xFFED1C24);

  static const progressTrack = Color(0xFFB098C0);

  static const darkButton = Color(0xFF333333);
}

class AppRadii {
  static const card = 16.0;
  static const cta = 8.0;
  static const smallButton = 8.0;
  static const darkButton = 6.0;
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x1A000000), // ~10% opacity
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
}

class AppTextStyles {
  // Header
  static const hello = TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const name = TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const welcomeBack = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const balance = TextStyle(
    fontSize: 13,
    height: 16 / 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // Titles
  static const cardTitle = TextStyle(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const sectionTitle = TextStyle(
    fontSize: 18,
    height: 22 / 18,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  // Fields
  static const fieldLabel = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const fieldValue = TextStyle(
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Buttons
  static const ctaText = TextStyle(
    fontSize: 18,
    height: 22 / 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const smallButtonText = TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const darkButtonText = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Stats
  static const statLabel = TextStyle(
    fontSize: 15,
    height: 18 / 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const statValue = TextStyle(
    fontSize: 22,
    height: 26 / 22,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  // Bottom nav
  static const navLabel = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const navLabelSelected = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

/// =====================
/// TOP HEADER
/// =====================

class _TopHeader extends StatelessWidget {
  final double horizontalPad;
  const _TopHeader({required this.horizontalPad});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPad, 8, horizontalPad, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: const TextSpan(
                        children: [
                          TextSpan(text: 'Hello, ', style: AppTextStyles.hello),
                          TextSpan(text: 'Hamdan !', style: AppTextStyles.name),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('welcome back', style: AppTextStyles.welcomeBack),
                  ],
                ),
              ),

              // Balance + bell
              Row(
                children: const [
                  Text('20.00KD', style: AppTextStyles.balance),
                  SizedBox(width: 12),
                  _BellWithBadge(badgeCount: 3),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Divider under header (subtle purple/grey line)
          Container(
            height: 1,
            color: AppColors.primary.withOpacity(0.35),
          ),
        ],
      ),
    );
  }
}

class _BellWithBadge extends StatelessWidget {
  final int badgeCount;
  const _BellWithBadge({required this.badgeCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Purple circular button
          Positioned.fill(
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: const Center(
                  child: Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // Badge
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.badgeRed,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// BODY CARDS
/// =====================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.sectionTitle);
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
      ),
      padding: padding,
      child: child,
    );
  }
}

class _PendingChip extends StatelessWidget {
  const _PendingChip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _StatusDot(),
        SizedBox(width: 6),
        Text(
          'Pending',
          style: TextStyle(
            fontSize: 14,
            height: 18 / 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.pendingDot,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  const _InfoIcon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Icon(
        Icons.info_outline,
        size: 12,
        color: AppColors.textSecondary.withOpacity(0.45),
      ),
    );
  }
}

class _PackageSummaryCard extends StatelessWidget {
  const _PackageSummaryCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + pending
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Expanded(
                child: Text(
                  'Giza Moibile 2GB/ 7 Days',
                  style: AppTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 12),
              _PendingChip(),
            ],
          ),
          const SizedBox(height: 14),

          // Fields
          const _FieldBlock(
            label: 'Order ID',
            value: '65273784',
            showInfo: true,
          ),
          const SizedBox(height: 12),
          const _FieldBlock(
            label: 'ICCID NUMBER',
            value: '89109284949938829382938',
            showInfo: true,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          const _FieldBlock(
            label: 'COVERAGE',
            value: 'Egypt',
            showInfo: false,
          ),
        ],
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool showInfo;
  final int maxLines;

  const _FieldBlock({
    required this.label,
    required this.value,
    this.showInfo = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.fieldLabel),
            if (showInfo) const _InfoIcon(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.fieldValue,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
      ],
    );
  }
}

class _PrimaryCTAButton extends StatelessWidget {
  final String label;
  final double height;
  final VoidCallback? onTap;

  const _PrimaryCTAButton({
    required this.label,
    this.height = 45,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.cta),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.cta),
          onTap: onTap ?? () {},
          child: Center(
            child: Text(label, style: AppTextStyles.ctaText),
          ),
        ),
      ),
    );
  }
}

class _EsimDetailsCard extends StatelessWidget {
  const _EsimDetailsCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name row + edit + pending
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Name', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Abdullah Hamdan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 18 / 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'EDIT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary.withOpacity(0.9),
                      height: 14 / 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              const _PendingChip(),
            ],
          ),

          const SizedBox(height: 12),

          // Fields + right buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left fields
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _InlineField(label: 'ICCID', value: '77748273484920101929'),
                    SizedBox(height: 6),
                    _InlineField(label: 'COVERAGE', value: 'Egypt'),
                    SizedBox(height: 6),
                    _InlineField(
                      label: 'Data',
                      value: 'Giza Mobile 2GB / 7 Days',
                    ),
                    SizedBox(height: 6),
                    _InlineField(label: 'Mobile No.', value: '00965 9887 3177'),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Right action buttons (fixed sizing)
              Column(
                children: const [
                  _SmallActionButton(label: 'Activate'),
                  SizedBox(height: 8),
                  _SmallActionButton(label: 'Share eSIM'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.dividerLight),
          const SizedBox(height: 12),

          // Remaining Internet row
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Remaing Internet',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 18 / 14,
                  ),
                ),
              ),
              Text(
                '2 GB of 2GB',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 18 / 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar (6px height)
          const _ProgressBar(value: 1.0),

          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.dividerLight),
          const SizedBox(height: 10),

          // Stats row with vertical dividers
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Expanded(
                  child: _StatCell(label: 'Local Calls', value: '100 min'),
                ),
                _VSeparator(),
                Expanded(
                  child: _StatCell(label: 'international\nCalls', value: '0'),
                ),
                _VSeparator(),
                Expanded(
                  child: _StatCell(label: 'Messages', value: '500'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineField extends StatelessWidget {
  final String label;
  final String value;

  const _InlineField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84, // keeps labels aligned like the screenshot
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              height: 16 / 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 18 / 14,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SmallActionButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 91,
      height: 26,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.smallButton),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.smallButton),
          onTap: onTap ?? () {},
          child: Center(child: Text(label, style: AppTextStyles.smallButtonText)),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value; // 0..1
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final fillW = (w * value).clamp(0.0, w);
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: AppColors.progressTrack.withOpacity(0.45),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: fillW,
                  child: Container(color: AppColors.primary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VSeparator extends StatelessWidget {
  const _VSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: AppColors.dividerMedium,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.statLabel, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.statValue, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Details', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.dividerLight),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 16 / 13,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              height: 32,
              child: Material(
                color: AppColors.darkButton,
                borderRadius: BorderRadius.circular(AppRadii.darkButton),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.darkButton),
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Center(
                      child: Text(
                        'More details about my eSIM',
                        style: AppTextStyles.darkButtonText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopUpButton extends StatelessWidget {
  const _TopUpButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 231,
        height: 36,
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadii.cta),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.cta),
            onTap: () {},
            child: const Center(
              child: Text(
                'Top Up',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 22 / 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =====================
/// BOTTOM NAVIGATION
/// =====================

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  const _BottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: AppColors.headerBg,
        height: 96,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                selected: selectedIndex == 0,
                label: 'Home',
                icon: Icons.home_outlined,
                onTap: () {},
              ),
            ),
            Expanded(
              child: _NavItemSelectedCenter(
                selected: selectedIndex == 1,
                label: 'Data Plans',
                onTap: () {},
              ),
            ),
            Expanded(
              child: _NavItem(
                selected: selectedIndex == 2,
                label: 'My Account',
                icon: Icons.person_outline,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavItem({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // In this UI, only the center tab has the purple selection block.
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: AppColors.textPrimary),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.navLabel),
          ],
        ),
      ),
    );
  }
}

class _NavItemSelectedCenter extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _NavItemSelectedCenter({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Purple block behind icon+label (~138x82 in the screenshot).
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 138,
          height: 82,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.zero,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "eSIM" badge-like icon area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'eSIM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 14 / 11,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(label, style: AppTextStyles.navLabelSelected),
            ],
          ),
        ),
      ),
    );
  }
}
