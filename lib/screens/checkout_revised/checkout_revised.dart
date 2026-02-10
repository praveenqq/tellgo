import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/screens/bundle_revised/data/models.dart';
import 'package:tellgo_app/screens/checkout_revised/checkout_repository.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_bloc.dart';
import 'package:tellgo_app/screens/wallet/payment_webview_screen.dart';

/// Payment Screen - Checkout flow for bundle purchase
/// Accepts a BundleRevisedItem and quantity, allows coupon codes and payment method selection
class PaymentScreen extends StatefulWidget {
  final BundleRevisedItem? bundle;
  final int quantity;

  const PaymentScreen({
    super.key,
    this.bundle,
    this.quantity = 1,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _couponController = TextEditingController();
  final _giftCardController = TextEditingController();
  final _checkoutRepo = CheckoutRepository();
  
  // Quantity management
  late int _quantity;
  static const int _minQuantity = 1;
  static const int _maxQuantity = 10;
  
  // Payment channels
  List<PaymentChannel> _paymentChannels = [];
  bool _isLoadingChannels = true;
  PaymentChannel? _selectedChannel;
  
  bool _isApplyingCoupon = false;
  CouponResult? _couponResult;
  bool _couponExpanded = false;
  
  // Payment processing state
  bool _isProcessingPayment = false;
  
  // Get bundle info
  BundleRevisedItem? get bundle => widget.bundle;
  int get quantity => _quantity;
  
  // Calculate prices - use merchantSellingPrice for payment calculations
  double get unitPrice {
    if (bundle == null) return 0.0;
    // Priority: merchantSellingPrice > sellingPriceInDollar > costAmountInDollar
    return bundle!.merchantSellingPrice ?? bundle!.sellingPriceInDollar ?? bundle!.costAmountInDollar ?? 0.0;
  }
  
  double get totalPrice => unitPrice * quantity;
  
  double get discountAmount {
    if (_couponResult?.success == true && _couponResult?.discountAmount != null) {
      return _couponResult!.discountAmount!;
    }
    return 0.0;
  }
  
  double get payableAmount => (totalPrice - discountAmount).clamp(0.0, double.infinity);

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
    _loadPaymentChannels();
  }

  void _incrementQuantity() {
    if (_quantity < _maxQuantity) {
      setState(() {
        _quantity++;
        // Auto-deselect wallet if balance becomes insufficient
        _checkAndDeselectWalletIfInsufficient();
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > _minQuantity) {
      setState(() => _quantity--);
    }
  }
  
  /// Check if wallet is selected but has insufficient balance, and deselect it
  void _checkAndDeselectWalletIfInsufficient() {
    if (_selectedChannel?.isWallet == true) {
      try {
        final walletState = context.read<WalletBloc>().state;
        final walletBalance = walletState.balance?.balance ?? 0.0;
        if (walletBalance < payableAmount) {
          _selectedChannel = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallet deselected: Insufficient balance for new total'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (_) {
        // WalletBloc not available
      }
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    _giftCardController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentChannels() async {
    setState(() => _isLoadingChannels = true);
    
    final channels = await _checkoutRepo.getServiceChannels(serviceId: 1);
    
    if (mounted) {
      setState(() {
        _paymentChannels = channels;
        _isLoadingChannels = false;
        // Auto-select first channel if available
        if (channels.isNotEmpty) {
          _selectedChannel = channels.first;
        }
      });
    }
  }

  Future<void> _applyCoupon() async {
    if (_couponController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a coupon code'),
          backgroundColor: UIColors.danger,
        ),
      );
      return;
    }
    
    if (bundle == null) return;
    
    setState(() => _isApplyingCoupon = true);
    
    final result = await _checkoutRepo.applyCouponCode(
      bundleId: bundle!.id,
      quantity: quantity,
      orderAmount: totalPrice,
      couponCode: _couponController.text.trim(),
    );
    
    setState(() {
      _isApplyingCoupon = false;
      _couponResult = result;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? UIColors.primary : UIColors.danger,
        ),
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponResult = null;
      _couponController.clear();
    });
  }

  Future<void> _goToPayment() async {
    if (bundle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No bundle selected'),
          backgroundColor: UIColors.danger,
        ),
      );
      return;
    }
    
    if (_selectedChannel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: UIColors.danger,
        ),
      );
      return;
    }
    
    // Validate gift card code if gift card payment is selected
    if (_selectedChannel!.isGiftCard && _giftCardController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your gift card code'),
          backgroundColor: UIColors.danger,
        ),
      );
      return;
    }
    
    setState(() => _isProcessingPayment = true);
    
    try {
      // Create purchase item
      final purchaseItems = [
        PurchaseItem(
          bundleId: bundle!.id,
          categoryId: bundle!.categoryId,
          subCategoryId: bundle!.subCategoryId,
          purchasedQuantity: quantity,
          pricePerunit: unitPrice,
        ),
      ];
      
      // Call validation API
      // Note: Send FULL price (totalPrice) for both cartTotal and finalTotal
      // Backend will calculate and apply the discount using the discountCoupon code
      final result = await _checkoutRepo.validateBundlePurchase(
        paymentChannelCode: _selectedChannel!.code,
        cartTotal: totalPrice,
        finalTotal: totalPrice,  // Full price - backend applies discount from coupon
        purchaseItems: purchaseItems,
        giftCardCode: _selectedChannel!.isGiftCard ? _giftCardController.text.trim() : null,
        discountCoupon: _couponResult?.success == true ? _couponController.text.trim() : null,
        currency: 'USD',
      );
      
      if (!mounted) return;
      
      setState(() => _isProcessingPayment = false);
      
      if (result.success) {
        if (kDebugMode) {
          debugPrint('✅ Payment validation successful');
          debugPrint('   - orderId: ${result.orderId}');
          debugPrint('   - paymentUrl: ${result.paymentUrl}');
          debugPrint('   - transactionId: ${result.paymentTransactionId}');
        }
        
        // If we have a payment URL, navigate to WebView
        if (result.paymentUrl != null && result.paymentUrl!.isNotEmpty) {
          _navigateToPayment(result);
        } else {
          // Direct success (e.g., full gift card payment - no external payment needed)
          // Navigate to success screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => _BundlePurchaseSuccessScreen(
                bundleName: bundle?.subCategoryName ?? bundle?.name ?? 'Bundle',
                transactionId: result.orderId ?? 'N/A',
                message: result.message,
                isGiftCardPayment: _selectedChannel?.isGiftCard ?? false,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: UIColors.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred'),
            backgroundColor: UIColors.danger,
          ),
        );
      }
    }
  }

  void _navigateToPayment(BundlePurchaseValidationResult validationResult) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _BundlePaymentWebViewWrapper(
          paymentUrl: validationResult.paymentUrl!,
          transactionId: validationResult.paymentTransactionId,
          checkoutRepo: _checkoutRepo,
          bundleName: bundle?.subCategoryName ?? bundle?.name ?? 'Bundle',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.background,
      appBar: AppBar(
        backgroundColor: UIColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: UIColors.textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: UIColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(UISpacing.screenPadding16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CardSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PlanHeader(
                        bundle: bundle,
                        quantity: quantity,
                        unitPrice: unitPrice,
                        onIncrement: _incrementQuantity,
                        onDecrement: _decrementQuantity,
                        canIncrement: _quantity < _maxQuantity,
                        canDecrement: _quantity > _minQuantity,
                      ),
                      const _SectionDivider(),

                      _TotalPriceRow(totalPrice: totalPrice),
                      const _SectionDivider(),

                      _DiscountSection(
                        expanded: _couponExpanded,
                        couponController: _couponController,
                        isApplying: _isApplyingCoupon,
                        couponResult: _couponResult,
                        onToggle: () => setState(() => _couponExpanded = !_couponExpanded),
                        onApply: _applyCoupon,
                        onRemove: _removeCoupon,
                      ),
                      const _SectionDivider(),

                      _PaymentChannelsSection(
                        channels: _paymentChannels,
                        isLoading: _isLoadingChannels,
                        selectedChannel: _selectedChannel,
                        cartTotal: payableAmount,
                        onChannelSelected: (channel) => setState(() => _selectedChannel = channel),
                        giftCardController: _giftCardController,
                        onGiftCardChanged: () => setState(() {}),
                      ),
                      const _SectionDivider(),

                      _PayableAmountRow(
                        payableAmount: payableAmount,
                        discountAmount: discountAmount,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: UISpacing.sectionGap24),

                _PrimaryButton(
                  text: 'Go To Payment',
                  onPressed: _isProcessingPayment ? null : _goToPayment,
                  isLoading: _isProcessingPayment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================
   TOKENS / CONSTANTS
   =========================== */

class UIColors {
  static const Color background = Color(0xFFF6F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF6A2FA1);
  static const Color primaryPressed = Color(0xFF58248C);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color iconMuted = Color(0xFF6B7280);
  static const Color danger = Color(0xFFE11D48);
  static const Color success = Color(0xFF22C55E);
}

class UISpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;

  static const double screenPadding16 = 16;
  static const double cardPadding16 = 16;
  static const double dividerVSpacing12 = 12;
  static const double sectionGap24 = 24;

  static const double rowHeight52 = 52;
  static const double discountRowHeight44 = 44;
  static const double buttonHeight52 = 52;
}

class UIRadius {
  static const double r8 = 8;
  static const double r12 = 12;
}

class UITextStyles {
  static const TextStyle titleSmall16Semibold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    color: UIColors.textPrimary,
  );

  static const TextStyle body14RegularSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 18 / 14,
    color: UIColors.textSecondary,
  );

  static const TextStyle body14MediumPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 18 / 14,
    color: UIColors.textPrimary,
  );

  static const TextStyle caption12RegularMuted = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 14 / 12,
    color: UIColors.textMuted,
  );

  static const TextStyle action12SemiboldDanger = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 14 / 12,
    color: UIColors.danger,
  );

  static const TextStyle button16SemiboldWhite = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    color: Colors.white,
  );

  static const TextStyle label12UpperSecondary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 14 / 12,
    letterSpacing: 0.1,
    color: UIColors.textSecondary,
  );
}

/* ===========================
   SCREEN SECTIONS / WIDGETS
   =========================== */

class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UISpacing.cardPadding16),
      decoration: BoxDecoration(
        color: UIColors.surface,
        borderRadius: BorderRadius.circular(UIRadius.r12),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
            color: Color.fromRGBO(0, 0, 0, 0.04),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UISpacing.dividerVSpacing12),
      child: Container(
        height: 1,
        color: UIColors.divider,
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({
    required this.bundle,
    required this.quantity,
    required this.unitPrice,
    required this.onIncrement,
    required this.onDecrement,
    required this.canIncrement,
    required this.canDecrement,
  });

  final BundleRevisedItem? bundle;
  final int quantity;
  final double unitPrice;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canIncrement;
  final bool canDecrement;

  @override
  Widget build(BuildContext context) {
    final name = bundle?.subCategoryName ?? bundle?.name ?? 'Unknown Plan';
    final dataInfo = bundle != null ? 'Data ${bundle!.data} | Validity ${bundle!.validity} Days' : '';
    final priceStr = '\$${unitPrice.toStringAsFixed(2)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Logo, Name, Price
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bundle logo/flag
            if (bundle?.subCategoryLogo != null && bundle!.subCategoryLogo!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  bundle!.subCategoryLogo!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: UIColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sim_card, size: 24, color: UIColors.primary),
                  ),
                ),
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: UIColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sim_card, size: 24, color: UIColors.primary),
              ),
            const SizedBox(width: 12),
            // Name and data info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: UITextStyles.titleSmall16Semibold),
                  if (dataInfo.isNotEmpty) ...[
                    const SizedBox(height: UISpacing.s4),
                    Text(dataInfo, style: UITextStyles.body14RegularSecondary),
                  ],
                  const SizedBox(height: UISpacing.s4),
                  Text(priceStr, style: UITextStyles.caption12RegularMuted),
            ],
          ),
        ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Bottom row: Quantity controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // QTY label
            Text(
              'Quantity',
              style: UITextStyles.body14RegularSecondary.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Quantity controls (+/-)
            _QuantityControls(
              quantity: quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
              canIncrement: canIncrement,
              canDecrement: canDecrement,
          ),
          ],
        ),
      ],
    );
  }
}

/// Quantity control widget with + and - buttons
class _QuantityControls extends StatelessWidget {
  const _QuantityControls({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.canIncrement,
    required this.canDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canIncrement;
  final bool canDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: UIColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          _QuantityButton(
            icon: Icons.remove,
            onTap: canDecrement ? onDecrement : null,
            enabled: canDecrement,
          ),
          
          // Quantity display
          Container(
            width: 44,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: UIColors.textPrimary,
              ),
            ),
          ),
          
          // Increment button
          _QuantityButton(
            icon: Icons.add,
            onTap: canIncrement ? onIncrement : null,
            enabled: canIncrement,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

/// Individual quantity button (+ or -)
class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
    this.isPrimary = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isPrimary 
        ? (enabled ? UIColors.primary : UIColors.primary.withValues(alpha: 0.5))
        : Colors.transparent;
    final Color iconColor = isPrimary 
        ? Colors.white 
        : (enabled ? UIColors.primary : UIColors.textMuted);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.horizontal(
        left: isPrimary ? Radius.zero : const Radius.circular(8),
        right: isPrimary ? const Radius.circular(8) : Radius.zero,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.horizontal(
          left: isPrimary ? Radius.zero : const Radius.circular(8),
          right: isPrimary ? const Radius.circular(8) : Radius.zero,
        ),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class _TotalPriceRow extends StatelessWidget {
  const _TotalPriceRow({required this.totalPrice});

  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text('TOTAL PRICE', style: UITextStyles.label12UpperSecondary),
        ),
        Text('\$${totalPrice.toStringAsFixed(2)}', style: UITextStyles.body14MediumPrimary),
      ],
    );
  }
}

class _DiscountSection extends StatelessWidget {
  const _DiscountSection({
    required this.expanded,
    required this.couponController,
    required this.isApplying,
    required this.couponResult,
    required this.onToggle,
    required this.onApply,
    required this.onRemove,
  });

  final bool expanded;
  final TextEditingController couponController;
  final bool isApplying;
  final CouponResult? couponResult;
  final VoidCallback onToggle;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
        borderRadius: BorderRadius.circular(UIRadius.r8),
          onTap: onToggle,
          child: SizedBox(
            height: UISpacing.discountRowHeight44,
          child: Row(
            children: [
              Expanded(
                child: Text(
                    'Discount codes and Vouchers',
                  style: UITextStyles.body14RegularSecondary.copyWith(
                    color: UIColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: UISpacing.s8),
                // Show success indicator if coupon applied
                if (couponResult?.success == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: UIColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Applied',
                      style: TextStyle(
                        color: UIColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
              Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: UIColors.iconMuted,
              ),
            ],
          ),
        ),
      ),
        
        // Expanded coupon input section
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Coupon input field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: couponController,
                              enabled: couponResult?.success != true,
                              decoration: InputDecoration(
                                hintText: 'Enter coupon code',
                                hintStyle: const TextStyle(
                                  color: UIColors.textMuted,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: UIColors.divider.withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(UIRadius.r8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              style: const TextStyle(
                                color: UIColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Apply or Remove button
                          if (couponResult?.success == true)
                            TextButton(
                              onPressed: onRemove,
                              style: TextButton.styleFrom(
                                backgroundColor: UIColors.danger.withValues(alpha: 0.1),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(UIRadius.r8),
                                ),
                              ),
                              child: const Text(
                                'Remove',
                                style: TextStyle(
                                  color: UIColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: isApplying ? null : onApply,
                              style: TextButton.styleFrom(
                                backgroundColor: UIColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(UIRadius.r8),
                                ),
                              ),
                              child: isApplying
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Apply',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                        ],
                      ),
                      
                      // Show discount info if applied
                      if (couponResult?.success == true && couponResult?.discountAmount != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: UIColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(UIRadius.r8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: UIColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'You save \$${couponResult!.discountAmount!.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: UIColors.success,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _PaymentChannelsSection extends StatelessWidget {
  const _PaymentChannelsSection({
    required this.channels,
    required this.isLoading,
    required this.selectedChannel,
    required this.cartTotal,
    required this.onChannelSelected,
    required this.giftCardController,
    required this.onGiftCardChanged,
  });

  final List<PaymentChannel> channels;
  final bool isLoading;
  final PaymentChannel? selectedChannel;
  final double cartTotal;
  final ValueChanged<PaymentChannel> onChannelSelected;
  final TextEditingController giftCardController;
  final VoidCallback onGiftCardChanged;

  @override
  Widget build(BuildContext context) {
    // Try to get wallet balance from BLoC for wallet channel
    double walletBalance = 0.0;
    try {
      final walletState = context.watch<WalletBloc>().state;
      if (walletState.balance != null) {
        walletBalance = walletState.balance!.balance;
      }
    } catch (_) {
      // WalletBloc not available
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 18 / 14,
            color: UIColors.textPrimary,
          ),
        ),
        const SizedBox(height: UISpacing.s8),

        // Loading state
        if (isLoading)
          const _PaymentChannelsLoading()
        else if (channels.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No payment methods available',
                style: UITextStyles.body14RegularSecondary,
              ),
            ),
          )
        else
          Column(
            children: channels.asMap().entries.map((entry) {
              final index = entry.key;
              final channel = entry.value;
              final isSelected = selectedChannel?.id == channel.id;
              
              // Check if wallet has insufficient balance
              final bool isWalletInsufficient = channel.isWallet && walletBalance < cartTotal;
              
              // Get subtitle based on channel type
              String subtitle = '';
              if (channel.isWallet) {
                if (isWalletInsufficient) {
                  subtitle = 'Insufficient balance (\$${walletBalance.toStringAsFixed(2)})';
                } else {
                  subtitle = '${walletBalance.toStringAsFixed(2)} USD available';
                }
              } else if (channel.isGiftCard) {
                subtitle = 'Pay with Tellgo gift card';
              } else {
                subtitle = 'Pay with ${channel.name}';
              }
              
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: (channel.isGiftCard && isSelected) ? 0 : (index < channels.length - 1 ? UISpacing.s12 : 0)),
                    child: _PaymentChannelTile(
                      channel: channel,
                      selected: isSelected,
                      subtitle: subtitle,
                      isDisabled: isWalletInsufficient,
                      onTap: () {
                        if (isWalletInsufficient) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Insufficient wallet balance. You need \$${cartTotal.toStringAsFixed(2)} but only have \$${walletBalance.toStringAsFixed(2)}',
                              ),
                              backgroundColor: UIColors.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          onChannelSelected(channel);
                        }
                      },
                    ),
                  ),
                  // Show gift card input field when gift card is selected
                  if (channel.isGiftCard && isSelected) ...[
                    const SizedBox(height: UISpacing.s12),
                    _GiftCardInputField(
                      controller: giftCardController,
                      onChanged: onGiftCardChanged,
                    ),
                    if (index < channels.length - 1)
                      const SizedBox(height: UISpacing.s12),
                  ],
                ],
              );
            }).toList(),
        ),
      ],
    );
  }
}

/// Gift card input field widget
class _GiftCardInputField extends StatelessWidget {
  const _GiftCardInputField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UIColors.divider.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(UIRadius.r8),
        border: Border.all(color: UIColors.divider),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          hintText: 'Enter gift card code',
          hintStyle: const TextStyle(
            color: UIColors.textMuted,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.card_giftcard_outlined,
            color: UIColors.primary,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIRadius.r8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        style: const TextStyle(
          color: UIColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textCapitalization: TextCapitalization.characters,
      ),
    );
  }
}

class _PaymentChannelsLoading extends StatelessWidget {
  const _PaymentChannelsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index < 2 ? UISpacing.s12 : 0),
          child: Container(
            height: UISpacing.rowHeight52,
            decoration: BoxDecoration(
              color: UIColors.divider.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(UIRadius.r12),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: UIColors.primary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PaymentChannelTile extends StatelessWidget {
  const _PaymentChannelTile({
    required this.channel,
    required this.selected,
    required this.subtitle,
    required this.onTap,
    this.isDisabled = false,
  });

  final PaymentChannel channel;
  final bool selected;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDisabled;

  IconData _getChannelIcon() {
    if (channel.isWallet) return Icons.account_balance_wallet_outlined;
    if (channel.isGiftCard) return Icons.card_giftcard_outlined;
    return Icons.credit_card_outlined;
  }

  @override
  Widget build(BuildContext context) {
    // Grey out colors when disabled
    final Color fg = isDisabled 
        ? UIColors.textSecondary.withOpacity(0.5) 
        : (selected ? Colors.white : UIColors.textPrimary);
    final Color subFg = isDisabled 
        ? UIColors.textSecondary.withOpacity(0.4) 
        : (selected ? Colors.white : UIColors.textSecondary);
    final Color iconColor = isDisabled 
        ? UIColors.iconMuted.withOpacity(0.4) 
        : (selected ? Colors.white : UIColors.iconMuted);

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: SizedBox(
      height: UISpacing.rowHeight52,
      child: Material(
          color: isDisabled 
              ? Colors.grey.shade100 
              : (selected ? UIColors.primary : Colors.transparent),
        borderRadius: BorderRadius.circular(UIRadius.r12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UIRadius.r12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(UIRadius.r12),
                border: selected && !isDisabled ? null : Border.all(
                  color: isDisabled ? Colors.grey.shade300 : UIColors.divider,
                ),
              ),
            padding: const EdgeInsets.symmetric(horizontal: UISpacing.s12),
            child: Row(
              children: [
                // Channel logo or icon
                if (channel.logo != null && channel.logo!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      channel.logo!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        _getChannelIcon(),
                        size: 24,
                        color: iconColor,
                      ),
                    ),
                  )
                else
                  Icon(_getChannelIcon(), size: 24, color: iconColor),
                const SizedBox(width: UISpacing.s12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 18 / 14,
                          color: fg,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 14 / 12,
                          color: subFg.withValues(alpha: selected ? 0.95 : 1.0),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: UISpacing.s12),

                _RadioIndicator(selected: selected),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color stroke = selected ? Colors.white : UIColors.divider;
    final Color fill = selected ? Colors.white : Colors.transparent;
    final Color dot = selected ? UIColors.primary : Colors.transparent;

    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: stroke, width: 2),
              color: fill.withValues(alpha: selected ? 0.15 : 0.0),
            ),
          ),
          if (selected)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dot,
              ),
            ),
        ],
      ),
    );
  }
}

class _PayableAmountRow extends StatelessWidget {
  const _PayableAmountRow({
    required this.payableAmount,
    required this.discountAmount,
  });

  final double payableAmount;
  final double discountAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (discountAmount > 0) ...[
          Row(
            children: [
              const Expanded(
                child: Text('Discount:', style: UITextStyles.body14RegularSecondary),
              ),
              Text(
                '-\$${discountAmount.toStringAsFixed(2)}',
                style: UITextStyles.body14MediumPrimary.copyWith(color: UIColors.success),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            const Expanded(
          child: Text(
            'Payable Amount:',
            style: UITextStyles.body14RegularSecondary,
          ),
        ),
        Text(
              '\$${payableAmount.toStringAsFixed(2)}',
              style: UITextStyles.body14MediumPrimary.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null && !widget.isLoading;
    
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
        setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        height: UISpacing.buttonHeight52,
        decoration: BoxDecoration(
          color: enabled
              ? (_pressed ? UIColors.primaryPressed : UIColors.primary)
              : UIColors.primary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(UIRadius.r12),
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(widget.text, style: UITextStyles.button16SemiboldWhite),
      ),
    );
  }
}

/* ===========================
   BUNDLE PAYMENT WEBVIEW WRAPPER
   =========================== */

/// Wrapper widget that handles the payment WebView for bundle purchases
/// and processes the transaction after payment completion
class _BundlePaymentWebViewWrapper extends StatefulWidget {
  final String paymentUrl;
  final String? transactionId;
  final CheckoutRepository checkoutRepo;
  final String bundleName;

  const _BundlePaymentWebViewWrapper({
    required this.paymentUrl,
    this.transactionId,
    required this.checkoutRepo,
    required this.bundleName,
  });

  @override
  State<_BundlePaymentWebViewWrapper> createState() => _BundlePaymentWebViewWrapperState();
}

class _BundlePaymentWebViewWrapperState extends State<_BundlePaymentWebViewWrapper> {
  bool _isProcessing = false;
  String? _paymentStatus;

  void _handlePaymentComplete(String transactionId) {
    if (_isProcessing) return;
    
    if (kDebugMode) {
      debugPrint('✅ Bundle payment completed, transactionId: $transactionId');
      debugPrint('   - paymentStatus: $_paymentStatus');
    }
    
    _processTransaction(transactionId);
  }

  Future<void> _processTransaction(String transactionId) async {
    setState(() => _isProcessing = true);
    
    if (kDebugMode) {
      debugPrint('💳 Processing bundle transaction: $transactionId');
    }
    
    final result = await widget.checkoutRepo.processTransaction(
      transactionId,
      paymentStatus: _paymentStatus,
    );
    
    if (!mounted) return;
    
    setState(() => _isProcessing = false);
    
    if (result.success) {
      if (kDebugMode) {
        debugPrint('✅ Bundle transaction processed successfully');
        if (result.isPartialSuccess) {
          debugPrint('   ⚠️ Partial success - payment OK but backend processing pending');
        }
      }
      
      // Navigate to success screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _BundlePurchaseSuccessScreen(
            bundleName: widget.bundleName,
            transactionId: transactionId,
            message: result.message,
            isPartialSuccess: result.isPartialSuccess,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: UIColors.danger,
        ),
      );
      // Go back on error
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return Scaffold(
        backgroundColor: UIColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(UIColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Processing your purchase...',
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

    return PaymentWebViewScreen(
      paymentUrl: widget.paymentUrl,
      transactionId: widget.transactionId,
      onPaymentComplete: _handlePaymentComplete,
      onStatusExtracted: (status) {
        // Capture the payment status from callback URL
        if (kDebugMode) {
          debugPrint('📋 Payment status extracted: $status');
        }
        _paymentStatus = status;
      },
    );
  }
}

/* ===========================
   BUNDLE PURCHASE SUCCESS SCREEN
   =========================== */

/// Success screen shown after a bundle purchase is completed
class _BundlePurchaseSuccessScreen extends StatelessWidget {
  final String bundleName;
  final String transactionId;
  final String message;
  final bool isPartialSuccess;
  final bool isGiftCardPayment;

  const _BundlePurchaseSuccessScreen({
    required this.bundleName,
    required this.transactionId,
    required this.message,
    this.isPartialSuccess = false,
    this.isGiftCardPayment = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: UIColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: UIColors.success,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Purchase Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: UIColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: UIColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Bundle name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: UIColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: UIColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sim_card,
                      color: UIColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        bundleName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: UIColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (isPartialSuccess) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your eSIM will be activated shortly. You can check your eSIMs in the My eSIMs section.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Transaction ID
              Text(
                'Transaction ID: $transactionId',
                style: const TextStyle(
                  fontSize: 12,
                  color: UIColors.textMuted,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Go to Home button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // View My eSIMs button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to My eSIMs screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: UIColors.primary,
                    side: const BorderSide(color: UIColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View My eSIMs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
