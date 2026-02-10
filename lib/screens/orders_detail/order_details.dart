import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/models/order_models.dart';
import 'package:tellgo_app/repository/order_repository.dart';
import 'package:tellgo_app/screens/orders/bloc/orders_bloc.dart';
import 'package:tellgo_app/screens/orders/bloc/orders_event.dart';
import 'package:tellgo_app/screens/orders/bloc/orders_state.dart';

/// Order Details Screen - loads real data from API via BLoC.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersBloc(
        orderRepository: OrderRepositoryImpl(AppDio()),
      )..add(LoadOrderDetails(orderId: orderId)),
      child: _OrderDetailsContent(orderId: orderId),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  const _OrderDetailsContent({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            // ===== Top Navigation Bar (56px height) =====
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _IconTap(
                      size: 24,
                      icon: Icons.arrow_back,
                      color: AppColors.textPrimary,
                      onTap: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Order #$orderId',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.appBarTitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Content =====
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrderDetailsLoading || state is OrdersInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is OrderDetailsError) {
                    // Clean up the error message for display
                    String displayMsg = state.message;
                    if (displayMsg.startsWith('Exception: ')) {
                      displayMsg = displayMsg.substring(11);
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading order details',
                              style: AppTextStyles.sectionTitle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayMsg,
                              style: AppTextStyles.bodySecondary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              text: 'Retry',
                              onTap: () {
                                context.read<OrdersBloc>().add(LoadOrderDetails(orderId: orderId));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is OrderDetailsLoaded) {
                    return _buildOrderDetailsBody(context, state.orderDetails);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsBody(BuildContext context, OrderDetails details) {
    final firstItem = details.items.isNotEmpty ? details.items.first : null;
    final statusColor = _getStatusColor(details.statusLabel);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===== Order Header Section =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: image + details + price aligned right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // eSIM image (56x56, radius 8)
                    Container(
                        width: 56,
                        height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.sim_card, size: 28, color: Color(0xFF9E9E9E)),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Middle content expands; price sits at far right.
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  firstItem?.name ?? 'Order',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.sectionTitle,
                                ),
                                if (firstItem?.description != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    firstItem!.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySecondary,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Price (right aligned)
                          Text(
                            details.formattedTotalPrice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.bodyPrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Status row and order id
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${details.statusLabel ?? 'Unknown'} ${details.formattedDate}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 16 / 12,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Order ID: $orderId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          // ===== Divider =====
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1, color: AppColors.divider),
          ),

          // ===== Order Summary Section =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Order Summary',
              style: AppTextStyles.sectionTitle,
            ),
          ),
          const SizedBox(height: 12),

          // Summary rows from items
          ...details.items.map((item) => _SummaryRow(
                label: '${item.name ?? 'Item'} x${item.quantity}',
                value: '${details.currency ?? 'KWD'} ${(item.pricePerUnit * item.quantity).toStringAsFixed(3)}',
              )),

          // Discount row (if any)
          if ((details.discount ?? 0) > 0)
            _SummaryRow(
              label: 'Discount',
              value: '-${details.currency ?? 'KWD'} ${details.discount!.toStringAsFixed(3)}',
            ),

          // Total row
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Total Amount',
            value: details.formattedTotalPrice,
            isEmphasis: true,
          ),

          // ===== Customer Info Section =====
          if (details.customerName != null) ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 1, color: AppColors.divider),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Customer',
                style: AppTextStyles.sectionTitle,
              ),
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Name',
              value: details.customerName!,
            ),
          ],

          // ===== eSIM Details (if available) =====
          if (firstItem != null && (firstItem.iccid != null || firstItem.qrCodeURL != null)) ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 1, color: AppColors.divider),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'eSIM Details',
                style: AppTextStyles.sectionTitle,
              ),
            ),
            const SizedBox(height: 8),
            if (firstItem.iccid != null)
              _SummaryRow(label: 'ICCID', value: firstItem.iccid!),
            if (firstItem.smdpAddress != null)
              _SummaryRow(label: 'SM-DP+', value: firstItem.smdpAddress!),
          ],

          // ===== CTA Button Group =====
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  text: 'View receipt',
                  onTap: () {
                    // TODO: Navigate to receipt
                  },
                ),
                if (firstItem?.iccid != null || firstItem?.qrCodeURL != null) ...[
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'View eSIM details',
                    onTap: () {
                      // TODO: Navigate to eSIM details
                    },
                  ),
                ],
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'View my eSIMs',
                  onTap: () {
                    // TODO: Navigate to eSIM list
                  },
                ),
              ],
            ),
          ),

          // ===== Help Link =====
          const SizedBox(height: 16),
          Center(
            child: _TextTap(
              text: 'Get Help',
              style: AppTextStyles.helpLink,
              onTap: () {
                // TODO: Open help/support
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statusLabel) {
    if (statusLabel == null) return const Color(0xFF787878);
    final s = statusLabel.toLowerCase();
    if (s.contains('complete')) return AppColors.success;
    if (s.contains('cancel') || s.contains('refund')) return const Color(0xFFFF0021);
    if (s.contains('pending')) return const Color(0xFFFFA500);
    if (s.contains('processing')) return const Color(0xFF2196F3);
    return const Color(0xFF787878);
  }
}

/// ===== Mini Design System =====

class AppColors {
  static const background = Color(0xFFFFFFFF);
  static const primary = Color(0xFF6A1BB9);
  static const primaryPressed = Color(0xFF4E148F);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF666666);
  static const textMuted = Color(0xFF9E9E9E);
  static const divider = Color(0xFFE6E6E6);
  static const success = Color(0xFF1FAE5B);
  static const buttonText = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String fontFamily = 'Roboto';

  static const appBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 20 / 16,
    color: AppColors.textPrimary,
  );

  static const sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 20 / 15,
    color: AppColors.textPrimary,
  );

  static const bodyPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  static const bodySecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: AppColors.textSecondary,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.textMuted,
  );

  static const button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.1,
    color: AppColors.buttonText,
  );

  static const amountEmphasis = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  static const helpLink = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    decorationThickness: 1,
  );
}

/// ===== Reusable widgets =====

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isEmphasis = false,
  });

  final String label;
  final String value;
  final bool isEmphasis;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isEmphasis ? AppTextStyles.amountEmphasis : AppTextStyles.bodyPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: isEmphasis ? AppTextStyles.amountEmphasis : AppTextStyles.bodyPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.enabled = true,
  });

  final String text;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.enabled
        ? (_pressed ? AppColors.primaryPressed : AppColors.primary)
        : AppColors.primary.withOpacity(0.5);

    return SizedBox(
      height: 48,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.enabled ? widget.onTap : null,
          onHighlightChanged: (v) {
            if (!widget.enabled) return;
            setState(() => _pressed = v);
          },
          child: Center(
            child: Text(
              widget.text,
              style: AppTextStyles.button,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: size, color: color),
          ),
        ),
      ),
    );
  }
}

class _TextTap extends StatelessWidget {
  const _TextTap({
    required this.text,
    required this.style,
    required this.onTap,
  });

  final String text;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(text, style: style),
        ),
      ),
    );
  }
}
