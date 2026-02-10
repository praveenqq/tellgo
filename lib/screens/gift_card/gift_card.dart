import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/models/gift_card_models.dart';
import 'package:tellgo_app/repository/gift_card_repository.dart';
import 'package:tellgo_app/screens/gift_card/channel_selection.dart';
import 'package:tellgo_app/screens/gift_card/gift_card_bloc.dart';
import 'package:tellgo_app/screens/gift_card/gift_card_event.dart';
import 'package:tellgo_app/screens/gift_card/gift_card_payment_success_screen.dart';
import 'package:tellgo_app/screens/gift_card/gift_card_state.dart';
import 'package:tellgo_app/screens/profile/user_header.dart';
// Note: Payment WebView is now handled in channel_selection.dart
import 'package:tellgo_app/widgets/go_points_transaction_history.dart'
    as go_points_transaction_history;

/// Gift Card Screen (pixel-focused implementation)
/// - Base design width: 521px (matching go_points_screen)
/// - Spacing: 4/8/12/16/20/24
/// - Radius: 12px
/// - Primary: #7B2C8F
/// - Grid: 3 columns, 12px spacing
///
/// NOTE:
/// This is built to be extremely close to the spec I described:
/// - No elevations/shadows
/// - Flat surfaces
/// - Exact paddings/heights
/// - Ellipsis rules
class GiftCardScreen extends StatelessWidget {
  const GiftCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide GiftCardBloc if not already provided
    return BlocProvider(
      create: (context) => GiftCardBloc(
        giftCardRepository: GiftCardRepositoryImpl(AppDio()),
      )..add(const LoadGiftCardData(countryId: 92)),
      child: const _GiftCardScreenContent(),
    );
  }
}

class _GiftCardScreenContent extends StatefulWidget {
  const _GiftCardScreenContent();

  @override
  State<_GiftCardScreenContent> createState() => _GiftCardScreenState();
}

enum GiftRecipientType { myself, someoneElse }

class _GiftCardScreenState extends State<_GiftCardScreenContent> {
  int? _selectedDenominationId;
  GiftRecipientType _recipientType = GiftRecipientType.myself;
  
  // Text controllers for recipient details
  final _recipientNameController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _recipientMessageController = TextEditingController();
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientEmailController.dispose();
    _recipientMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final scale = w / 521.0;

    double s(double px) => px * scale;

    // Primary left inset observed ~66px on 521px wide screenshot.
    final sidePad = _clampDouble(s(66), 24, 70);

    // Colors (tokens)
    const bg = Color(0xFFFFFFFF);
    const textSecondary = Color(0xFF7E7F7F);

    // Typography (matching go_points_screen)
    final appTitle = TextStyle(
      fontSize: s(16),
      fontWeight: FontWeight.w700,
      height: 20 / 16,
      color: Colors.black,
    );
    final sectionSubtitle = TextStyle(
      fontSize: s(13),
      fontWeight: FontWeight.w400,
      height: 18 / 13,
      color: textSecondary,
    );

    return BlocConsumer<GiftCardBloc, GiftCardState>(
      listener: (context, state) {
        // Handle process transaction success (when returning from payment)
        if (state is GiftCardProcessTransactionSuccess) {
          if (kDebugMode) {
            debugPrint('🎉 Gift card transaction processed successfully');
            debugPrint('   - transactionId: ${state.response.transactionId}');
            debugPrint('   - giftCardCode: ${state.response.giftCardCode}');
            debugPrint('   - amount: ${state.response.amount} ${state.response.currency}');
          }
          
          // Use post-frame callback to avoid navigator lock issues
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // Navigate to payment success screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GiftCardPaymentSuccessScreen(
                    response: state.response,
                    // Denomination info is not available here after navigation
                    // It will use the response data instead
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
        // Convert denominations to amounts for display
        final denominations = state.denominations
            .where((d) => d.isActive)
            .toList();
        
        // Convert purchase history to transaction items
        final transactions = state.purchaseHistory
            .map((p) => go_points_transaction_history.TransactionItem(
                  title: 'Gift Card Purchase - ${p.denomination ?? "${p.amount} ${p.currency ?? "KWD"}"}',
                  time: _formatDate(p.createdDate),
                  pointsDelta: -p.amount.toInt(),
                ))
            .toList();

        // Show loading shimmer while data is loading
        final isLoading = state.isLoading || state.isLoadingDenominations;

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            top: true,
            bottom: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Common header at the top - balance fetched from WalletBloc
                const CommonAppHeader(
                  includeSafeAreaTop: false,
                ),

                // Title row
                Padding(
                  padding: EdgeInsets.only(
                    left: sidePad,
                    right: sidePad,
                    top: s(27),
                  ),
                  child: Text('Gift Card', style: appTitle),
                ),

                SizedBox(height: s(6)),

                // Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePad),
                  child: Text(
                    'Surprise someone with a gift card',
                    style: sectionSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: s(20)),

                // Show shimmer loading or content
                if (isLoading)
                  Expanded(
                    child: _GiftCardLoadingShimmer(
                      sidePad: sidePad,
                      scale: scale,
                    ),
                  )
                else ...[
                // Amount grid with side padding
                  if (denominations.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePad),
                    child: Center(
                      child: Text(
                        'No gift card denominations available',
                        style: sectionSubtitle,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePad),
                    child: _AmountGrid(
                      denominations: denominations,
                      selectedDenominationId: _selectedDenominationId,
                      gap: s(12),
                      scale: scale,
                      onTapDenomination: (id) =>
                          setState(() => _selectedDenominationId = id),
                    ),
                  ),

                  SizedBox(height: s(20)),

                  // Radio buttons for recipient selection
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePad),
                    child: _RecipientTypeSelector(
                      selectedType: _recipientType,
                      scale: scale,
                      onChanged: (type) {
                        setState(() {
                          _recipientType = type;
                          // Clear fields when switching to myself
                          if (type == GiftRecipientType.myself) {
                            _recipientNameController.clear();
                            _recipientEmailController.clear();
                            _recipientMessageController.clear();
                          }
                        });
                      },
                    ),
                  ),

                // Recipient details form (only shown for "someone else")
                if (_recipientType == GiftRecipientType.someoneElse) ...[
                  SizedBox(height: s(16)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePad),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ThemedTextField(
                            controller: _recipientNameController,
                            label: "Recipient's Name",
                            hint: "Enter recipient's name",
                            scale: scale,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Recipient's name is required";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: s(12)),
                          _ThemedTextField(
                            controller: _recipientEmailController,
                            label: 'Email Address',
                            hint: "Enter recipient's email",
                            keyboardType: TextInputType.emailAddress,
                            scale: scale,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email address is required';
                              }
                              // Simple email validation
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: s(12)),
                          _ThemedTextField(
                            controller: _recipientMessageController,
                            label: 'Message (Optional)',
                            hint: 'Add a personal message',
                            maxLines: 3,
                            scale: scale,
                            validator: null, // Optional field
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                SizedBox(height: s(24)),

                // Proceed button with side padding
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePad),
                  child: SizedBox(
                    width: double.infinity,
                    height: s(48),
                    child: _PrimaryButton(
                      label: state.isPurchasing ? 'Processing...' : 'Proceed',
                      scale: scale,
                      onPressed: state.isPurchasing ||
                              _selectedDenominationId == null
                          ? null
                          : () {
                              // Validate form if gifting to someone else
                              if (_recipientType == GiftRecipientType.someoneElse) {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                              }
                              
                              // Safety check: verify the denomination still exists
                              final matchingDenominations = denominations.where(
                                (d) => d.id == _selectedDenominationId,
                              );
                              
                              if (matchingDenominations.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a denomination'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                setState(() => _selectedDenominationId = null);
                                return;
                              }
                              
                              final selectedDenomination = matchingDenominations.first;
                              
                              // Get recipient details based on selection
                              final recipientName = _recipientType == GiftRecipientType.someoneElse
                                  ? _recipientNameController.text.trim()
                                  : null;
                              final recipientEmail = _recipientType == GiftRecipientType.someoneElse
                                  ? _recipientEmailController.text.trim()
                                  : null;
                              final recipientMessage = _recipientType == GiftRecipientType.someoneElse &&
                                      _recipientMessageController.text.trim().isNotEmpty
                                  ? _recipientMessageController.text.trim()
                                  : null;
                              
                              // Get available channel codes and infos
                              final channelCodes = state.availableChannelCodes;
                              final channelInfos = state.availableChannelInfos;
                              
                              if (channelCodes.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No payment channels available'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              // Navigate to channel selection screen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<GiftCardBloc>(),
                                    child: GiftCardChannelSelectionScreen(
                                      args: GiftCardChannelSelectionArgs(
                                        denomination: selectedDenomination,
                                        channelCodes: channelCodes,
                                        channelInfos: channelInfos,
                                        recipientName: recipientName,
                                        recipientEmail: recipientEmail,
                                        recipientMessage: recipientMessage,
                                      ),
                                    ),
                                      ),
                                    ),
                                  );
                            },
                    ),
                  ),
                ),

                // Transaction History widget
                Expanded(
                  child: go_points_transaction_history.GoPointsTransactionHistory(
                    transactions: transactions,
                    scale: scale,
                    sidePadding: 66.0,
                    scrollRailWidth: 65.0,
                    trackLeftInset: 20.0,
                    trackWidth: 7.0,
                    initialExpanded: true,
                  ),
                ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  double _clampDouble(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final day = date.day;
    final month = date.month;
    final year = date.year;
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$day-$month-$year, $hour:$minute $period';
  }
}

/* ------------------------------ THEME ------------------------------ */

class GiftCardTheme {
  final _GiftCardColors colors;
  final _GiftCardText text;
  final _GiftCardRadii radii;

  GiftCardTheme._(this.colors, this.text, this.radii);

  static GiftCardTheme of(BuildContext context) {
    // Keep it self-contained (no need to wire ThemeData unless you want).
    const colors = _GiftCardColors();
    final text = _GiftCardText(colors);
    const radii = _GiftCardRadii();
    return GiftCardTheme._(colors, text, radii);
  }
}

class _GiftCardColors {
  const _GiftCardColors();

  final Color background = const Color(0xFFFFFFFF);

  // Surfaces
  final Color surfaceLight = const Color(0xFFF6F6F6);
  final Color surfaceWhite = const Color(0xFFFFFFFF);

  // Primary brand
  final Color primaryPurple = const Color(0xFF7B2C8F);
  final Color primaryPurpleDark = const Color(0xFF5E1F6E);

  // Text
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF6B6B6B);
  final Color disabled = const Color(0xFFBDBDBD);

  // Lines
  final Color divider = const Color(0xFFE5E5E5);

  // Status
  final Color success = const Color(0xFF1DB954);
  final Color error = const Color(0xFFE53935);
}

class _GiftCardRadii {
  const _GiftCardRadii();

  final double r12 = 12;
  final double r10 = 10;
}

class _GiftCardText {
  _GiftCardText(this.c);

  final _GiftCardColors c;

  TextStyle get screenTitle => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        color: c.textPrimary,
      );

  TextStyle get sectionSubtitle => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18 / 13,
        color: c.textSecondary,
      );

  TextStyle get amountLabelDark => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 20 / 16,
        color: c.textPrimary,
      );

  TextStyle get amountLabelLight => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 20 / 16,
        color: Colors.white,
      );

  TextStyle get buttonText => const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: Colors.white,
      );

  TextStyle get sectionHeader => const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: Colors.white,
      );

  TextStyle get listTitle => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 18 / 13,
        color: c.textPrimary,
      );

  TextStyle get listCaption => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 16 / 11,
        color: c.textSecondary,
      );

  TextStyle get pointsDeltaLight => const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        color: Colors.white,
      );

  TextStyle get pointsDeltaSuccess => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        color: c.success,
      );

  TextStyle get pointsDeltaError => TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        color: c.error,
      );
}

/* ------------------------------ AMOUNT GRID ------------------------------ */

class _AmountGrid extends StatelessWidget {
  const _AmountGrid({
    required this.denominations,
    required this.selectedDenominationId,
    required this.gap,
    required this.scale,
    required this.onTapDenomination,
  });

  final List<GiftCardDenomination> denominations;
  final int? selectedDenominationId;
  final double gap;
  final double scale;
  final ValueChanged<int> onTapDenomination;

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    // We mimic the screenshot: 3 columns, flat tiles, 12px radius, centered label.
    // Use GridView (shrinkWrap, no scroll) inside scroll view.
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: denominations.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final denomination = denominations[index];
        final bool selected = denomination.id == selectedDenominationId;

        return _AmountTile(
          denomination: denomination,
          selected: selected,
          scale: scale,
          onTap: () => onTapDenomination(denomination.id),
        );
      },
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.denomination,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final GiftCardDenomination denomination;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    final primaryPurple = const Color(0xFF7B2C8F);
    final surfaceLight = const Color(0xFFF6F6F6);
    final textPrimary = const Color(0xFF111111);

    final Color bg = selected ? primaryPurple : surfaceLight;

    // Extract amount from denomination string or use sellingPrice as fallback
    String amount;
    if (denomination.denomination != null && denomination.denomination!.isNotEmpty) {
      // Try to extract number from denomination string (e.g., "10 KWD" -> "10")
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(denomination.denomination!);
      if (match != null) {
        final numValue = double.tryParse(match.group(1) ?? '');
        amount = numValue != null ? numValue.toInt().toString() : denomination.sellingPrice.toInt().toString();
      } else {
        amount = denomination.sellingPrice.toInt().toString();
      }
    } else {
      amount = denomination.sellingPrice.toInt().toString();
    }
    final currency = denomination.currency ?? 'KWD';

    // Large digit style
    final digitStyle = TextStyle(
      fontSize: s(16),
      fontWeight: FontWeight.w600,
      height: 20 / 16,
      color: selected ? Colors.white : textPrimary,
    );

    // Smaller KD style (smaller font, slightly superscripted)
    final kdStyle = TextStyle(
      fontSize: s(11), // Smaller than digit
      fontWeight: FontWeight.w600,
      height: 1.0,
      color: selected ? Colors.white : textPrimary,
    );

    // NOTE: No shadow. Flat tile.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(s(12)),
        splashColor: selected
            ? Colors.white.withOpacity(0.12)
            : primaryPurple.withOpacity(0.10),
        highlightColor: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(s(12)),
          ),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: amount,
                    style: digitStyle,
                  ),
                  TextSpan(
                    text: ' $currency',
                    style: kdStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ PRIMARY BUTTON ------------------------------ */

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.scale,
    required this.onPressed,
  });

  final String label;
  final double scale;
  final VoidCallback? onPressed;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  double s(double px) => px * widget.scale;

  @override
  Widget build(BuildContext context) {
    final primaryPurple = const Color(0xFF7B2C8F);
    final primaryPurpleDark = const Color(0xFF5E1F6E);
    final disabled = const Color(0xFFBDBDBD);

    final bool isDisabled = widget.onPressed == null;

    final Color fill = isDisabled
        ? disabled
        : (_pressed ? primaryPurpleDark : primaryPurple);

    final buttonTextStyle = TextStyle(
      fontSize: s(14),
      fontWeight: FontWeight.w600,
      height: 20 / 14,
      color: Colors.white,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            },
      child: Container(
        height: s(48),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(s(12)),
        ),
        alignment: Alignment.center,
        child: Text(widget.label, style: buttonTextStyle),
      ),
    );
  }
}

/* ------------------------------ RECIPIENT TYPE SELECTOR ------------------------------ */

class _RecipientTypeSelector extends StatelessWidget {
  const _RecipientTypeSelector({
    required this.selectedType,
    required this.scale,
    required this.onChanged,
  });

  final GiftRecipientType selectedType;
  final double scale;
  final ValueChanged<GiftRecipientType> onChanged;

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF7B2C8F);
    const textPrimary = Color(0xFF111111);
    const textSecondary = Color(0xFF6B6B6B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who is this for?',
          style: TextStyle(
            fontSize: s(14),
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: s(12)),
        Row(
          children: [
            // For Myself option
            Expanded(
              child: _RadioOption(
                label: 'For Myself',
                isSelected: selectedType == GiftRecipientType.myself,
                scale: scale,
                primaryColor: primaryPurple,
                textColor: textPrimary,
                secondaryTextColor: textSecondary,
                onTap: () => onChanged(GiftRecipientType.myself),
              ),
            ),
            SizedBox(width: s(16)),
            // Gift to Someone Else option
            Expanded(
              child: _RadioOption(
                label: 'Gift to Someone',
                isSelected: selectedType == GiftRecipientType.someoneElse,
                scale: scale,
                primaryColor: primaryPurple,
                textColor: textPrimary,
                secondaryTextColor: textSecondary,
                onTap: () => onChanged(GiftRecipientType.someoneElse),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  const _RadioOption({
    required this.label,
    required this.isSelected,
    required this.scale,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final double scale;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isSelected 
        ? primaryColor.withOpacity(0.08) 
        : const Color(0xFFF6F6F6);
    final borderColor = isSelected ? primaryColor : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(s(12)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: s(12),
            vertical: s(14),
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(s(12)),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 0,
            ),
          ),
          child: Row(
            children: [
              // Custom radio circle
              Container(
                width: s(20),
                height: s(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primaryColor : secondaryTextColor,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: s(10),
                          height: s(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: s(10)),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: s(13),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? primaryColor : textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ THEMED TEXT FIELD ------------------------------ */

class _ThemedTextField extends StatelessWidget {
  const _ThemedTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.scale,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final double scale;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  double s(double px) => px * scale;

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF7B2C8F);
    const textPrimary = Color(0xFF111111);
    const textSecondary = Color(0xFF6B6B6B);
    const surfaceLight = Color(0xFFF6F6F6);
    const errorColor = Color(0xFFE53935);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: s(13),
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        SizedBox(height: s(6)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            fontSize: s(14),
            fontWeight: FontWeight.w400,
            color: textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: s(14),
              fontWeight: FontWeight.w400,
              color: textSecondary.withOpacity(0.6),
            ),
            filled: true,
            fillColor: surfaceLight,
            contentPadding: EdgeInsets.symmetric(
              horizontal: s(14),
              vertical: s(12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s(12)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s(12)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s(12)),
              borderSide: BorderSide(
                color: primaryPurple,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s(12)),
              borderSide: BorderSide(
                color: errorColor,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s(12)),
              borderSide: BorderSide(
                color: errorColor,
                width: 1.5,
              ),
            ),
            errorStyle: TextStyle(
              fontSize: s(11),
              fontWeight: FontWeight.w400,
              color: errorColor,
            ),
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ LOADING SHIMMER ------------------------------ */

class _GiftCardLoadingShimmer extends StatefulWidget {
  const _GiftCardLoadingShimmer({
    required this.sidePad,
    required this.scale,
  });

  final double sidePad;
  final double scale;

  @override
  State<_GiftCardLoadingShimmer> createState() => _GiftCardLoadingShimmerState();
}

class _GiftCardLoadingShimmerState extends State<_GiftCardLoadingShimmer>
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
          padding: EdgeInsets.symmetric(horizontal: widget.sidePad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount grid shimmer (3x2 grid)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: s(12),
                  crossAxisSpacing: s(12),
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) => _ShimmerBox(
                  controller: _shimmerController,
                  borderRadius: s(12),
                ),
              ),

              SizedBox(height: s(20)),

              // "Who is this for?" label shimmer
              _ShimmerBox(
                controller: _shimmerController,
                width: s(120),
                height: s(20),
                borderRadius: s(4),
              ),

              SizedBox(height: s(12)),

              // Radio buttons shimmer
              Row(
                children: [
                  Expanded(
                    child: _ShimmerBox(
                      controller: _shimmerController,
                      height: s(52),
                      borderRadius: s(12),
                    ),
                  ),
                  SizedBox(width: s(16)),
                  Expanded(
                    child: _ShimmerBox(
                      controller: _shimmerController,
                      height: s(52),
                      borderRadius: s(12),
                    ),
                  ),
                ],
              ),

              SizedBox(height: s(24)),

              // Proceed button shimmer
              _ShimmerBox(
                controller: _shimmerController,
                height: s(48),
                borderRadius: s(12),
              ),

              SizedBox(height: s(32)),

              // Transaction history header shimmer
              _ShimmerBox(
                controller: _shimmerController,
                height: s(48),
                borderRadius: s(24),
              ),

              SizedBox(height: s(16)),

              // Transaction items shimmer
              ...List.generate(
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

