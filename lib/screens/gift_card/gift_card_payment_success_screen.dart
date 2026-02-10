import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tellgo_app/models/gift_card_models.dart';

/// Gift Card Payment Success Screen
/// Displays the result of a successful gift card purchase transaction
class GiftCardPaymentSuccessScreen extends StatelessWidget {
  final GiftCardProcessTransactionResponse response;
  final GiftCardDenomination? denomination;
  final String? recipientName;
  final String? recipientEmail;

  const GiftCardPaymentSuccessScreen({
    super.key,
    required this.response,
    this.denomination,
    this.recipientName,
    this.recipientEmail,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final scale = w / 375.0;
    double s(double px) => px * scale;

    final isGifting = recipientName != null && recipientName!.isNotEmpty;
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
                      
                      // Main card
                      _CardSurface(
                        scale: scale,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Product info
                            _ProductInfoSection(
                              response: response,
                              denomination: denomination,
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
                            
                            // Gift Card Code Section (important!)
                            if (response.giftCardCode != null) ...[
                              _GiftCardCodeSection(
                                code: response.giftCardCode!,
                                scale: scale,
                              ),
                              SizedBox(height: s(20)),
                            ],
                            
                            // Recipient info if gifting
                            if (isGifting) ...[
                              _RecipientInfoSection(
                                recipientName: recipientName!,
                                recipientEmail: recipientEmail,
                                emailSent: response.emailSent ?? false,
                                scale: scale,
                              ),
                              SizedBox(height: s(20)),
                            ],
                            
                            // Order summary
                            _OrderSummary(
                              amount: response.amount ?? denomination?.sellingPrice ?? 0,
                              currency: response.currency ?? denomination?.currency ?? 'KWD',
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
                          // TODO: Implement receipt view
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Receipt feature coming soon'),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: s(12)),
                      
                      // Copy Code button (if gift card code exists)
                      if (response.giftCardCode != null)
                        _PrimaryButton(
                          text: 'Copy Gift Card Code',
                          scale: scale,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: response.giftCardCode!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gift card code copied to clipboard'),
                                backgroundColor: Colors.green,
                              ),
                            );
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
  static const Color codeBackground = Color(0xFFFFF7ED);
  static const Color codeBorder = Color(0xFFFED7AA);
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
              'Payment successful',
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

/* ------------------------------ PRODUCT INFO SECTION ------------------------------ */

class _ProductInfoSection extends StatelessWidget {
  final GiftCardProcessTransactionResponse response;
  final GiftCardDenomination? denomination;
  final double scale;

  const _ProductInfoSection({
    required this.response,
    this.denomination,
    required this.scale,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    final currency = response.currency ?? denomination?.currency ?? 'KWD';
    final amount = response.amount ?? denomination?.sellingPrice ?? 0;
    final denominationText = denomination?.denomination ?? '$amount $currency';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gift card icon/image
        Container(
          width: s(72),
          height: s(72),
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
              Icons.card_giftcard,
              size: s(36),
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
                'TellGo Gift Card',
                style: TextStyle(
                  fontSize: s(16),
                  fontWeight: FontWeight.w600,
                  color: _Colors.textPrimary,
                ),
              ),
              SizedBox(height: s(4)),
              Text(
                denominationText,
                style: TextStyle(
                  fontSize: s(14),
                  fontWeight: FontWeight.w400,
                  color: _Colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Amount
        Text(
          '$currency ${amount.toStringAsFixed(3)}',
          style: TextStyle(
            fontSize: s(16),
            fontWeight: FontWeight.w600,
            color: _Colors.textPrimary,
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
    return 'Completed$month $day - $hour:$minute$period';
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
            _formatDate(completedTime),
            style: TextStyle(
              fontSize: s(12),
              fontWeight: FontWeight.w500,
              color: _Colors.success,
            ),
          ),
        ),
        
        SizedBox(height: s(8)),
        
        // Order ID
        Text(
          'Order ID: $transactionId',
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

/* ------------------------------ GIFT CARD CODE SECTION ------------------------------ */

class _GiftCardCodeSection extends StatelessWidget {
  final String code;
  final double scale;

  const _GiftCardCodeSection({
    required this.code,
    required this.scale,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(s(16)),
      decoration: BoxDecoration(
        color: _Colors.codeBackground,
        borderRadius: BorderRadius.circular(s(12)),
        border: Border.all(color: _Colors.codeBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: s(20),
                color: const Color(0xFFD97706),
              ),
              SizedBox(width: s(8)),
              Text(
                'Your Gift Card Code',
                style: TextStyle(
                  fontSize: s(14),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF92400E),
                ),
              ),
            ],
          ),
          SizedBox(height: s(12)),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: s(14), vertical: s(12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(s(8)),
                    border: Border.all(color: _Colors.codeBorder),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: s(18),
                      fontWeight: FontWeight.w700,
                      color: _Colors.textPrimary,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              SizedBox(width: s(10)),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(s(8)),
                  child: Container(
                    padding: EdgeInsets.all(s(12)),
                    decoration: BoxDecoration(
                      color: _Colors.primary,
                      borderRadius: BorderRadius.circular(s(8)),
                    ),
                    child: Icon(
                      Icons.copy,
                      size: s(22),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ RECIPIENT INFO SECTION ------------------------------ */

class _RecipientInfoSection extends StatelessWidget {
  final String recipientName;
  final String? recipientEmail;
  final bool emailSent;
  final double scale;

  const _RecipientInfoSection({
    required this.recipientName,
    this.recipientEmail,
    required this.emailSent,
    required this.scale,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(s(14)),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(s(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: s(20),
                color: _Colors.primary,
              ),
              SizedBox(width: s(8)),
              Text(
                'Gift Recipient',
                style: TextStyle(
                  fontSize: s(14),
                  fontWeight: FontWeight.w600,
                  color: _Colors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: s(10)),
          _InfoRow(
            label: 'Name:',
            value: recipientName,
            scale: scale,
          ),
          if (recipientEmail != null) ...[
            SizedBox(height: s(6)),
            _InfoRow(
              label: 'Email:',
              value: recipientEmail!,
              scale: scale,
            ),
          ],
          SizedBox(height: s(10)),
          Row(
            children: [
              Icon(
                emailSent ? Icons.check_circle : Icons.schedule,
                size: s(16),
                color: emailSent ? _Colors.success : _Colors.textMuted,
              ),
              SizedBox(width: s(6)),
              Text(
                emailSent 
                    ? 'Gift card sent to recipient\'s email' 
                    : 'Email notification pending',
                style: TextStyle(
                  fontSize: s(12),
                  fontWeight: FontWeight.w500,
                  color: emailSent ? _Colors.success : _Colors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double scale;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.scale,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: s(60),
          child: Text(
            label,
            style: TextStyle(
              fontSize: s(13),
              fontWeight: FontWeight.w400,
              color: _Colors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: s(13),
              fontWeight: FontWeight.w500,
              color: _Colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ ORDER SUMMARY ------------------------------ */

class _OrderSummary extends StatelessWidget {
  final double amount;
  final String currency;
  final double scale;

  const _OrderSummary({
    required this.amount,
    required this.currency,
    required this.scale,
  });

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = '$currency ${amount.toStringAsFixed(3)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          'Order Summary',
          style: TextStyle(
            fontSize: s(15),
            fontWeight: FontWeight.w600,
            color: _Colors.textPrimary,
          ),
        ),
        
        SizedBox(height: s(14)),
        
        // Subtotal
        _SummaryRow(
          label: 'Subtotal',
          value: formattedAmount,
          scale: scale,
        ),
        
        SizedBox(height: s(8)),
        
        // Wallet
        _SummaryRow(
          label: 'Wallet',
          value: '$currency -0.000',
          scale: scale,
        ),
        
        SizedBox(height: s(8)),
        
        // Points
        _SummaryRow(
          label: 'Points',
          value: '$currency 0.000',
          scale: scale,
        ),
        
        SizedBox(height: s(12)),
        
        // Divider
        Container(
          height: 1,
          color: _Colors.divider,
        ),
        
        SizedBox(height: s(12)),
        
        // Total
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

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.scale,
    this.isBold = false,
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
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? _Colors.textPrimary : _Colors.textSecondary,
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
          // TODO: Navigate to help/support screen
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

