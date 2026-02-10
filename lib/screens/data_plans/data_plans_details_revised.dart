import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/models/order_models.dart';
import 'package:tellgo_app/repository/order_repository.dart';
import 'package:tellgo_app/screens/orders/bloc/orders_bloc.dart';
import 'package:tellgo_app/screens/orders/bloc/orders_event.dart';
import 'package:tellgo_app/screens/orders/bloc/orders_state.dart';
import 'package:tellgo_app/screens/profile/user_header.dart';

// =============================================================================
// DESIGN TOKENS (Mini Design System)
// =============================================================================

class _C {
  // Surfaces
  static const pageBg = Color(0xFFF5F6F8);
  static const surface = Color(0xFFFFFFFF);

  // Brand
  static const primary = Color(0xFF7652A2);
  static const primaryOutline = Color(0xFFCDBCE6);

  // Text
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textInverse = Color(0xFFFFFFFF);

  // Borders / Dividers
  static const dividerGray = Color(0xFFDADADA);

  // Status dots
  static const pendingDot = Color(0xFFF2C200);
  static const activeDot = Color(0xFF4CAF50);
  static const processingDot = Color(0xFF2196F3);
  static const cancelledDot = Color(0xFFED1C24);

  // Misc
  static const darkButton = Color(0xFF3F3F3F);
  static const progressTrack = Color(0xFFE7E7E7);
  static const iconMuted = Color(0xFFB0B0B0);
}

class _R {
  static const r16 = 16.0;
  static const r12 = 12.0;
  static const r10 = 10.0;
  static const r999 = 999.0;
}

const _cardShadow = BoxShadow(
  color: Color(0x1F000000), // ~12% black
  offset: Offset(0, 6),
  blurRadius: 16,
  spreadRadius: 0,
);

// =============================================================================
// SCREEN ENTRY POINT
// =============================================================================

class EsimDetailsScreen extends StatelessWidget {
  final String orderId;
  final String? orderTitle;

  const EsimDetailsScreen({
    super.key,
    required this.orderId,
    this.orderTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersBloc(
        orderRepository: OrderRepositoryImpl(AppDio()),
      )..add(LoadOrderDetails(orderId: orderId)),
      child: _ScreenShell(orderId: orderId, orderTitle: orderTitle),
    );
  }
}

class _ScreenShell extends StatelessWidget {
  final String orderId;
  final String? orderTitle;

  const _ScreenShell({required this.orderId, this.orderTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (reusable app header) ──
            const CommonAppHeader(
              notificationCount: 3,
              includeSafeAreaTop: false,
              showDivider: false,
        ),

            // ── Body ──
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrderDetailsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: _C.primary),
                    );
                  }
                  if (state is OrderDetailsLoaded) {
                    return _LoadedBody(
                      details: state.orderDetails,
                      orderId: orderId,
                    );
                  }
                  if (state is OrderDetailsError) {
                    return _ErrorBody(
                      message: state.message,
                      onRetry: () => context
                          .read<OrdersBloc>()
                          .add(LoadOrderDetails(orderId: orderId)),
                    );
                  }
                  // Initial / other
                  return const Center(
                    child: CircularProgressIndicator(color: _C.primary),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ERROR BODY
// =============================================================================

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48,
                color: _C.cancelledDot.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            const Text(
              'Failed to load order details',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _C.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48, width: 160,
              child: Material(
                color: _C.primary,
                borderRadius: BorderRadius.circular(_R.r12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(_R.r12),
                  onTap: onRetry,
                  child: const Center(
                    child: Text('Retry',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                            color: _C.textInverse)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LOADED BODY – scrollable content
// =============================================================================

class _LoadedBody extends StatelessWidget {
  final OrderDetails details;
  final String orderId;

  const _LoadedBody({required this.details, required this.orderId});

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _parseCoverage(String? desc) {
    if (desc == null || desc.isEmpty) return 'N/A';
    final parts = desc.split(',').map((e) => e.trim()).toList();
    return parts.length >= 4 ? parts[3] : 'N/A';
  }

  String _parseDataPlan(String? desc, String? fallback) {
    if (desc == null || desc.isEmpty) return fallback ?? 'N/A';
    final parts = desc.split(',').map((e) => e.trim()).toList();
    return parts.length >= 3 ? '${parts[1]} / ${parts[2]}' : desc;
  }

  String get _displayTitle {
    if (details.items.isNotEmpty) {
      final n = details.items.first.name;
      if (n != null && n.isNotEmpty) return n;
    }
    return 'eSIM Order #${details.orderNumber ?? orderId}';
  }

  OrderItem? get _primaryItem =>
      details.items.isNotEmpty ? details.items.first : null;

  bool get _hasEsimData => details.items.any((i) =>
      i.iccid != null ||
      i.smdpAddress != null ||
      i.matchingId != null ||
      i.qrCodeURL != null ||
      i.appleInstallUrl != null);

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final hPad = screenW < 360 ? 16.0 : 24.0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
                child: Center(
                  child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1) Order Summary Card ──
                _OrderSummaryCard(
                  title: _displayTitle,
                  status: details.status,
                  statusLabel: details.statusLabel ?? 'Unknown',
                  orderIdValue: details.orderNumber ?? orderId,
                  iccid: _primaryItem?.iccid,
                  coverage: _parseCoverage(_primaryItem?.description),
                ),
                const SizedBox(height: 20),

                // ── 2+3+4) eSIM Installation section ──
                if (_hasEsimData) ...[
                  const _SectionTitle(text: 'eSIM Installation'),
                  const SizedBox(height: 12),
                  _PrimaryButton(
                    text: 'Direct Install eSIM',
                    onPressed: () {/* TODO */},
                  ),
                  const SizedBox(height: 12),
                  _PrimaryButton(
                    text: 'Activate by QR code',
                    onPressed: () {/* TODO */},
                  ),
                  const SizedBox(height: 20),
                ],

                // ── 5) eSIM Detail Card(s) ──
                ...details.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _EsimDetailCard(
                        item: item,
                        customerName: details.customerName,
                        status: details.status,
                        statusLabel: details.statusLabel,
                        coverage: _parseCoverage(item.description),
                        dataPlan: _parseDataPlan(item.description, item.name),
                      ),
                    )),

                // ── 6) Details Card ──
                const _DetailsCard(),
                const SizedBox(height: 20),

                // ── 7) Top Up button (centered, not full width) ──
                const _CenteredTopUpButton(),

                // Extra padding at bottom
                const SizedBox(height: 24),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

// =============================================================================
// COMMON CARD SHELL (white, 16px radius, shadow)
// =============================================================================

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
        color: _C.surface,
        borderRadius: BorderRadius.circular(_R.r16),
        boxShadow: const [_cardShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_R.r16),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

// =============================================================================
// 1) ORDER SUMMARY CARD
// =============================================================================

class _OrderSummaryCard extends StatelessWidget {
  final String title;
  final String? status;
  final String statusLabel;
  final String orderIdValue;
  final String? iccid;
  final String coverage;

  const _OrderSummaryCard({
    required this.title,
    required this.status,
    required this.statusLabel,
    required this.orderIdValue,
    this.iccid,
    required this.coverage,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    height: 28 / 22, letterSpacing: -0.2,
                    color: _C.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _StatusDot(status: status, label: statusLabel),
            ],
          ),
          const SizedBox(height: 16),

          // ORDER ID (caps label)
          _CapsLabelValue(label: 'ORDER ID', value: orderIdValue, copyable: true),
          const SizedBox(height: 16),

          // ICCID NUMBER
          if (iccid != null && iccid!.isNotEmpty) ...[
            _CapsLabelValue(
            label: 'ICCID NUMBER',
              value: iccid!,
              copyable: true,
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          ],

          // COVERAGE
          _CapsLabelValue(label: 'COVERAGE', value: coverage),
        ],
      ),
    );
  }
}

// =============================================================================
// STATUS DOT + LABEL (reused in multiple cards)
// =============================================================================

class _StatusDot extends StatelessWidget {
  final String? status;
  final String label;

  const _StatusDot({required this.status, required this.label});

  Color get _color {
    switch (status) {
      case '1': return _C.pendingDot;
      case '2': return _C.processingDot;
      case '3': return _C.activeDot;
      case '4': return _C.cancelledDot;
      case '5': return _C.cancelledDot;
      default:  return _C.pendingDot;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            height: 20 / 14, color: _C.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CAPS LABEL + VALUE (Order ID, ICCID, COVERAGE)
// =============================================================================

class _CapsLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final int maxLines;

  const _CapsLabelValue({
    required this.label,
    required this.value,
    this.copyable = false,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                height: 16 / 12, letterSpacing: 0.4,
                color: _C.textPrimary,
              ),
            ),
            if (copyable) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied: $value'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: _C.primary,
                    ),
                  );
                },
                child: const Icon(Icons.copy, size: 16, color: _C.iconMuted),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            height: 20 / 14, color: _C.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 2) SECTION TITLE
// =============================================================================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w800,
        height: 28 / 22, letterSpacing: -0.2,
        color: _C.textPrimary,
          ),
    );
  }
}

// =============================================================================
// 3 + 4) PRIMARY PURPLE BUTTONS (full width, 56px height, 12px radius)
// =============================================================================

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const _PrimaryButton({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: _C.primary,
        borderRadius: BorderRadius.circular(_R.r12),
        child: InkWell(
          borderRadius: BorderRadius.circular(_R.r12),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                height: 24 / 18, color: _C.textInverse,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 5) ESIM DETAIL CARD
//    ─ Name row + EDIT + Status
//    ─ Left detail rows (ICCID, Coverage, Data, Mobile No.)
//    ─ Right action buttons (Activate, Share eSIM)
//    ─ Divider
//    ─ Remaining Internet + progress bar
//    ─ 3-column metrics (Local Calls / Int'l Calls / Messages)
// =============================================================================

class _EsimDetailCard extends StatelessWidget {
  final OrderItem item;
  final String? customerName;
  final String? status;
  final String? statusLabel;
  final String coverage;
  final String dataPlan;

  const _EsimDetailCard({
    required this.item,
    this.customerName,
    this.status,
    this.statusLabel,
    required this.coverage,
    required this.dataPlan,
  });

  String get _statusText => statusLabel ?? 'Unknown';
  bool get _isPending => status == '1';

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: Name | EDIT | Status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  height: 18 / 13, color: _C.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customerName ?? 'N/A',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    height: 20 / 14, color: _C.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // EDIT button
              GestureDetector(
                onTap: () {/* TODO: open name edit */},
                child: Row(
                mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit, size: 16, color: _C.textSecondary),
                    SizedBox(width: 6),
                  Text(
                    'EDIT',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        letterSpacing: 0.3, color: _C.textSecondary,
                    ),
                  ),
                ],
                ),
              ),
              const SizedBox(width: 14),
              _StatusDot(status: status, label: _statusText),
            ],
          ),
          const SizedBox(height: 12),

          // ── Detail rows (left) + Action buttons (right) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column – details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.iccid != null) ...[
                      _InlineRow(label: 'ICCID', value: item.iccid!, maxLines: 2),
                      const SizedBox(height: 8),
                    ],
                    _InlineRow(label: 'COVERAGE', value: coverage),
                    const SizedBox(height: 8),
                    _InlineRow(label: 'Data', value: dataPlan),
                    const SizedBox(height: 8),
                    _InlineRow(
                      label: 'Mobile No.',
                      value: item.iccid != null
                          ? '–' // placeholder; API doesn't provide msisdn on items
                          : '–',
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right column – action buttons (fixed width)
              SizedBox(
                width: 132,
                child: Column(
                  children: [
                    _SmallPurpleButton(
                      text: _isPending ? 'Activate' : 'Activate',
                      onPressed: () {/* TODO: activate action */},
                    ),
                    const SizedBox(height: 12),
                    _SmallPurpleButton(
                      text: 'Share eSIM',
                      onPressed: () {/* TODO: share action */},
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── SM-DP+ / Matching ID (if available) ──
          if (item.smdpAddress != null || item.matchingId != null) ...[
            const SizedBox(height: 12),
            const _HorizontalRule(),
            const SizedBox(height: 12),
            if (item.smdpAddress != null)
              _InlineRow(label: 'SM-DP+', value: item.smdpAddress!, maxLines: 2, copyable: true),
            if (item.smdpAddress != null && item.matchingId != null)
              const SizedBox(height: 8),
            if (item.matchingId != null)
              _InlineRow(label: 'Matching ID', value: item.matchingId!, maxLines: 2, copyable: true),
          ],

          const SizedBox(height: 14),
          const _HorizontalRule(),
          const SizedBox(height: 12),

          // ── Remaining Internet row ──
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Remaing Internet',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    height: 20 / 14, color: _C.textPrimary,
                  ),
                ),
              ),
              Text(
                _remainingInternetText,
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  height: 20 / 14, color: _C.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Progress bar ──
          _ProgressBar(value: _progressValue),

          const SizedBox(height: 14),
          const _HorizontalRule(),
          const SizedBox(height: 12),

          // ── 3-column metrics row ──
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _MetricBlock(label: 'Local Calls', value: _localCallsText)),
                const _VerticalDividerThin(),
                Expanded(child: _MetricBlock(label: 'international\nCalls', value: _intlCallsText)),
                const _VerticalDividerThin(),
                Expanded(child: _MetricBlock(label: 'Messages', value: _messagesText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Data extraction helpers (best-effort from API) ──

  /// Attempts to extract remaining data from description/usage
  String get _remainingInternetText {
    // Try to parse data size from description: "eSIM, 2GB, 7 Days, Egypt, V1"
    final desc = item.description;
    if (desc != null && desc.isNotEmpty) {
      final parts = desc.split(',').map((e) => e.trim()).toList();
      if (parts.length >= 2) {
        final dataSize = parts[1]; // e.g. "2GB"
        return '$dataSize of $dataSize'; // Assumes full if no usage API
      }
    }
    return 'N/A';
  }

  double get _progressValue {
    // Default to near-full since we don't have consumed data from API
    return 0.98;
  }

  String get _localCallsText => '–';
  String get _intlCallsText => '0';
  String get _messagesText => '–';

}

// =============================================================================
// INLINE DETAIL ROW (label | value) – used inside eSIM Detail Card
// =============================================================================

class _InlineRow extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;
  final bool copyable;

  const _InlineRow({
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              height: 18 / 13, color: _C.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              height: 20 / 14, color: _C.textPrimary,
          ),
        ),
        ),
        if (copyable) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied $label'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: _C.primary,
                ),
              );
            },
            child: const Icon(Icons.copy, size: 14, color: _C.iconMuted),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// SMALL PURPLE BUTTON (120–132px wide, 38px tall, 12px radius)
// =============================================================================

class _SmallPurpleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const _SmallPurpleButton({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      width: double.infinity,
      child: Material(
        color: _C.primary,
        borderRadius: BorderRadius.circular(_R.r12),
        child: InkWell(
          borderRadius: BorderRadius.circular(_R.r12),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                height: 20 / 14, color: _C.textInverse,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PROGRESS BAR (8px height, fully rounded, purple fill on gray track)
// =============================================================================

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: _C.progressTrack,
        borderRadius: BorderRadius.circular(_R.r999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(_R.r999),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HORIZONTAL RULE (1px, dividerGray)
// =============================================================================

class _HorizontalRule extends StatelessWidget {
  const _HorizontalRule();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: _C.dividerGray);
  }
}

// =============================================================================
// VERTICAL DIVIDER (1px, primaryOutline, full metric row height)
// =============================================================================

class _VerticalDividerThin extends StatelessWidget {
  const _VerticalDividerThin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: _C.primaryOutline,
    );
  }
}

// =============================================================================
// METRIC BLOCK (label 14/600 + value 22/800)
// =============================================================================

class _MetricBlock extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            height: 20 / 14, color: _C.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800,
            height: 28 / 22, color: _C.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 6) DETAILS CARD
//    ─ "Details" title
//    ─ 1px divider
//    ─ "Additional Information" centered
//    ─ Dark gray button "More details about my eSIM"
// =============================================================================

class _DetailsCard extends StatelessWidget {
  const _DetailsCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800,
              height: 22 / 16, color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const _HorizontalRule(),
          const SizedBox(height: 16),

          // Centered label
          const Center(
            child: Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dark gray button
          Center(
            child: SizedBox(
              height: 42,
              width: 250,
              child: Material(
                color: _C.darkButton,
                borderRadius: BorderRadius.circular(_R.r10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(_R.r10),
                  onTap: () {/* TODO: navigate to more eSIM details */},
                  child: const Center(
                    child: Text(
                      'More details about my eSIM',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        height: 16 / 12, color: _C.textInverse,
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

// =============================================================================
// 7) CENTERED TOP UP BUTTON (not full width, ~296px, 56px, 12px radius)
// =============================================================================

class _CenteredTopUpButton extends StatelessWidget {
  const _CenteredTopUpButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 296,
        height: 56,
        child: Material(
          color: _C.primary,
          borderRadius: BorderRadius.circular(_R.r12),
          child: InkWell(
            borderRadius: BorderRadius.circular(_R.r12),
            onTap: () {/* TODO: navigate to Top Up flow */},
            child: const Center(
              child: Text(
                'Top Up',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  height: 24 / 18, color: _C.textInverse,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
