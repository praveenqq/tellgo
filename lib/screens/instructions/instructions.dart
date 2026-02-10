import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Pixel-focused implementation of the provided screenshot.
/// - iOS-like header (center title + back chevron)
/// - Purple segmented control (3 tabs, “QR Code” selected)
/// - Grouped background + rounded shadow cards
/// - Warning card, QR card with outline “SHARE QR CODE” button
/// - Two accordions, both expanded by default
/// - Optional bottom overlay (seen in screenshot; toggle off if not needed)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const ViewInstructionsScreen(),
    );
  }
}

class ViewInstructionsScreen extends StatefulWidget {
  const ViewInstructionsScreen({super.key});

  @override
  State<ViewInstructionsScreen> createState() => _ViewInstructionsScreenState();
}

class _ViewInstructionsScreenState extends State<ViewInstructionsScreen> {
  int selectedSegment = 1; // 0=Direct, 1=QR Code, 2=Manual (QR Code selected in screenshot)
  bool expanded1 = true;
  bool expanded2 = true;

  // Screenshot includes a bottom overlay (likely external UI). Keep ON to match screenshot.
  // Turn OFF if you only want the app screen.
  static const bool showBottomOverlay = true;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;

    // Base design width from the analysis: ~414px.
    final scale = (w / 414.0).clamp(0.77, 1.05);

    double sp(double px) => px * scale;

    final cardHPad = (sp(16)).clamp(12.0, 20.0); // major card outer padding
    final segHPad = (sp(32)).clamp(16.0, 36.0); // segmented control inset
    final headerHPad = sp(16);

    final qrSize = (sp(200)).clamp(160.0, 220.0);
    final shareBtnW = (sp(190)).clamp(160.0, 220.0);
    final shareBtnH = (sp(32)).clamp(30.0, 36.0);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Stack(
          children: [
            Column(
              children: [
                _TopAppBar(
                  padding: EdgeInsets.symmetric(horizontal: headerHPad),
                  title: 'View Instructions',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                SizedBox(height: sp(8)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: segHPad),
                  child: SegmentedPill(
                    height: (sp(36)).clamp(34.0, 38.0),
                    borderRadius: (sp(12)).clamp(10.0, 12.0),
                    selectedIndex: selectedSegment,
                    labels: const ['Direct', 'QR Code', 'Manual'],
                    onChanged: (i) => setState(() => selectedSegment = i),
                  ),
                ),
                SizedBox(height: sp(12)),
                Expanded(
                  child: Container(
                    color: AppColors.groupedBg,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: sp(12), bottom: sp(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: cardHPad),
                            child: WarningCard(
                              padding: EdgeInsets.all(sp(14)),
                              iconSize: sp(28),
                              title: 'WARNING!',
                              body:
                                  ' Most eSims can only be installed once. If you remove the eSim from your device, you cannot install it again.',
                            ),
                          ),
                          SizedBox(height: sp(12)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: cardHPad),
                            child: QrCard(
                              padding: EdgeInsets.all(sp(16)),
                              qrSize: qrSize,
                              shareButtonWidth: shareBtnW,
                              shareButtonHeight: shareBtnH,
                              // Provide an asset if you want the exact QR image:
                              // qrAssetPath: 'assets/qr.png',
                              onShare: () {
                                // Hook to share sheet / share QR logic.
                              },
                            ),
                          ),
                          SizedBox(height: sp(12)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: cardHPad),
                            child: AccordionCard(
                              title: '1 - Install eSim',
                              expanded: expanded1,
                              onToggle: () => setState(() => expanded1 = !expanded1),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(sp(16), sp(14), sp(16), sp(16)),
                                child: Text(
                                  _installEsimText,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: sp(12)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: cardHPad),
                            child: AccordionCard(
                              title: '2 - Access Data',
                              expanded: expanded2,
                              onToggle: () => setState(() => expanded2 = !expanded2),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(sp(16), sp(14), sp(16), sp(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    AccessDataInsetCard(
                                      padding: EdgeInsets.all(sp(16)),
                                      radius: (sp(12)).clamp(10.0, 12.0),
                                      dividerColor: AppColors.lightPurpleDivider,
                                      items: const [
                                        AccessDataItem(label: 'NETWORK', value: 'Zain LTE'),
                                        AccessDataItem(label: 'APN', value: 'The APN is set automatically'),
                                        AccessDataItem(label: 'DATA ROAMING', value: 'ON'),
                                      ],
                                    ),
                                    SizedBox(height: sp(14)),
                                    Text(
                                      _accessDataText,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: sp(24)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (showBottomOverlay)
              Positioned(
                left: cardHPad,
                right: cardHPad,
                bottom: (sp(10)).clamp(8.0, 14.0),
                child: _BottomOverlayBar(
                  height: (sp(92)).clamp(84.0, 100.0),
                  radius: (sp(16)).clamp(14.0, 18.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------- THEME / TOKENS -----------------------------

class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const groupedBg = Color(0xFFF4F4F5);

  static const primaryPurple = Color(0xFF832D9F);

  static const divider = Color(0xFFD5D5D6);
  static const outlineGray = Color(0xFFB7B7B8);

  static const insetBg = Color(0xFFF8F8F8);
  static const lightPurpleDivider = Color(0xFFDECEE3);

  static const warningYellow = Color(0xFFF5E800);

  static const overlayDark = Color(0xFF282828);

  static const textPrimary = Color(0xFF0F0F0F);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textMuted = Color(0xFF9A9AA0);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.white,
      fontFamily: null, // uses platform default (SF Pro on iOS, Roboto on Android)
      splashFactory: InkRipple.splashFactory,
      textTheme: const TextTheme(
        titleMedium: TextStyle(
          fontSize: 17,
          height: 22 / 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          height: 22 / 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13.5,
          height: 19 / 13.5,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          height: 18 / 12.5,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: AppColors.textMuted,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          height: 14 / 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  static List<BoxShadow> cardShadow({double opacity = 0.10}) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: 22,
        offset: const Offset(0, 6),
      ),
    ];
  }
}

// ----------------------------- HEADER -----------------------------

class _TopAppBar extends StatelessWidget {
  const _TopAppBar({
    required this.padding,
    required this.title,
    required this.onBack,
  });

  final EdgeInsets padding;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            InkResponse(
              onTap: onBack,
              radius: 24,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.chevron_left, size: 28, color: AppColors.textPrimary),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 44, height: 44),
          ],
        ),
      ),
    );
  }
}

// ----------------------------- SEGMENTED CONTROL -----------------------------

class SegmentedPill extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.height,
    required this.borderRadius,
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  final double height;
  final double borderRadius;
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 16 / 13,
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryPurple, width: 1),
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.transparent,
        ),
        child: Row(
          children: List.generate(labels.length, (i) {
            final selected = i == selectedIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  color: selected ? AppColors.primaryPurple : Colors.transparent,
                  child: Text(
                    labels[i],
                    style: textStyle?.copyWith(
                      color: selected ? Colors.white : AppColors.primaryPurple,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ----------------------------- BASE CARD -----------------------------

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 12,
    this.backgroundColor = AppColors.white,
    this.shadowOpacity = 0.10,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color backgroundColor;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppTheme.cardShadow(opacity: shadowOpacity),
      ),
      child: child,
    );
  }
}

// ----------------------------- WARNING CARD -----------------------------

class WarningCard extends StatelessWidget {
  const WarningCard({
    super.key,
    required this.padding,
    required this.iconSize,
    required this.title,
    required this.body,
  });

  final EdgeInsets padding;
  final double iconSize;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      radius: 12,
      backgroundColor: AppColors.white,
      shadowOpacity: 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: CustomPaint(
                size: Size(iconSize, iconSize),
                painter: _WarningTrianglePainter(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final tri = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fill = Paint()..color = AppColors.warningYellow;
    canvas.drawPath(tri, fill);

    // Exclamation mark
    final exPaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = (w * 0.10).clamp(1.5, 3.2)
      ..strokeCap = StrokeCap.round;

    final cx = w / 2;
    final top = h * 0.32;
    final mid = h * 0.66;
    canvas.drawLine(Offset(cx, top), Offset(cx, mid), exPaint);

    final dotR = (w * 0.06).clamp(1.2, 2.6);
    canvas.drawCircle(Offset(cx, h * 0.80), dotR, Paint()..color = AppColors.textPrimary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------- QR CARD -----------------------------

class QrCard extends StatelessWidget {
  const QrCard({
    super.key,
    required this.padding,
    required this.qrSize,
    required this.shareButtonWidth,
    required this.shareButtonHeight,
    this.qrAssetPath,
    required this.onShare,
  });

  final EdgeInsets padding;
  final double qrSize;
  final double shareButtonWidth;
  final double shareButtonHeight;
  final String? qrAssetPath;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      radius: 12,
      backgroundColor: AppColors.white,
      shadowOpacity: 0.10,
      child: Column(
        children: [
          SizedBox(
            width: qrSize,
            height: qrSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: qrAssetPath != null
                    ? Image.asset(qrAssetPath!, fit: BoxFit.cover)
                    : CustomPaint(painter: _FakeQrPainter()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scan the QR code by printing out or displaying the\n'
            'code on another device to install your eSIM. Make\n'
            'sure your device has a stable internet connection\n'
            'before installing.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: shareButtonWidth,
            height: shareButtonHeight,
            child: OutlinedButton(
              onPressed: onShare,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.outlineGray, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                foregroundColor: AppColors.textSecondary,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'SHARE QR CODE',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Simple QR-like pattern placeholder (replace with real asset for exact match).
    final bg = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bg);

    final block = Paint()..color = Colors.black;
    final n = 21;
    final cell = size.width / n;

    bool finder(int x, int y) {
      // 7x7 finder patterns corners
      bool inTopLeft = x < 7 && y < 7;
      bool inTopRight = x >= n - 7 && y < 7;
      bool inBottomLeft = x < 7 && y >= n - 7;
      return inTopLeft || inTopRight || inBottomLeft;
    }

    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        final r = Rect.fromLTWH(x * cell, y * cell, cell, cell);

        if (finder(x, y)) {
          final fx = x % 7;
          final fy = y % 7;
          final border = fx == 0 || fx == 6 || fy == 0 || fy == 6;
          final inner = fx >= 2 && fx <= 4 && fy >= 2 && fy <= 4;
          if (border || inner) {
            canvas.drawRect(r, block);
          }
          continue;
        }

        // deterministic pseudo pattern
        final v = (x * 17 + y * 31 + x * y) % 7;
        if (v == 0 || v == 3 || v == 5) {
          canvas.drawRect(r, block);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ----------------------------- ACCORDION -----------------------------

class AccordionCard extends StatelessWidget {
  const AccordionCard({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 12,
      backgroundColor: AppColors.white,
      shadowOpacity: 0.10,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: SizedBox(
              height: 44,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 180),
                      turns: expanded ? 0.5 : 0.0,
                      child: const Icon(Icons.keyboard_arrow_down, size: 24, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeOut,
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: child,
          ),
        ],
      ),
    );
  }
}

// ----------------------------- ACCESS DATA INSET CARD -----------------------------

class AccessDataItem {
  const AccessDataItem({required this.label, required this.value});
  final String label;
  final String value;
}

class AccessDataInsetCard extends StatelessWidget {
  const AccessDataInsetCard({
    super.key,
    required this.items,
    required this.padding,
    required this.radius,
    required this.dividerColor,
  });

  final List<AccessDataItem> items;
  final EdgeInsets padding;
  final double radius;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.insetBg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppTheme.cardShadow(opacity: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (i != items.length - 1) ...[
                const SizedBox(height: 12),
                Divider(height: 1, thickness: 1, color: dividerColor),
                const SizedBox(height: 12),
              ],
            ],
          );
        }),
      ),
    );
  }
}

// ----------------------------- BOTTOM OVERLAY (OPTIONAL) -----------------------------

class _BottomOverlayBar extends StatelessWidget {
  const _BottomOverlayBar({required this.height, required this.radius});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.overlayDark,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _OverlaySquareIcon(
            icon: Icons.send,
            bg: const Color(0xFF1A73E8),
          ),
          const SizedBox(width: 12),
          _OverlayCircleIcon(icon: Icons.pan_tool_alt, size: 22),
          const SizedBox(width: 10),
          _OverlayCircleIcon(icon: Icons.circle_outlined, size: 22),
          const Spacer(),
          _OverlayAskButton(onTap: () {}),
        ],
      ),
    );
  }
}

class _OverlaySquareIcon extends StatelessWidget {
  const _OverlaySquareIcon({required this.icon, required this.bg});

  final IconData icon;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _OverlayCircleIcon extends StatelessWidget {
  const _OverlayCircleIcon({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}

class _OverlayAskButton extends StatelessWidget {
  const _OverlayAskButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A73E8),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Ask',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// ----------------------------- COPY TEXT (MATCHING SCREEN) -----------------------------

const String _installEsimText = '''
1. Go to Settings > Cellular/Mobile Data > Add eSIM or
   Set up Cellular/Mobile Service > Use QR code on your
   device.
2. Scan the QR code or take a screenshot (available
   on iOS 17.3), tap “Open Photos”, select it from your
   camera roll, tap “Next”.
3. Choose what label you like. Your eSIM will connect to
   the network, this may take a few minutes, then tap
   “Done”.
4. Choose a label for your new eSIM plan.
5. Choose “Primary” for your default line, then tap
   “Continue”.
6. Choose the “Primary” you want to use with iMessage
   and FaceTime for your Apple ID, then tap
   “Continue”.
6. Choose your new eSIM plan for cellular/mobile
   data, then tap “Continue”
''';

const String _accessDataText = '''
1. Go to “Cellular/Mobile Data”, then select the recently
   downloaded eSIM.
   This line’s toggle should be ON for
   cellular/mobile data.
2. Tap “Network”.
   Choose the “Zain” network (or set it from your
   eSIM’s line toggle).
3. Enable the “Data Roaming” toggle for your eSIM.
''';
