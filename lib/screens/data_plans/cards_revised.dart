import 'package:flutter/material.dart';
import 'package:tellgo_app/models/order_models.dart';

/// Pixel-spec implementation of the "eSIM usage cards" from the design.
///
/// Design tokens:
/// - Card background: #F4F4F5
/// - Screen background: #FCFCFC
/// - Primary purple: #85209C
/// - Track grey: #E1E2E1
/// - Divider lavender: #D8C4DF
/// - Pending dot: #F5E90C
/// - Active dot: #5CD340
/// - Buttons: fixed 122×35 (top) and 122×34 (bottom)
/// - Progress bar height: 8px, radius 4px

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════════════════

class CardColors {
  static const bg = Color(0xFFFCFCFC);
  static const card = Color(0xFFF4F4F5);
  static const primary = Color(0xFF85209C);
  static const track = Color(0xFFE1E2E1);
  static const dividerLavender = Color(0xFFD8C4DF);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF6B6B6B);
  static const buttonGrey = Color(0xFF6B6B6B);
  static const pendingDot = Color(0xFFF5E90C);
  static const activeDot = Color(0xFF5CD340);
  static const processingDot = Color(0xFF2196F3);
  static const cancelledDot = Color(0xFFED1C24);
  static const white = Color(0xFFFFFFFF);
  static const hairline = Color(0xFFE9E3EE);
}

class CardRadii {
  static const card = 16.0;
  static const button = 12.0;
  static const progress = 4.0;
}

const _kCardShadow = [
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 20,
      spreadRadius: 0,
      color: Color.fromRGBO(0, 0, 0, 0.08),
    ),
  ];

class _T {
  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 16 / 13,
    color: CardColors.textSecondary,
  );

  static const valueBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 18 / 14,
    color: CardColors.textPrimary,
  );

  static const editLink = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 14 / 12,
    color: CardColors.textSecondary,
    letterSpacing: 0.2,
  );

  static const statusText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 18 / 14,
    color: CardColors.textPrimary,
  );

  static const sectionLeft = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 18 / 14,
    color: CardColors.textPrimary,
  );

  static const sectionRight = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 18 / 14,
    color: CardColors.textPrimary,
  );

  static const buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 18 / 14,
    color: CardColors.white,
  );

  static const statTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 18 / 14,
    color: CardColors.textPrimary,
  );

  static const statValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 26 / 22,
    color: CardColors.textPrimary,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATUS HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

enum _CardStatus { pending, active, processing, cancelled, expired }

_CardStatus _resolveStatus(String? rawStatus) {
  switch (rawStatus) {
    case '1':
      return _CardStatus.pending;
    case '2':
      return _CardStatus.processing;
    case '3':
      return _CardStatus.active;
    case '4':
      return _CardStatus.cancelled;
    case '5':
      return _CardStatus.expired;
    default:
      return _CardStatus.pending;
  }
}

Color _statusDotColor(_CardStatus s) {
  switch (s) {
    case _CardStatus.pending:
      return CardColors.pendingDot;
    case _CardStatus.active:
      return CardColors.activeDot;
    case _CardStatus.processing:
      return CardColors.processingDot;
    case _CardStatus.cancelled:
    case _CardStatus.expired:
      return CardColors.cancelledDot;
  }
}

String _statusLabel(_CardStatus s) {
  switch (s) {
    case _CardStatus.pending:
      return 'Pending';
    case _CardStatus.active:
      return 'Active';
    case _CardStatus.processing:
      return 'Processing';
    case _CardStatus.cancelled:
      return 'Cancelled';
    case _CardStatus.expired:
      return 'Expired';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESCRIPTION PARSERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Parse coverage from description like "eSIM, 5GB, 30 Days, Africa, V2"
String _parseCoverage(String? desc) {
  if (desc == null || desc.isEmpty) return 'N/A';
  final parts = desc.split(',').map((e) => e.trim()).toList();
  return parts.length >= 4 ? parts[3] : 'N/A';
}

/// Parse data plan from description: "5GB / 30 Days"
String _parseDataPlan(String? desc, String? fallback) {
  if (desc == null || desc.isEmpty) return fallback ?? 'N/A';
  final parts = desc.split(',').map((e) => e.trim()).toList();
  return parts.length >= 3 ? '${parts[1]} / ${parts[2]}' : desc;
}

/// Parse data size from description for remaining internet: "2GB"
String _parseDataSize(String? desc) {
  if (desc == null || desc.isEmpty) return 'N/A';
  final parts = desc.split(',').map((e) => e.trim()).toList();
  return parts.length >= 2 ? parts[1] : 'N/A';
}

// ═══════════════════════════════════════════════════════════════════════════════
// ESIM USAGE CARD — main public widget
// ═══════════════════════════════════════════════════════════════════════════════

class EsimUsageCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onEdit;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final VoidCallback? onTapDetails;

  const EsimUsageCard({
    super.key,
    required this.order,
    this.onEdit,
    this.onPrimary,
    this.onSecondary,
    this.onTapDetails,
  });

  _CardStatus get _status => _resolveStatus(order.status);
  bool get _isPending => _status == _CardStatus.pending;
  bool get _isActive => _status == _CardStatus.active;

  // Button configuration based on status
  String get _primaryButtonText => 'Activate';
  Color get _primaryButtonColor =>
      _isPending ? CardColors.primary : CardColors.buttonGrey;

  String get _secondaryButtonText =>
      _isActive ? 'Top Up' : 'Share eSIM';
  Color get _secondaryButtonColor => CardColors.primary;

  // Remaining internet display
  String get _remainingText {
    final dataSize = _parseDataSize(order.description);
    if (dataSize == 'N/A') return 'N/A';
    return '$dataSize of $dataSize'; // Full by default; real usage API would update this
  }

  double get _remainingRatio => 1.0; // Default full; update when usage API is available

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CardColors.card,
        borderRadius: BorderRadius.circular(CardRadii.card),
        boxShadow: _kCardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP SECTION: info (left) + status/buttons (right) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoTable(
                  name: order.customerName ?? 'N/A',
                  iccid: order.iccid ?? '–',
                  coverage: _parseCoverage(order.description),
                  dataPlan: _parseDataPlan(order.description, order.title),
                  mobileNo: order.msisdn ?? order.mobileNumber ?? '–',
                  onEdit: onEdit,
                ),
              ),
              const SizedBox(width: 16),
              _RightActions(
                statusDot: _statusDotColor(_status),
                statusText: _statusLabel(_status),
                primaryText: _primaryButtonText,
                primaryColor: _primaryButtonColor,
                secondaryText: _secondaryButtonText,
                secondaryColor: _secondaryButtonColor,
                onPrimary: onPrimary ?? () {},
                onSecondary: onSecondary ?? () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── HAIRLINE DIVIDER ──
          Container(height: 1, color: CardColors.hairline),

          const SizedBox(height: 12),

          // ── Remaining Internet row ──
          Row(
            children: [
              const Text('Remaing Internet', style: _T.sectionLeft),
              const Spacer(),
              Text(_remainingText, style: _T.sectionRight),
            ],
          ),

          const SizedBox(height: 8),

          // ── Progress bar (height 8px, radius 4px) ──
          _ProgressBar(
            height: 8,
            radius: CardRadii.progress,
            trackColor: CardColors.track,
            fillColor: CardColors.primary,
            value: _remainingRatio,
          ),

          const SizedBox(height: 16),

          // ── Stats (3 columns + 2 vertical dividers) ──
          const _StatsRow(
            localCallsValue: '–',
            intlCallsValue: '0',
            messagesValue: '–',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEFT INFO TABLE (5 label/value rows)
// ═══════════════════════════════════════════════════════════════════════════════

class _InfoTable extends StatelessWidget {
  final String name;
  final String iccid;
  final String coverage;
  final String dataPlan;
  final String mobileNo;
  final VoidCallback? onEdit;

  const _InfoTable({
    required this.name,
    required this.iccid,
    required this.coverage,
    required this.dataPlan,
    required this.mobileNo,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    const labelW = 76.0;
    const rowGap = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name row with EDIT
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: labelW,
              child: Text('Name', style: _T.label),
            ),
            Expanded(
              child: Text(
                name,
                style: _T.valueBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit_outlined,
                        size: 14, color: CardColors.textSecondary),
                    SizedBox(width: 4),
                    Text('EDIT', style: _T.editLink),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: rowGap),
        _kvRow(labelW, 'ICCID', iccid),
        const SizedBox(height: rowGap),
        _kvRow(labelW, 'COVERAGE', coverage),
        const SizedBox(height: rowGap),
        _kvRow(labelW, 'Data', dataPlan),
        const SizedBox(height: rowGap),
        _kvRow(labelW, 'Mobile No.', mobileNo),
      ],
    );
  }

  static Widget _kvRow(double labelW, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: labelW, child: Text(label, style: _T.label)),
        Expanded(
          child: Text(
            value,
            style: _T.valueBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RIGHT SIDE: status dot + 2 action buttons
// ═══════════════════════════════════════════════════════════════════════════════

class _RightActions extends StatelessWidget {
  final Color statusDot;
  final String statusText;
  final String primaryText;
  final Color primaryColor;
  final String secondaryText;
  final Color secondaryColor;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const _RightActions({
    required this.statusDot,
    required this.statusText,
    required this.primaryText,
    required this.primaryColor,
    required this.secondaryText,
    required this.secondaryColor,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 122, // fixed width matches screenshot buttons
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // status row (dot 8px + gap 10px)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusDot,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(statusText, style: _T.statusText),
            ],
          ),
          const SizedBox(height: 12),

          // Primary button: 122×35
          _FixedButton(
            width: 122,
            height: 35,
            radius: CardRadii.button,
            color: primaryColor,
            text: primaryText,
            onTap: onPrimary,
          ),
          const SizedBox(height: 10),

          // Secondary button: 122×34
          _FixedButton(
            width: 122,
            height: 34,
            radius: CardRadii.button,
            color: secondaryColor,
            text: secondaryText,
            onTap: onSecondary,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FIXED-SIZE BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _FixedButton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;
  final String text;
  final VoidCallback onTap;

  const _FixedButton({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Center(
            child: Text(
              text,
              style: _T.buttonText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROGRESS BAR (8px tall, rounded ends)
// ═══════════════════════════════════════════════════════════════════════════════

class _ProgressBar extends StatelessWidget {
  final double height;
  final double radius;
  final Color trackColor;
  final Color fillColor;
  final double value; // 0..1

  const _ProgressBar({
    required this.height,
    required this.radius,
    required this.trackColor,
    required this.fillColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final fillW = w * v;

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: trackColor)),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: fillW,
                  child: ColoredBox(color: fillColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATS ROW (3 equal columns + 2 vertical dividers)
// ═══════════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final String localCallsValue;
  final String intlCallsValue;
  final String messagesValue;

  const _StatsRow({
    required this.localCallsValue,
    required this.intlCallsValue,
    required this.messagesValue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCol(
              title: 'Local Calls',
              value: localCallsValue,
              titleMaxLines: 1,
            ),
          ),
          _VStatDivider(),
          Expanded(
            child: _StatCol(
              title: 'international\nCalls',
              value: intlCallsValue,
              titleMaxLines: 2,
            ),
          ),
          _VStatDivider(),
          Expanded(
            child: _StatCol(
              title: 'Messages',
              value: messagesValue,
              titleMaxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String title;
  final String value;
  final int titleMaxLines;

  const _StatCol({
    required this.title,
    required this.value,
    required this.titleMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: _T.statTitle,
          textAlign: TextAlign.center,
          maxLines: titleMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 18),
        Text(
          value,
          style: _T.statValue,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _VStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: CardColors.dividerLavender,
    );
  }
}
