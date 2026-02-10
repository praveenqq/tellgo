import 'package:flutter/material.dart';
import 'package:tellgo_app/models/wallet_models.dart';

/// Wallet Payment Success Screen
/// Displays the result of a successful wallet top-up transaction
class WalletPaymentSuccessScreen extends StatelessWidget {
  final ProcessTransactionResponse response;
  final double amount;
  final double topUpValue;
  final String currency;

  const WalletPaymentSuccessScreen({
    super.key,
    required this.response,
    required this.amount,
    required this.topUpValue,
    this.currency = 'KWD',
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final scale = w / 375.0;
    double s(double px) => px * scale;

    final completedTime = DateTime.now();

    return Scaffold(
      backgroundColor: _Colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _CustomAppBar(
              scale: scale,
              onBackPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: s(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: s(8)),
                      
                      // Success animation/icon
                      _SuccessHeader(scale: scale),
                      
                      SizedBox(height: s(24)),
                      
                      // Main card
                      _CardSurface(
                        scale: scale,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Transaction info
                            _TransactionInfoSection(
                              amount: amount,
                              topUpValue: topUpValue,
                              currency: currency,
                              newBalance: response.newBalance,
                              scale: scale,
                            ),
                            
                            SizedBox(height: s(16)),
                            
                            // Completion time and order ID
                            _OrderMetaInfo(
                              completedTime: completedTime,
                              transactionId: response.transactionId ?? 'N/A',
                              scale: scale,
                            ),
                            
                            SizedBox(height: s(20)),
                            
                            // Order summary
                            _OrderSummary(
                              amount: amount,
                              topUpValue: topUpValue,
                              currency: currency,
                              newBalance: response.newBalance,
                              scale: scale,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: s(24)),
                      
                      // View Receipt button
                      _SecondaryButton(
                        text: 'View receipt',
                        scale: scale,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Receipt feature coming soon'),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: s(12)),
                      
                      // Done button
                      _PrimaryButton(
                        text: 'Done',
                        scale: scale,
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                      
                      SizedBox(height: s(24)),
                      
                      // Get Help link
                      _GetHelpLink(scale: scale),
                      
                      SizedBox(height: s(32)),
                    ],
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

/* ------------------------------ COLORS ------------------------------ */

class _Colors {
  static const Color background = Color(0xFFF6F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF7B2C8F);
  static const Color primaryDark = Color(0xFF5E1F6E);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
}

/* ------------------------------ CUSTOM APP BAR ------------------------------ */

class _CustomAppBar extends StatelessWidget {
  final double scale;
  final VoidCallback onBackPressed;

  const _CustomAppBar({
    required this.scale,
    required this.onBackPressed,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s(8), vertical: s(12)),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: s(24),
              color: _Colors.textPrimary,
            ),
            onPressed: onBackPressed,
          ),
          Expanded(
            child: Text(
              'Top-up Successful',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: s(18),
                fontWeight: FontWeight.w600,
                color: _Colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: s(48)), // Balance the back button
        ],
      ),
    );
  }
}

/* ------------------------------ SUCCESS HEADER ------------------------------ */

class _SuccessHeader extends StatelessWidget {
  final double scale;

  const _SuccessHeader({required this.scale});

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: s(80),
          height: s(80),
          decoration: BoxDecoration(
            color: _Colors.successLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: s(48),
            color: _Colors.success,
          ),
        ),
        SizedBox(height: s(16)),
        Text(
          'Wallet Topped Up!',
          style: TextStyle(
            fontSize: s(22),
            fontWeight: FontWeight.w700,
            color: _Colors.textPrimary,
          ),
        ),
        SizedBox(height: s(6)),
        Text(
          'Your wallet has been successfully topped up',
          style: TextStyle(
            fontSize: s(14),
            fontWeight: FontWeight.w400,
            color: _Colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ CARD SURFACE ------------------------------ */

class _CardSurface extends StatelessWidget {
  final Widget child;
  final double scale;

  const _CardSurface({
    required this.child,
    required this.scale,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(s(16)),
      decoration: BoxDecoration(
        color: _Colors.surface,
        borderRadius: BorderRadius.circular(s(16)),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
            color: Color.fromRGBO(0, 0, 0, 0.06),
          ),
        ],
      ),
      child: child,
    );
  }
}

/* ------------------------------ TRANSACTION INFO SECTION ------------------------------ */

class _TransactionInfoSection extends StatelessWidget {
  final double amount;
  final double topUpValue;
  final String currency;
  final double? newBalance;
  final double scale;

  const _TransactionInfoSection({
    required this.amount,
    required this.topUpValue,
    required this.currency,
    this.newBalance,
    required this.scale,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wallet icon
        Container(
          width: s(56),
          height: s(56),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7B2C8F),
                Color(0xFFB45DC9),
              ],
            ),
            borderRadius: BorderRadius.circular(s(12)),
          ),
          child: Center(
            child: Icon(
              Icons.account_balance_wallet,
              size: s(28),
              color: Colors.white,
            ),
          ),
        ),
        
        SizedBox(width: s(14)),
        
        // Text info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet Top-up',
                style: TextStyle(
                  fontSize: s(16),
                  fontWeight: FontWeight.w600,
                  color: _Colors.textPrimary,
                ),
              ),
              SizedBox(height: s(4)),
              Text(
                'Amount added to wallet',
                style: TextStyle(
                  fontSize: s(13),
                  fontWeight: FontWeight.w400,
                  color: _Colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Amount
        Text(
          '+$currency ${topUpValue.toStringAsFixed(3)}',
          style: TextStyle(
            fontSize: s(16),
            fontWeight: FontWeight.w700,
            color: _Colors.success,
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ ORDER META INFO ------------------------------ */

class _OrderMetaInfo extends StatelessWidget {
  final DateTime completedTime;
  final String transactionId;
  final double scale;

  const _OrderMetaInfo({
    required this.completedTime,
    required this.transactionId,
    required this.scale,
  });

  double s(double px) => px * scale;

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'pm' : 'am';
    return '$month $day - $hour:$minute$period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge with completion time
        Container(
          padding: EdgeInsets.symmetric(horizontal: s(10), vertical: s(6)),
          decoration: BoxDecoration(
            color: _Colors.successLight,
            borderRadius: BorderRadius.circular(s(6)),
          ),
          child: Text(
            'Completed • ${_formatDate(completedTime)}',
            style: TextStyle(
              fontSize: s(12),
              fontWeight: FontWeight.w500,
              color: _Colors.success,
            ),
          ),
        ),
        
        SizedBox(height: s(8)),
        
        // Transaction ID
        Text(
          'Transaction ID: $transactionId',
          style: TextStyle(
            fontSize: s(13),
            fontWeight: FontWeight.w400,
            color: _Colors.textMuted,
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ ORDER SUMMARY ------------------------------ */

class _OrderSummary extends StatelessWidget {
  final double amount;
  final double topUpValue;
  final String currency;
  final double? newBalance;
  final double scale;

  const _OrderSummary({
    required this.amount,
    required this.topUpValue,
    required this.currency,
    this.newBalance,
    required this.scale,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = '$currency ${amount.toStringAsFixed(3)}';
    final formattedTopUp = '$currency ${topUpValue.toStringAsFixed(3)}';
    final formattedNewBalance = newBalance != null 
        ? '$currency ${newBalance!.toStringAsFixed(3)}' 
        : '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          'Transaction Details',
          style: TextStyle(
            fontSize: s(15),
            fontWeight: FontWeight.w600,
            color: _Colors.textPrimary,
          ),
        ),
        
        SizedBox(height: s(14)),
        
        // Amount Paid
        _SummaryRow(
          label: 'Amount Paid',
          value: formattedAmount,
          scale: scale,
        ),
        
        SizedBox(height: s(8)),
        
        // Credited to Wallet
        _SummaryRow(
          label: 'Credited to Wallet',
          value: formattedTopUp,
          scale: scale,
          valueColor: _Colors.success,
        ),
        
        SizedBox(height: s(12)),
        
        // Divider
        Container(
          height: 1,
          color: _Colors.divider,
        ),
        
        SizedBox(height: s(12)),
        
        // New Balance
        _SummaryRow(
          label: 'New Wallet Balance',
          value: formattedNewBalance,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: s(isBold ? 14 : 13),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isBold ? _Colors.textPrimary : _Colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: s(isBold ? 14 : 13),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? (isBold ? _Colors.textPrimary : _Colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ PRIMARY BUTTON ------------------------------ */

class _PrimaryButton extends StatefulWidget {
  final String text;
  final double scale;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.scale,
    required this.onPressed,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  double s(double px) => px * widget.scale;

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
        height: s(52),
        decoration: BoxDecoration(
          color: _pressed ? _Colors.primaryDark : _Colors.primary,
          borderRadius: BorderRadius.circular(s(26)),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: s(15),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ SECONDARY BUTTON ------------------------------ */

class _SecondaryButton extends StatefulWidget {
  final String text;
  final double scale;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.text,
    required this.scale,
    required this.onPressed,
  });

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _pressed = false;

  double s(double px) => px * widget.scale;

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
        height: s(52),
        decoration: BoxDecoration(
          color: _pressed 
              ? const Color(0xFFE5E7EB) 
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(s(26)),
          border: Border.all(
            color: _Colors.divider,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: s(15),
            fontWeight: FontWeight.w600,
            color: _Colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ GET HELP LINK ------------------------------ */

class _GetHelpLink extends StatelessWidget {
  final double scale;

  const _GetHelpLink({required this.scale});

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Help feature coming soon'),
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(12)),
        ),
        child: Text(
          'Get Help',
          style: TextStyle(
            fontSize: s(14),
            fontWeight: FontWeight.w500,
            color: _Colors.textSecondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

