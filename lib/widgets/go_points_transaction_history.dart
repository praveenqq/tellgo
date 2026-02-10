import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable transaction history section widget for Go Points screen.
/// Displays an accordion header and a scrollable list of transactions.
class GoPointsTransactionHistory extends StatefulWidget {
  const GoPointsTransactionHistory({
    super.key,
    required this.transactions,
    required this.scale,
    this.sidePadding = 66.0, // Base pixel value (will be scaled)
    this.scrollRailWidth = 65.0, // Base pixel value (will be scaled)
    this.trackLeftInset = 20.0, // Base pixel value (will be scaled)
    this.trackWidth = 7.0, // Base pixel value (will be scaled)
    this.initialExpanded = true,
    this.emptyMessage,
  });

  final List<TransactionItem> transactions;
  final double scale;
  final double sidePadding;
  final double scrollRailWidth;
  final double trackLeftInset;
  final double trackWidth;
  final bool initialExpanded;
  final String? emptyMessage;

  double s(double px) => px * scale;

  @override
  State<GoPointsTransactionHistory> createState() =>
      _GoPointsTransactionHistoryState();
}

class _GoPointsTransactionHistoryState
    extends State<GoPointsTransactionHistory> {
  final ScrollController _scrollController = ScrollController();
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double s(double px) => px * widget.scale;

  double _clampDouble(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  String _formatPoints(int delta) {
    if (delta > 0) return '+$delta Points';
    return '$delta Points';
  }

  @override
  Widget build(BuildContext context) {
    // Colors
    const primaryPurple = Color(0xFF832D9F);
    const borderLavender = Color(0xFFE1CCE6);
    const textSecondary = Color(0xFF7E7F7F);
    const successGreen = Color(0xFF00C75F);
    const errorRed = Color(0xFFFA0040);
    const scrollTrack = Color(0xFFEBEBEB);

    // Scale and clamp padding values (matching go_points_screen pattern)
    final sidePad = _clampDouble(s(widget.sidePadding), s(24), s(70));
    final scrollRailW = s(widget.scrollRailWidth);
    final trackLeftInset = s(widget.trackLeftInset);
    final trackW = s(widget.trackWidth);

    final cta = TextStyle(
      fontSize: s(14),
      fontWeight: FontWeight.w600,
      height: 18 / 14,
      color: Colors.white,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we have a constrained height
        final hasConstrainedHeight = constraints.maxHeight != double.infinity;
        final availableHeight = constraints.maxHeight;
        
        // Calculate minimum required height: pill + minimal padding
        final pillHeight = s(41);
        final minPadding = s(2); // Minimal padding to prevent overflow
        
        // Dynamically adjust padding based on available space
        double topPadding;
        double bottomPadding;
        
        if (hasConstrainedHeight) {
          // Calculate how much space we have for padding
          final spaceForPadding = availableHeight - pillHeight;
          
          if (spaceForPadding < minPadding * 2) {
            // Extremely constrained: use absolute minimum
            topPadding = minPadding;
            bottomPadding = minPadding;
          } else if (spaceForPadding < s(20)) {
            // Very constrained: distribute available space
            topPadding = (spaceForPadding * 0.6).clamp(minPadding, s(10));
            bottomPadding = (spaceForPadding * 0.4).clamp(minPadding, s(6));
          } else if (spaceForPadding < s(100)) {
            // Moderately constrained: reduce padding
            topPadding = s(10);
            bottomPadding = s(6);
          } else {
            // Normal padding
            topPadding = s(60);
            bottomPadding = s(11);
          }
          
          // Final check: ensure total doesn't exceed available height
          final totalHeight = pillHeight + topPadding + bottomPadding;
          if (totalHeight > availableHeight) {
            final excess = totalHeight - availableHeight;
            // Reduce padding proportionally
            final topRatio = topPadding / (topPadding + bottomPadding);
            topPadding = (topPadding - excess * topRatio).clamp(minPadding, topPadding);
            bottomPadding = (bottomPadding - excess * (1 - topRatio)).clamp(minPadding, bottomPadding);
          }
        } else {
          // Normal padding when not constrained
          topPadding = s(60);
          bottomPadding = s(11);
        }

        return Column(
          mainAxisSize: hasConstrainedHeight ? MainAxisSize.min : MainAxisSize.max,
          children: [
            // Transaction History pill
            Padding(
              padding: EdgeInsets.only(
                left: _clampDouble(s(71), s(24), s(80)),
                right: _clampDouble(s(68), s(24), s(80)),
                top: topPadding,
                bottom: bottomPadding,
              ),
              child: _AccordionPill(
                height: pillHeight,
                radius: s(12),
                color: primaryPurple,
                text: 'Transaction History',
                textStyle: cta,
                expanded: _expanded,
                onTap: () => setState(() => _expanded = !_expanded),
                chevronSize: s(20),
                chevronRightPad: s(16),
              ),
            ),

            // List area (expanded)
            if (_expanded)
              widget.transactions.isEmpty
                  ? _buildEmptyState(hasConstrainedHeight, textSecondary)
                  : _buildTransactionList(
                      hasConstrainedHeight: hasConstrainedHeight,
                      sidePad: sidePad,
                      scrollRailW: scrollRailW,
                      trackLeftInset: trackLeftInset,
                      trackW: trackW,
                      borderLavender: borderLavender,
                      successGreen: successGreen,
                      errorRed: errorRed,
                      textSecondary: textSecondary,
                      primaryPurple: primaryPurple,
                      scrollTrack: scrollTrack,
                    )
            else
              const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(bool hasConstrainedHeight, Color textSecondary) {
    final emptyWidget = Center(
      child: Padding(
        padding: EdgeInsets.all(s(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: s(48),
              color: textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: s(16)),
            Text(
              widget.emptyMessage ?? 'No transactions yet',
              style: TextStyle(
                fontSize: s(14),
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    return hasConstrainedHeight
        ? Flexible(child: emptyWidget)
        : Expanded(child: emptyWidget);
  }

  Widget _buildTransactionList({
    required bool hasConstrainedHeight,
    required double sidePad,
    required double scrollRailW,
    required double trackLeftInset,
    required double trackW,
    required Color borderLavender,
    required Color successGreen,
    required Color errorRed,
    required Color textSecondary,
    required Color primaryPurple,
    required Color scrollTrack,
  }) {
    double s(double px) => px * widget.scale;

    final listWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cards list area
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: sidePad,
              right: 0, // important: cards end before the rail
              bottom: s(24),
            ),
            itemCount: widget.transactions.length,
            separatorBuilder: (_, __) => SizedBox(height: s(11)),
            itemBuilder: (context, index) {
              final t = widget.transactions[index];
              final isEarn = t.pointsDelta > 0;
              final circleColor = isEarn ? successGreen : errorRed;
              final icon = isEarn
                  ? Icons.arrow_upward
                  : Icons.arrow_downward;

              return _TransactionCard(
                borderColor: borderLavender,
                radius: s(12),
                minHeight: s(52),
                leftCircleSize: s(32),
                leftCircleColor: circleColor,
                leftIcon: icon,
                leftIconSize: s(18),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: s(11),
                  vertical: s(8),
                ),
                gapAfterIcon: s(12),
                title: t.title,
                time: t.time,
                pointsLabel: _formatPoints(t.pointsDelta),
                titleStyle: TextStyle(
                  fontSize: s(13),
                  fontWeight: FontWeight.w600,
                  height: 18 / 13,
                  color: Colors.black,
                ),
                timeStyle: TextStyle(
                  fontSize: s(11),
                  fontWeight: FontWeight.w400,
                  height: 16 / 11,
                  color: textSecondary,
                ),
                pointsStyle: TextStyle(
                  fontSize: s(12),
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: const Color(0xFF5A5A5A),
                ),
                rightTopPad: s(2),
                iconTopPad: s(2),
                leftPadding: s(8),
                textGap: s(2),
              );
            },
          ),
        ),

        // Custom rail area to match screenshot inset scrollbar positioning
        SizedBox(
          width: scrollRailW,
          child: Padding(
            padding: EdgeInsets.only(left: trackLeftInset),
            child: _InsetScrollbar(
              controller: _scrollController,
              trackWidth: trackW,
              trackColor: scrollTrack,
              thumbColor: primaryPurple,
              minThumbExtent: s(48),
              radius: trackW / 2,
            ),
          ),
        ),
      ],
    );

    return hasConstrainedHeight
        ? Flexible(child: listWidget)
        : Expanded(child: listWidget);
  }
}

/// Purple pill header with centered label and right chevron, like an accordion header.
class _AccordionPill extends StatelessWidget {
  const _AccordionPill({
    required this.height,
    required this.radius,
    required this.color,
    required this.text,
    required this.textStyle,
    required this.expanded,
    required this.onTap,
    required this.chevronSize,
    required this.chevronRightPad,
  });

  final double height;
  final double radius;
  final Color color;
  final String text;
  final TextStyle textStyle;
  final bool expanded;
  final VoidCallback onTap;
  final double chevronSize;
  final double chevronRightPad;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(child: Text(text, style: textStyle)),
              Positioned(
                right: chevronRightPad,
                child: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: chevronSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.borderColor,
    required this.radius,
    required this.minHeight,
    required this.leftCircleSize,
    required this.leftCircleColor,
    required this.leftIcon,
    required this.leftIconSize,
    required this.contentPadding,
    required this.gapAfterIcon,
    required this.title,
    required this.time,
    required this.pointsLabel,
    required this.titleStyle,
    required this.timeStyle,
    required this.pointsStyle,
    required this.rightTopPad,
    required this.iconTopPad,
    required this.leftPadding,
    required this.textGap,
  });

  final Color borderColor;
  final double radius;
  final double minHeight;

  final double leftCircleSize;
  final Color leftCircleColor;
  final IconData leftIcon;
  final double leftIconSize;

  final EdgeInsets contentPadding;
  final double gapAfterIcon;

  final String title;
  final String time;
  final String pointsLabel;

  final TextStyle titleStyle;
  final TextStyle timeStyle;
  final TextStyle pointsStyle;

  final double rightTopPad;
  final double iconTopPad;
  final double leftPadding;
  final double textGap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8), // Light gray background matching wallet screen cards
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: contentPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Padding(
              padding: EdgeInsets.only(top: iconTopPad),
              child: Container(
                width: leftCircleSize,
                height: leftCircleSize,
                decoration: BoxDecoration(
                  color: leftCircleColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(leftIcon, color: Colors.white, size: leftIconSize),
              ),
            ),

            SizedBox(width: gapAfterIcon),

            // Middle text column
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: textGap),
                    Text(
                      time,
                      style: timeStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Right points label aligned to title line
            Padding(
              padding: EdgeInsets.only(top: rightTopPad, left: leftPadding),
              child: Text(pointsLabel, style: pointsStyle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom scrollbar rail to mimic the inset scrollbar placement in the screenshot:
/// - Cards end before the rail
/// - Track/Thumb sit inside the rail (not flush to screen edge)
class _InsetScrollbar extends StatefulWidget {
  const _InsetScrollbar({
    required this.controller,
    required this.trackWidth,
    required this.trackColor,
    required this.thumbColor,
    required this.minThumbExtent,
    required this.radius,
  });

  final ScrollController controller;
  final double trackWidth;
  final Color trackColor;
  final Color thumbColor;
  final double minThumbExtent;
  final double radius;

  @override
  State<_InsetScrollbar> createState() => _InsetScrollbarState();
}

class _InsetScrollbarState extends State<_InsetScrollbar> {
  double _thumbTop = 0;
  double _thumbH = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_recalc);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recalc());
  }

  @override
  void didUpdateWidget(covariant _InsetScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_recalc);
      widget.controller.addListener(_recalc);
      WidgetsBinding.instance.addPostFrameCallback((_) => _recalc());
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_recalc);
    super.dispose();
  }

  void _recalc() {
    if (!mounted) return;
    if (!widget.controller.hasClients) return;

    final pos = widget.controller.position;
    final viewport = pos.viewportDimension;
    final maxScroll = pos.maxScrollExtent;

    // Compute thumb height proportional, but keep a minimum to match screenshot.
    final content = viewport + maxScroll;
    final proportional = (viewport * viewport) / math.max(content, 1);
    final thumbH = math.max(widget.minThumbExtent, proportional);

    final trackH = viewport;
    final scrollFrac =
        maxScroll <= 0 ? 0.0 : (pos.pixels / maxScroll).clamp(0.0, 1.0);
    final thumbTop = (trackH - thumbH) * scrollFrac;

    setState(() {
      _thumbH = thumbH;
      _thumbTop = thumbTop;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        
        // Handle invalid or zero height constraints
        if (h <= 0 || !h.isFinite) {
          return const SizedBox.shrink();
        }

        // If list has not laid out yet, approximate thumb with min height.
        final thumbH = (_thumbH > 0)
            ? _thumbH.clamp(widget.minThumbExtent, h)
            : widget.minThumbExtent;
        final thumbTop = (_thumbH > 0)
            ? _thumbTop.clamp(0.0, math.max(0.0, h - thumbH).toDouble())
            : 0.0;

        return Stack(
          children: [
            // Track
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: widget.trackWidth,
                height: h,
                decoration: BoxDecoration(
                  color: widget.trackColor,
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
              ),
            ),
            // Thumb
            Positioned(
              top: thumbTop,
              left: 0,
              child: Container(
                width: widget.trackWidth,
                height: thumbH,
                decoration: BoxDecoration(
                  color: widget.thumbColor,
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Transaction item model for the transaction history
class TransactionItem {
  const TransactionItem({
    required this.title,
    required this.time,
    required this.pointsDelta,
  });

  final String title;
  final String time;
  final int pointsDelta;
}

