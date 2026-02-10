import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_bloc.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_event.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_state.dart';
import 'package:tellgo_app/models/wallet_models.dart';
import 'package:tellgo_app/screens/profile/user_header.dart';
import 'package:tellgo_app/widgets/go_points_user_header.dart';
import 'package:tellgo_app/widgets/go_points_transaction_history.dart'
    as go_points_transaction_history;
import 'package:tellgo_app/screens/wallet/wallet_channel_selection_screen.dart';

/// Top-up / Balance screen recreated from the provided screenshot.
///
/// DESIGN INTENT (matches the "theory" described):
/// - Base design width: 360px (typical Android)
/// - Light gray page background
/// - Fixed (non-scroll) main content with an INTERNAL scrollable Transaction History list
/// - 3x3 grid of top-up cards with a -50% chip overlaid at top center
/// - Purple primary buttons: Proceed + Transaction History header bar
///
/// NOTE:
/// - Font: If you have Inter in your app, set ThemeData fontFamily to 'Inter'.
///   This file does not force a font family to avoid runtime font issues.
///
/// USAGE:
/// - Put this file anywhere and route to TopUpScreen().
/// - Uses the app-level WalletBloc provided in AppBlocProvider
class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenWrapperState();
}

class _TopUpScreenWrapperState extends State<TopUpScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh wallet data when screen is opened
    // WalletBloc is provided at app level in AppBlocProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WalletBloc>().add(const LoadWalletData());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _TopUpScreenContent();
  }
}

class _TopUpScreenContent extends StatefulWidget {
  const _TopUpScreenContent();

  @override
  State<_TopUpScreenContent> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<_TopUpScreenContent> {
  final TextEditingController _customAmountCtrl = TextEditingController();
  int? _selectedOptionIndex;
  List<PaymentChannel> _availablePaymentChannels = [];

  @override
  void dispose() {
    _customAmountCtrl.dispose();
    super.dispose();
  }

  void _extractPaymentChannels(List<WalletDenomination> denominations) {
    // Extract unique payment channels from denominations
    final Set<String> channelCodes = {};
    final Map<String, String> channelNames = {};
    
    for (final denom in denominations) {
      if (denom.paymentChannels != null) {
        for (final channel in denom.paymentChannels!) {
          if (channel.isActive) {
            channelCodes.add(channel.code);
            channelNames[channel.code] = channel.name;
          }
        }
      }
    }
    
    // If no channels found in denominations, use default
    if (channelCodes.isEmpty) {
      _availablePaymentChannels = [
        const PaymentChannel(code: 'MyFatoorah', name: 'MyFatoorah'),
      ];
      if (kDebugMode) {
        debugPrint('💰 No payment channels found, using default: MyFatoorah');
      }
    } else {
      _availablePaymentChannels = channelCodes.map((code) {
        return PaymentChannel(
          code: code,
          name: channelNames[code] ?? code,
        );
      }).toList();
    }
    
    if (kDebugMode) {
      debugPrint('💰 Available payment channels: ${_availablePaymentChannels.map((c) => c.code).toList()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        // Handle transaction processing success - refresh balance and transactions
        if (state is WalletProcessTransactionSuccess) {
          if (kDebugMode) {
            debugPrint('✅ Wallet transaction processed successfully');
            debugPrint('   - newBalance: ${state.response.newBalance}');
          }
          // Refresh balance and transactions
          context.read<WalletBloc>().add(const RefreshWalletBalance());
          context.read<WalletBloc>().add(const RefreshWalletTransactions());
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
        // ---- Base scaling (521px design width - matching go_points_screen) ----
        final w = MediaQuery.of(context).size.width;
        final scale = w / 521.0;

        double s(double px) => px * scale;

        // Padding rules: 24px normally; 16px on very small screens (<= 340w)
        final horizontalPadding = w <= 340 ? s(16) : s(24);

        // Keep content centered with a max width so it doesn't stretch too much on wide phones
        final maxContentWidth = s(400);

        // Get data from state
        final balance = state.balance;
        final balanceText = balance != null
            ? '${balance.balance.toStringAsFixed(2)} ${balance.currency ?? 'KD'}'
            : '0.00 KD';

        // Convert wallet transactions to GoPointsTransactionHistory format
        final convertedTransactions = state.transactions.map((tx) {
          return go_points_transaction_history.TransactionItem(
            title: tx.title ?? tx.description ?? 'Transaction',
            time: tx.transactionDate != null
                ? '${tx.transactionDate!.day}-${tx.transactionDate!.month}-${tx.transactionDate!.year}, ${tx.transactionDate!.hour}:${tx.transactionDate!.minute.toString().padLeft(2, '0')} ${tx.transactionDate!.hour < 12 ? 'AM' : 'PM'}'
                : 'N/A',
            pointsDelta: tx.pointsDelta ?? (tx.amount?.toInt() ?? 0),
          );
        }).toList();

        // Extract payment channels from denominations (only once)
        if (state.denominations.isNotEmpty && _availablePaymentChannels.isEmpty) {
          _extractPaymentChannels(state.denominations);
        }
        
        // Convert denominations to TopUpOption format
        final topUpOptions = state.denominations
            .map((denom) => TopUpOption(
                  buyKd: denom.buyAmount.toInt(),
                  getKd: denom.getAmount.toInt(),
                  discountText: denom.discountText ?? '-50%',
                  denominationId: denom.denominationId,
                ))
            .toList();

        // Check if loading
        final isLoading = state is WalletLoading || state is WalletInitial;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: true,
            bottom: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Common header at the top - always visible
                const CommonAppHeader(
                  includeSafeAreaTop: false,
                ),
                
                // Show shimmer or content based on loading state
                Expanded(
                  child: isLoading
                      ? _WalletLoadingShimmer(
                          scale: scale,
                          horizontalPadding: horizontalPadding,
                        )
                      : _buildWalletContent(
                          context,
                          state,
                          scale,
                          horizontalPadding,
                          maxContentWidth,
                          balanceText,
                          topUpOptions,
                          convertedTransactions,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canProceed() {
    final hasCustom = _customAmountCtrl.text.trim().isNotEmpty;
    final hasPreset = _selectedOptionIndex != null;
    return hasCustom || hasPreset;
  }

  Widget _buildWalletContent(
    BuildContext context,
    WalletState state,
    double scale,
    double horizontalPadding,
    double maxContentWidth,
    String balanceText,
    List<TopUpOption> topUpOptions,
    List<go_points_transaction_history.TransactionItem> convertedTransactions,
  ) {
    double s(double px) => px * scale;

    // Get user name from AuthBloc
    final authState = context.read<AuthBloc>().state;
    final userName = authState.user?.name ?? 'User';

    final headerBlock = GoPointsUserHeader(
      userName: userName,
      points: '0', // Points can be calculated from transactions if needed
      balance: balanceText,
      scale: scale,
      walletStyle: true, // Use simplified wallet layout
    );

    final topUpControls = _TopUpControls(
      scale: scale,
      horizontalPadding: horizontalPadding,
      contentWidth: maxContentWidth,
      controller: _customAmountCtrl,
      options: topUpOptions,
      selectedIndex: _selectedOptionIndex,
      isLoading: state.isToppingUp || state.isProcessingTransaction,
      onSelectOption: (i) {
        setState(() {
          if (i < 0) {
            _selectedOptionIndex = null;
          } else {
            _selectedOptionIndex = i;
            // Clear custom amount when selecting preset
            _customAmountCtrl.clear();
          }
        });
      },
      onCustomAmountChanged: () {
        // Trigger rebuild to update canProceed state
        setState(() {
          // Clear selection when typing custom amount
          if (_customAmountCtrl.text.trim().isNotEmpty) {
            _selectedOptionIndex = null;
          }
        });
      },
      onProceed: () => _onProceed(context, topUpOptions, state.denominations),
      canProceed: _canProceed(),
    );

    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        // Calculate available height for transaction history
        final screenHeight = MediaQuery.of(context).size.height;
        final safeAreaTop = MediaQuery.of(context).padding.top;
        final safeAreaBottom = MediaQuery.of(context).padding.bottom;
        final availableViewportHeight = screenHeight - safeAreaTop - safeAreaBottom;
        
        // Estimate height of content above transaction history
        final estimatedHeaderHeight = s(10) + s(172) + s(12);
        final estimatedTopUpHeight = s(12) + s(200) + s(12);
        final estimatedAboveHeight = estimatedHeaderHeight + estimatedTopUpHeight + s(12);
        
        // Transaction history gets remaining space
        final transactionHistoryHeight = (availableViewportHeight - estimatedAboveHeight).clamp(s(200), availableViewportHeight * 0.6);
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: s(10)),
              headerBlock,
              SizedBox(height: s(12)),
              _SoftDivider(scale: scale),
              SizedBox(height: s(12)),
              topUpControls,
              // Transaction History widget
              SizedBox(
                height: transactionHistoryHeight,
                child: go_points_transaction_history.GoPointsTransactionHistory(
                  transactions: convertedTransactions,
                  scale: scale,
                  sidePadding: 66.0,
                  scrollRailWidth: 65.0,
                  trackLeftInset: 20.0,
                  trackWidth: 7.0,
                  initialExpanded: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onProceed(BuildContext context, List<TopUpOption> options, List<WalletDenomination> denominations) {
    final hasCustom = _customAmountCtrl.text.trim().isNotEmpty;
    final selected = _selectedOptionIndex;

    // Get available channel codes
    final channelCodes = _availablePaymentChannels.map((c) => c.code).toList();
    
    if (channelCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No payment channels available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (hasCustom) {
      final customAmount = double.tryParse(_customAmountCtrl.text.trim());
      if (customAmount == null || customAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }
      
      if (kDebugMode) {
        debugPrint('💰 Navigating to channel selection with custom amount: $customAmount');
      }
      
      // Navigate to channel selection screen with custom amount
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<WalletBloc>(),
            child: WalletChannelSelectionScreen(
              args: WalletChannelSelectionArgs(
                customAmount: customAmount,
                channelCodes: channelCodes,
                currency: 'KWD',
              ),
            ),
          ),
        ),
      );
    } else if (selected != null && selected < options.length && selected < denominations.length) {
      final opt = options[selected];
      final denom = denominations[selected];
      
      if (kDebugMode) {
        debugPrint('💰 Navigating to channel selection with denomination: ${opt.buyKd} KD');
      }
      
      // Navigate to channel selection screen with denomination
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<WalletBloc>(),
            child: WalletChannelSelectionScreen(
              args: WalletChannelSelectionArgs(
                denomination: denom,
                channelCodes: channelCodes,
                currency: denom.currency ?? 'KWD',
              ),
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an amount or enter a custom amount')),
      );
    }
  }
}

/// ====== TOKENS (mini design system) ======
class AppTokens {
  // Backgrounds
  static const Color bgPage = Color(0xFFF8F8F8);
  static const Color surface = Color(0xFFFFFFFF);

  // Primary
  static const Color primaryPurple = Color(0xFF8530A0);

  // Borders / dividers
  static const Color borderLavender = Color(0xFFDFD2E3);
  static const Color borderNeutral = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFDCDCDC);

  // Text
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6F6F6F);
  static const Color textTertiary = Color(0xFF9A9A9A);

  // Status
  static const Color successGreen = Color(0xFF02C860);
  static const Color errorRed = Color(0xFFFA0444);
}

/// ====== TOP-UP CONTROLS (Custom field + grid + proceed) ======
class _TopUpControls extends StatelessWidget {
  final double scale;
  final double horizontalPadding;
  final double contentWidth;

  final TextEditingController controller;
  final List<TopUpOption> options;
  final int? selectedIndex;

  final ValueChanged<int> onSelectOption;
  final VoidCallback? onCustomAmountChanged;
  final VoidCallback onProceed;
  final bool canProceed;
  final bool isLoading;

  const _TopUpControls({
    required this.scale,
    required this.horizontalPadding,
    required this.contentWidth,
    required this.controller,
    required this.options,
    required this.selectedIndex,
    required this.onSelectOption,
    this.onCustomAmountChanged,
    required this.onProceed,
    required this.canProceed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CustomAmountField(
            scale: scale,
            controller: controller,
            onChanged: () {
              // Notify parent about custom amount change
              onCustomAmountChanged?.call();
            },
          ),
          SizedBox(height: s(12)),
          Text(
            'Select Top Up Amount',
            style: TextStyle(
              fontSize: s(10),
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: AppTokens.textPrimary,
            ),
          ),
          SizedBox(height: s(10)),
          _TopUpGrid(
            scale: scale,
            options: options,
            selectedIndex: selectedIndex,
            onSelect: onSelectOption,
          ),
          SizedBox(height: s(14)),
          Center(
            child: isLoading
                ? SizedBox(
                    width: s(225),
                    height: s(29),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : _PrimaryButton(
                    scale: scale,
                    text: 'Proceed',
                    onTap: canProceed ? onProceed : null,
                    // Screenshot shows a relatively compact button.
                    width: s(225),
                    height: s(29),
                    radius: s(8),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Custom top-up field - simple text field with suffix
class _CustomAmountField extends StatelessWidget {
  final double scale;
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const _CustomAmountField({
    required this.scale,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        fontSize: s(14),
        color: AppTokens.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Custom Top Up Amount',
        hintStyle: TextStyle(
          fontSize: s(14),
          color: AppTokens.textTertiary,
        ),
        suffixText: 'KD',
        suffixStyle: TextStyle(
          fontSize: s(14),
          fontWeight: FontWeight.w600,
          color: AppTokens.textSecondary,
        ),
      ),
      onChanged: (_) {
        onChanged?.call();
      },
    );
  }
}

/// ====== GRID (3x3) ======
class _TopUpGrid extends StatelessWidget {
  final double scale;
  final List<TopUpOption> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _TopUpGrid({
    required this.scale,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    // Exact columns = 3 as per screenshot.
    const crossAxisCount = 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: s(35),
        crossAxisSpacing: s(35),
        // Compact rectangular cards.
        childAspectRatio: 1.15, // width/height; tweak to match your render
      ),
      itemBuilder: (context, i) {
        final opt = options[i];
        final isSelected = selectedIndex == i;
        return _TopUpOptionCard(
          scale: scale,
          option: opt,
          selected: isSelected,
          onTap: () => onSelect(i),
        );
      },
    );
  }
}

/// Each card:
/// - White surface + border
/// - Stack overlay chip "-50%" at top-center overlapping the card.
class _TopUpOptionCard extends StatelessWidget {
  final double scale;
  final TopUpOption option;
  final bool selected;
  final VoidCallback onTap;

  const _TopUpOptionCard({
    required this.scale,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    final borderColor = selected ? AppTokens.primaryPurple : AppTokens.borderNeutral;
    final fillColor = selected
        ? AppTokens.primaryPurple.withOpacity(0.04)
        : AppTokens.bgPage;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(s(8)),
            child: Ink(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(s(8)),
                border: Border.all(color: borderColor, width: s(1.2)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(s(8), s(12), s(8), s(8)),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Buy ${option.buyKd} KD',
                        style: TextStyle(
                          fontSize: s(16),
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: AppTokens.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: s(4)),
                      Text(
                        'Get ${option.getKd} KD',
                        style: TextStyle(
                          fontSize: s(16),
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: AppTokens.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -s(9),
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: s(10), vertical: s(3)),
              decoration: BoxDecoration(
                color: AppTokens.primaryPurple,
                borderRadius: BorderRadius.circular(s(10)),
              ),
              child: Text(
                option.discountText,
                style: TextStyle(
                  fontSize: s(9),
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  color: Colors.white,
                  letterSpacing: s(0.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ====== PRIMARY BUTTON (Proceed) ======
class _PrimaryButton extends StatelessWidget {
  final double scale;
  final String text;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double radius;

  const _PrimaryButton({
    required this.scale,
    required this.text,
    required this.onTap,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: enabled
                ? AppTokens.primaryPurple
                : AppTokens.primaryPurple.withOpacity(0.40),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: s(11),
                fontWeight: FontWeight.w800,
                height: 1.0,
                color: Colors.white.withOpacity(enabled ? 1 : 0.85),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ====== Soft divider (thin line across content) ======
class _SoftDivider extends StatelessWidget {
  final double scale;
  const _SoftDivider({required this.scale});

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(24)),
      child: Container(
        height: s(1),
        color: AppTokens.divider.withOpacity(0.9),
      ),
    );
  }
}

/// ====== MODELS ======
class TopUpOption {
  final int buyKd;
  final int getKd;
  final String discountText;
  final int denominationId;

  const TopUpOption({
    required this.buyKd,
    required this.getKd,
    required this.discountText,
    this.denominationId = 0,
  });
}

class TransactionItem {
  final bool isPositive;
  final String title;
  final String subtitle;
  final String pointsText;

  const TransactionItem({
    required this.isPositive,
    required this.title,
    required this.subtitle,
    required this.pointsText,
  });
}

/* ------------------------------ LOADING SHIMMER ------------------------------ */

class _WalletLoadingShimmer extends StatefulWidget {
  const _WalletLoadingShimmer({
    required this.scale,
    required this.horizontalPadding,
  });

  final double scale;
  final double horizontalPadding;

  @override
  State<_WalletLoadingShimmer> createState() => _WalletLoadingShimmerState();
}

class _WalletLoadingShimmerState extends State<_WalletLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  double s(double px) => px * widget.scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: s(10)),
              
              // User header shimmer
              Container(
                height: s(120),
                width: double.infinity,
                color: const Color(0xFFF1F1F1),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User name shimmer
                      _ShimmerBox(
                        controller: _shimmerController,
                        width: s(180),
                        height: s(24),
                        borderRadius: s(4),
                      ),
                      SizedBox(height: s(16)),
                      // Balance label shimmer
                      _ShimmerBox(
                        controller: _shimmerController,
                        width: s(60),
                        height: s(14),
                        borderRadius: s(4),
                      ),
                      SizedBox(height: s(8)),
                      // Balance value shimmer
                      _ShimmerBox(
                        controller: _shimmerController,
                        width: s(120),
                        height: s(20),
                        borderRadius: s(4),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: s(12)),
              
              // Divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(24)),
                child: Container(
                  height: s(1),
                  color: AppTokens.divider.withOpacity(0.9),
                ),
              ),
              
              SizedBox(height: s(12)),

              // Top-up controls shimmer
              Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom amount field shimmer
                    _ShimmerBox(
                      controller: _shimmerController,
                      height: s(48),
                      borderRadius: s(8),
                    ),

                    SizedBox(height: s(12)),

                    // "Select Top Up Amount" label shimmer
                    _ShimmerBox(
                      controller: _shimmerController,
                      width: s(120),
                      height: s(12),
                      borderRadius: s(4),
                    ),

                    SizedBox(height: s(10)),

                    // Top-up grid shimmer (3x3)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 9,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: s(35),
                        crossAxisSpacing: s(35),
                        childAspectRatio: 1.15,
                      ),
                      itemBuilder: (context, index) => _ShimmerBox(
                        controller: _shimmerController,
                        borderRadius: s(8),
                      ),
                    ),

                    SizedBox(height: s(14)),

                    // Proceed button shimmer
                    Center(
                      child: _ShimmerBox(
                        controller: _shimmerController,
                        width: s(225),
                        height: s(29),
                        borderRadius: s(8),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: s(24)),

              // Transaction history header shimmer
              Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                child: _ShimmerBox(
                  controller: _shimmerController,
                  height: s(48),
                  borderRadius: s(24),
                ),
              ),

              SizedBox(height: s(16)),

              // Transaction items shimmer
              Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                child: Column(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: s(12)),
                      child: Row(
                        children: [
                          _ShimmerBox(
                            controller: _shimmerController,
                            width: s(40),
                            height: s(40),
                            borderRadius: s(20),
                          ),
                          SizedBox(width: s(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ShimmerBox(
                                  controller: _shimmerController,
                                  height: s(16),
                                  borderRadius: s(4),
                                ),
                                SizedBox(height: s(4)),
                                _ShimmerBox(
                                  controller: _shimmerController,
                                  width: s(100),
                                  height: s(12),
                                  borderRadius: s(4),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: s(12)),
                          _ShimmerBox(
                            controller: _shimmerController,
                            width: s(60),
                            height: s(16),
                            borderRadius: s(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.controller,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  final AnimationController controller;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final shimmerValue = controller.value;
        final gradient = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: [
            (shimmerValue - 0.3).clamp(0.0, 1.0),
            shimmerValue.clamp(0.0, 1.0),
            (shimmerValue + 0.3).clamp(0.0, 1.0),
          ],
        );

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }
}

