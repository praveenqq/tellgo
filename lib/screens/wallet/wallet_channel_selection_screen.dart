import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/models/wallet_models.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_bloc.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_event.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_state.dart';
import 'package:tellgo_app/screens/wallet/payment_webview_screen.dart';
import 'package:tellgo_app/screens/wallet/wallet_payment_success_screen.dart';

/// Arguments passed to the WalletChannelSelectionScreen
class WalletChannelSelectionArgs {
  final WalletDenomination? denomination;
  final double? customAmount;
  final List<String> channelCodes;
  final String currency;

  const WalletChannelSelectionArgs({
    this.denomination,
    this.customAmount,
    required this.channelCodes,
    this.currency = 'KWD',
  });

  double get amount => denomination?.buyAmount ?? customAmount ?? 0;
  double get topUpValue => denomination?.getAmount ?? customAmount ?? 0;
  String get displayAmount => '${amount.toStringAsFixed(3)} $currency';
}

/// Wallet Channel Selection Screen
/// Displays available payment channels for wallet top-up
class WalletChannelSelectionScreen extends StatefulWidget {
  final WalletChannelSelectionArgs args;

  const WalletChannelSelectionScreen({
    super.key,
    required this.args,
  });

  @override
  State<WalletChannelSelectionScreen> createState() =>
      _WalletChannelSelectionScreenState();
}

class _WalletChannelSelectionScreenState
    extends State<WalletChannelSelectionScreen> {
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

    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        // Handle top-up success
        if (state is WalletTopUpSuccess) {
          final response = state.response;

          if (kDebugMode) {
            debugPrint('💰 Wallet top-up response received:');
            debugPrint('   - success: ${response.success}');
            debugPrint('   - paymentUrl: ${response.paymentUrl}');
            debugPrint('   - transactionId: ${response.transactionId}');
          }

          // If payment URL is present, navigate to payment screen
          if (response.paymentUrl != null && response.paymentUrl!.isNotEmpty) {
            if (kDebugMode) {
              debugPrint(
                  '🌐 Opening payment WebView for wallet: ${response.paymentUrl}');
            }
            final walletBloc = context.read<WalletBloc>();
            final args = widget.args;
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: walletBloc,
                  child: _WalletPaymentWebViewWrapper(
                    paymentUrl: response.paymentUrl!,
                    transactionId: response.transactionId,
                    amount: args.amount,
                    topUpValue: args.topUpValue,
                    currency: args.currency,
                  ),
                ),
              ),
            );
          } else {
            // Direct success (no payment gateway, e.g., wallet payment)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.message ?? 'Wallet top-up successful',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        }

        // Handle transaction processing success
        if (state is WalletProcessTransactionSuccess) {
          if (kDebugMode) {
            debugPrint('🎉 Wallet transaction processed successfully');
            debugPrint('   - newBalance: ${state.response.newBalance}');
          }
          // Use post-frame callback to avoid navigator lock issues
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // Navigate to success screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => WalletPaymentSuccessScreen(
                    response: state.response,
                    amount: widget.args.amount,
                    topUpValue: widget.args.topUpValue,
                    currency: widget.args.currency,
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
        final isProcessing = state.isToppingUp || state.isProcessingTransaction;

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
              'Payment Method',
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
                          'Payment Method',
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
                          return _PaymentChannelTile(
                            channelCode: code,
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
                          amount: widget.args.amount,
                          topUpValue: widget.args.topUpValue,
                          currency: widget.args.currency,
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
                      onPressed: isProcessing || _selectedChannelCode == null
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
                      child: isProcessing
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
      debugPrint('💳 Proceeding to wallet top-up:');
      debugPrint('   - Amount: ${widget.args.amount}');
      debugPrint('   - Denomination ID: ${widget.args.denomination?.denominationId}');
      debugPrint('   - Channel: $_selectedChannelCode');
    }

    // Create top-up request
    final request = TopUpRequest(
      denominationId: widget.args.denomination?.denominationId,
      amount: widget.args.denomination == null ? widget.args.customAmount : null,
      paymentChannelCode: _selectedChannelCode!,
    );

    // Dispatch top-up event
    context.read<WalletBloc>().add(
          TopUpWalletRequested(request: request),
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
  final bool isSelected;
  final double scale;
  final VoidCallback onTap;

  const _PaymentChannelTile({
    required this.channelCode,
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

    final displayName = _getDisplayName(channelCode);

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
                // Icon/Logo
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

  String _getDisplayName(String code) {
    switch (code.toLowerCase()) {
      case 'myfatoorah':
        return 'MyFatoorah';
      case 'tgwallet':
        return 'TellGo Wallet';
      case 'knet':
        return 'KNET';
      case 'applepay':
        return 'Apple Pay';
      case 'mastercard':
      case 'master':
        return 'Master Card';
      case 'visa':
        return 'Visa';
      default:
        return code;
    }
  }

  Widget _buildChannelIcon() {
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
  final double amount;
  final double topUpValue;
  final String currency;
  final double scale;

  const _PaymentSummary({
    required this.amount,
    required this.topUpValue,
    required this.currency,
    required this.scale,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    const textPrimary = Color(0xFF111111);
    const textSecondary = Color(0xFF6B6B6B);

    final formattedAmount = '$currency ${amount.toStringAsFixed(3)}';
    final formattedTopUp = '$currency ${topUpValue.toStringAsFixed(3)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Summary',
          style: TextStyle(
            fontSize: s(16),
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: s(16)),

        // Top-up Amount
        _SummaryRow(
          label: 'Top-up Amount',
          value: formattedAmount,
          scale: scale,
          valueColor: textSecondary,
        ),
        SizedBox(height: s(10)),

        // You will receive
        _SummaryRow(
          label: 'You will receive',
          value: formattedTopUp,
          scale: scale,
          valueColor: const Color(0xFF10B981), // green
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
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.scale,
    this.isBold = false,
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
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? (isBold ? textPrimary : textSecondary),
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ PAYMENT WEBVIEW WRAPPER ------------------------------ */

/// Wrapper widget that handles the payment WebView and listens for transaction processing
class _WalletPaymentWebViewWrapper extends StatelessWidget {
  final String paymentUrl;
  final String? transactionId;
  final double amount;
  final double topUpValue;
  final String currency;

  const _WalletPaymentWebViewWrapper({
    required this.paymentUrl,
    this.transactionId,
    required this.amount,
    required this.topUpValue,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        // Handle transaction processing success
        if (state is WalletProcessTransactionSuccess) {
          if (kDebugMode) {
            debugPrint('🎉 Wallet transaction processed successfully from WebView wrapper');
            debugPrint('   - newBalance: ${state.response.newBalance}');
          }
          // Use post-frame callback to avoid navigator lock issues
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // Pop all routes and push the success screen
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WalletPaymentSuccessScreen(
                    response: state.response,
                    amount: amount,
                    topUpValue: topUpValue,
                    currency: currency,
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
        if (state is WalletProcessingTransaction) {
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
                    'Processing your top-up...',
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
              debugPrint('✅ Wallet payment completed, transactionId: $txnId');
            }
            // Process transaction after payment completion
            context.read<WalletBloc>().add(
              ProcessTransactionRequested(transactionId: txnId),
            );
          },
        );
      },
    );
  }
}

