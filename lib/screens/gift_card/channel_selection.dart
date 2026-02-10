import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/models/gift_card_models.dart';
import 'package:tellgo_app/screens/gift_card/gift_card_bloc.dart';
import 'package:tellgo_app/screens/gift_card/gift_card_event.dart';
import 'package:tellgo_app/screens/gift_card/gift_card_payment_success_screen.dart';
import 'package:tellgo_app/screens/gift_card/gift_card_state.dart';
import 'package:tellgo_app/screens/wallet/payment_webview_screen.dart';

/// Arguments passed to the GiftCardChannelSelectionScreen
class GiftCardChannelSelectionArgs {
  final GiftCardDenomination denomination;
  final List<String> channelCodes;
  final List<PaymentChannelInfo> channelInfos;
  final String? recipientName;
  final String? recipientEmail;
  final String? recipientMessage;

  const GiftCardChannelSelectionArgs({
    required this.denomination,
    required this.channelCodes,
    this.channelInfos = const [],
    this.recipientName,
    this.recipientEmail,
    this.recipientMessage,
  });

  /// Check if this is a gift for someone else
  bool get isGiftForSomeoneElse =>
      recipientName != null && recipientName!.isNotEmpty;
  
  /// Get channel info by code
  PaymentChannelInfo? getChannelInfo(String code) {
    try {
      return channelInfos.firstWhere(
        (info) => info.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Gift Card Channel Selection Screen
/// Displays available payment channels for gift card purchase
class GiftCardChannelSelectionScreen extends StatefulWidget {
  final GiftCardChannelSelectionArgs args;

  const GiftCardChannelSelectionScreen({
    super.key,
    required this.args,
  });

  @override
  State<GiftCardChannelSelectionScreen> createState() =>
      _GiftCardChannelSelectionScreenState();
}

class _GiftCardChannelSelectionScreenState
    extends State<GiftCardChannelSelectionScreen> {
  String? _selectedChannelCode;

  @override
  void initState() {
    super.initState();
    // Default to first channel if available
    if (widget.args.channelCodes.isNotEmpty) {
      _selectedChannelCode = widget.args.channelCodes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final scale = w / 521.0;
    double s(double px) => px * scale;

    // Colors
    const bg = Color(0xFFFFFFFF);
    const primaryPurple = Color(0xFF7B2C8F);
    const textPrimary = Color(0xFF111111);

    final sidePad = _clampDouble(s(24), 16, 32);

    return BlocConsumer<GiftCardBloc, GiftCardState>(
      listener: (context, state) {
        // Handle purchase success
        if (state is GiftCardPurchaseSuccess) {
          final response = state.response;

          if (kDebugMode) {
            debugPrint('🎁 Gift card purchase response received:');
            debugPrint('   - success: ${response.success}');
            debugPrint('   - paymentUrl: ${response.paymentUrl}');
            debugPrint('   - transactionId: ${response.transactionId}');
          }

          // If payment URL is present, navigate to payment screen
          if (response.paymentUrl != null && response.paymentUrl!.isNotEmpty) {
            if (kDebugMode) {
              debugPrint(
                  '🌐 Opening payment WebView for gift card: ${response.paymentUrl}');
            }
            final giftCardBloc = context.read<GiftCardBloc>();
            final denomination = widget.args.denomination;
            final recipientName = widget.args.recipientName;
            final recipientEmail = widget.args.recipientEmail;
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: giftCardBloc,
                  child: _PaymentWebViewWrapper(
                    paymentUrl: response.paymentUrl!,
                    transactionId: response.transactionId,
                    denomination: denomination,
                    recipientName: recipientName,
                    recipientEmail: recipientEmail,
                  ),
                ),
              ),
            );
          } else {
            // Direct success (no payment gateway, e.g., wallet payment)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.message ?? 'Gift card purchase successful',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        }

        // Handle transaction processing success
        if (state is GiftCardProcessTransactionSuccess) {
          if (kDebugMode) {
            debugPrint('🎉 Gift card transaction processed successfully from channel_selection');
            debugPrint('   - giftCardCode: ${state.response.giftCardCode}');
          }
          // Use post-frame callback to avoid navigator lock issues
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // Navigate to success screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GiftCardPaymentSuccessScreen(
                    response: state.response,
                    denomination: widget.args.denomination,
                    recipientName: widget.args.recipientName,
                    recipientEmail: widget.args.recipientEmail,
                  ),
                ),
              );
            }
          });
        }

        // Handle errors
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isPurchasing = state.isPurchasing;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textPrimary, size: s(24)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(
              'Cart',
              style: TextStyle(
                fontSize: s(18),
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: sidePad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: s(20)),

                        // Pay with section
                        Text(
                          'Pay with',
                          style: TextStyle(
                            fontSize: s(16),
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: s(16)),

                        // Payment channels list
                        ...widget.args.channelCodes.map((code) {
                          final isSelected = _selectedChannelCode == code;
                          final channelInfo = widget.args.getChannelInfo(code);
                          return _PaymentChannelTile(
                            channelCode: code,
                            channelInfo: channelInfo,
                            isSelected: isSelected,
                            scale: scale,
                            onTap: () {
                              setState(() => _selectedChannelCode = code);
                            },
                          );
                        }),

                        SizedBox(height: s(32)),

                        // Payment summary
                        _PaymentSummary(
                          denomination: widget.args.denomination,
                          scale: scale,
                        ),

                        SizedBox(height: s(24)),
                      ],
                    ),
                  ),
                ),

                // Go to Payment button
                Padding(
                  padding: EdgeInsets.all(sidePad),
                  child: SizedBox(
                    width: double.infinity,
                    height: s(52),
                    child: ElevatedButton(
                      onPressed: isPurchasing || _selectedChannelCode == null
                          ? null
                          : _onGoToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        disabledBackgroundColor: const Color(0xFFBDBDBD),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(s(26)),
                        ),
                      ),
                      child: isPurchasing
                          ? SizedBox(
                              width: s(24),
                              height: s(24),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Go To Payment',
                              style: TextStyle(
                                fontSize: s(15),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onGoToPayment() {
    if (_selectedChannelCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (kDebugMode) {
      debugPrint('🛒 Proceeding to payment:');
      debugPrint('   - Denomination ID: ${widget.args.denomination.id}');
      debugPrint('   - Channel: $_selectedChannelCode');
      debugPrint('   - Recipient: ${widget.args.recipientName ?? "Self"}');
      debugPrint('   - Email: ${widget.args.recipientEmail ?? "N/A"}');
    }

    // Create purchase request
    final request = GiftCardPurchaseRequest(
      giftCardDenominationId: widget.args.denomination.id,
      paymentChannelCode: _selectedChannelCode!,
      recipientName: widget.args.recipientName,
      recipientEmail: widget.args.recipientEmail,
      recipientMessage: widget.args.recipientMessage,
    );

    // Dispatch purchase event
    context.read<GiftCardBloc>().add(
          PurchaseGiftCardRequested(request: request),
        );
  }

  double _clampDouble(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }
}

/* ------------------------------ PAYMENT CHANNEL TILE ------------------------------ */

class _PaymentChannelTile extends StatelessWidget {
  final String channelCode;
  final PaymentChannelInfo? channelInfo;
  final bool isSelected;
  final double scale;
  final VoidCallback onTap;

  const _PaymentChannelTile({
    required this.channelCode,
    this.channelInfo,
    required this.isSelected,
    required this.scale,
    required this.onTap,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF7B2C8F);
    const textPrimary = Color(0xFF111111);
    final surfaceColor = isSelected 
        ? primaryPurple.withOpacity(0.08) 
        : const Color(0xFFF8F8F8);
    final borderColor = isSelected ? primaryPurple : Colors.transparent;

    // Use channel info name if available, otherwise use display name from code
    final displayName = channelInfo?.name ?? GiftCardPaymentChannel.getDisplayName(channelCode);

    return Padding(
      padding: EdgeInsets.only(bottom: s(10)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(s(12)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: s(16),
              vertical: s(16),
            ),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(s(12)),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 0,
              ),
            ),
            child: Row(
              children: [
                // Icon/Logo - prefer network image if available
                _buildChannelIcon(),
                SizedBox(width: s(14)),
                // Channel name
                Expanded(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: s(14),
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                ),
                // Selection indicator
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: primaryPurple,
                    size: s(22),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelIcon() {
    // If we have a logo URL from the API, use it
    if (channelInfo?.logo != null && channelInfo!.logo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(s(6)),
        child: Image.network(
          channelInfo!.logo!,
          width: s(40),
          height: s(28),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackIcon(),
        ),
      );
    }

    // Fallback to built-in icons
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    // Return appropriate icon based on channel code
    switch (channelCode.toLowerCase()) {
      case 'applepay':
        return Container(
          width: s(40),
          height: s(28),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(s(6)),
          ),
          child: Icon(
            Icons.apple,
            color: Colors.white,
            size: s(20),
          ),
        );
      case 'knet':
        return Container(
          width: s(40),
          height: s(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F71),
            borderRadius: BorderRadius.circular(s(6)),
          ),
          alignment: Alignment.center,
          child: Text(
            'K',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: s(16),
            ),
          ),
        );
      case 'mastercard':
      case 'master':
        return Container(
          width: s(40),
          height: s(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(s(6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: s(14),
                height: s(14),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEB001B),
                ),
              ),
              Transform.translate(
                offset: Offset(-s(5), 0),
                child: Container(
                  width: s(14),
                  height: s(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF79E1B).withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'visa':
        return Container(
          width: s(40),
          height: s(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F71),
            borderRadius: BorderRadius.circular(s(6)),
          ),
          alignment: Alignment.center,
          child: Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: s(10),
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case 'myfatoorah':
        return Container(
          width: s(40),
          height: s(28),
          decoration: BoxDecoration(
            color: const Color(0xFF00A651),
            borderRadius: BorderRadius.circular(s(6)),
          ),
          alignment: Alignment.center,
          child: Text(
            'MF',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: s(12),
            ),
          ),
        );
      case 'tgwallet':
      case 'tellgowallet':
        return Container(
          width: s(40),
          height: s(28),
          decoration: BoxDecoration(
            color: const Color(0xFF7B2C8F),
            borderRadius: BorderRadius.circular(s(6)),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: s(18),
          ),
        );
      default:
        return Container(
          width: s(40),
          height: s(28),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(s(6)),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.payment,
            color: Colors.grey[600],
            size: s(18),
          ),
        );
    }
  }
}

/* ------------------------------ PAYMENT SUMMARY ------------------------------ */

class _PaymentSummary extends StatelessWidget {
  final GiftCardDenomination denomination;
  final double scale;

  const _PaymentSummary({
    required this.denomination,
    required this.scale,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    const textPrimary = Color(0xFF111111);
    const textSecondary = Color(0xFF6B6B6B);

    final currency = denomination.currency ?? 'KWD';
    final amount = denomination.sellingPrice;
    final formattedAmount = '$currency ${amount.toStringAsFixed(3)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment summary',
          style: TextStyle(
            fontSize: s(16),
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: s(16)),

        // Subtotal
        _SummaryRow(
          label: 'Subtotal',
          value: formattedAmount,
          scale: scale,
          valueColor: textSecondary,
        ),
        SizedBox(height: s(10)),

        // Wallet
        _SummaryRow(
          label: 'Wallet',
          value: '$currency -0.000',
          scale: scale,
          valueColor: textSecondary,
          isStrikethrough: true,
        ),
        SizedBox(height: s(10)),

        // Points
        _SummaryRow(
          label: 'Points',
          value: '$currency 0.000',
          scale: scale,
          valueColor: textSecondary,
          isStrikethrough: true,
        ),
        SizedBox(height: s(16)),

        // Divider
        Container(
          height: 1,
          color: const Color(0xFFE5E5E5),
        ),
        SizedBox(height: s(16)),

        // Total Amount
        _SummaryRow(
          label: 'Total Amount',
          value: formattedAmount,
          scale: scale,
          isBold: true,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final double scale;
  final bool isBold;
  final bool isStrikethrough;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.scale,
    this.isBold = false,
    this.isStrikethrough = false,
    this.valueColor,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    const textPrimary = Color(0xFF111111);
    const textSecondary = Color(0xFF6B6B6B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: s(isBold ? 15 : 14),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isBold ? textPrimary : textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: s(isBold ? 15 : 14),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: valueColor ?? (isBold ? textPrimary : textSecondary),
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ PAYMENT WEBVIEW WRAPPER ------------------------------ */

/// Wrapper widget that handles the payment WebView and listens for transaction processing
class _PaymentWebViewWrapper extends StatelessWidget {
  final String paymentUrl;
  final String? transactionId;
  final GiftCardDenomination denomination;
  final String? recipientName;
  final String? recipientEmail;

  const _PaymentWebViewWrapper({
    required this.paymentUrl,
    this.transactionId,
    required this.denomination,
    this.recipientName,
    this.recipientEmail,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GiftCardBloc, GiftCardState>(
      listener: (context, state) {
        // Handle transaction processing success
        if (state is GiftCardProcessTransactionSuccess) {
          if (kDebugMode) {
            debugPrint('🎉 Gift card transaction processed successfully from WebView wrapper');
            debugPrint('   - giftCardCode: ${state.response.giftCardCode}');
          }
          // Use post-frame callback to avoid navigator lock issues
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // Pop all routes and push the success screen
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GiftCardPaymentSuccessScreen(
                    response: state.response,
                    denomination: denomination,
                    recipientName: recipientName,
                    recipientEmail: recipientEmail,
                  ),
                ),
              );
            }
          });
        }

        // Handle errors
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Show loading indicator while processing transaction
        if (state is GiftCardProcessingTransaction) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B2C8F)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Processing your gift card...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show payment WebView
        return PaymentWebViewScreen(
          paymentUrl: paymentUrl,
          transactionId: transactionId,
          onPaymentComplete: (txnId) {
            if (kDebugMode) {
              debugPrint('✅ Gift card payment completed, transactionId: $txnId');
            }
            // Process transaction after payment completion
            context.read<GiftCardBloc>().add(
              ProcessGiftCardTransactionRequested(transactionId: txnId),
            );
          },
        );
      },
    );
  }
}

