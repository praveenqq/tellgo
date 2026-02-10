import 'package:tellgo_app/core/bloc/base_state.dart';
import 'package:tellgo_app/models/gift_card_models.dart';

class GiftCardState extends BaseState {
  final List<GiftCardDenomination> denominations;
  final List<GiftCardPaymentChannel> paymentChannels;
  final List<GiftCardPurchaseHistory> purchaseHistory;
  final List<GiftCardRedeemHistory> redeemHistory;
  final bool isLoading;
  final bool isLoadingDenominations;
  final bool isLoadingPurchaseHistory;
  final bool isLoadingRedeemHistory;
  final bool isPurchasing;
  final String? errorMessage;
  final GiftCardPurchaseResponse? purchaseResponse;

  const GiftCardState({
    this.denominations = const [],
    this.paymentChannels = const [],
    this.purchaseHistory = const [],
    this.redeemHistory = const [],
    this.isLoading = false,
    this.isLoadingDenominations = false,
    this.isLoadingPurchaseHistory = false,
    this.isLoadingRedeemHistory = false,
    this.isPurchasing = false,
    this.errorMessage,
    this.purchaseResponse,
  });

  /// Get all available channel codes from payment channels
  List<String> get availableChannelCodes {
    final codes = <String>[];
    for (final channel in paymentChannels) {
      codes.addAll(channel.channelCodes);
    }
    return codes;
  }

  /// Get all payment channel infos with logos
  List<PaymentChannelInfo> get availableChannelInfos {
    final infos = <PaymentChannelInfo>[];
    for (final channel in paymentChannels) {
      infos.addAll(channel.channels);
    }
    return infos;
  }

  GiftCardState copyWith({
    List<GiftCardDenomination>? denominations,
    List<GiftCardPaymentChannel>? paymentChannels,
    List<GiftCardPurchaseHistory>? purchaseHistory,
    List<GiftCardRedeemHistory>? redeemHistory,
    bool? isLoading,
    bool? isLoadingDenominations,
    bool? isLoadingPurchaseHistory,
    bool? isLoadingRedeemHistory,
    bool? isPurchasing,
    String? errorMessage,
    GiftCardPurchaseResponse? purchaseResponse,
    bool clearError = false,
    bool clearPurchaseResponse = false,
  }) {
    return GiftCardState(
      denominations: denominations ?? this.denominations,
      paymentChannels: paymentChannels ?? this.paymentChannels,
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      redeemHistory: redeemHistory ?? this.redeemHistory,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDenominations: isLoadingDenominations ?? this.isLoadingDenominations,
      isLoadingPurchaseHistory: isLoadingPurchaseHistory ?? this.isLoadingPurchaseHistory,
      isLoadingRedeemHistory: isLoadingRedeemHistory ?? this.isLoadingRedeemHistory,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      purchaseResponse: clearPurchaseResponse
          ? null
          : (purchaseResponse ?? this.purchaseResponse),
    );
  }

  @override
  List<Object?> get props => [
        denominations,
        paymentChannels,
        purchaseHistory,
        redeemHistory,
        isLoading,
        isLoadingDenominations,
        isLoadingPurchaseHistory,
        isLoadingRedeemHistory,
        isPurchasing,
        errorMessage,
        purchaseResponse,
      ];
}

// Initial state
class GiftCardInitial extends GiftCardState {
  const GiftCardInitial();
}

// Loading states
class GiftCardLoading extends GiftCardState {
  const GiftCardLoading() : super(isLoading: true);
}

class GiftCardDenominationsLoading extends GiftCardState {
  const GiftCardDenominationsLoading() : super(isLoadingDenominations: true);
}

class GiftCardPurchaseHistoryLoading extends GiftCardState {
  const GiftCardPurchaseHistoryLoading() : super(isLoadingPurchaseHistory: true);
}

class GiftCardRedeemHistoryLoading extends GiftCardState {
  const GiftCardRedeemHistoryLoading() : super(isLoadingRedeemHistory: true);
}

class GiftCardPurchasing extends GiftCardState {
  const GiftCardPurchasing() : super(isPurchasing: true);
}

// Success states
class GiftCardDataLoaded extends GiftCardState {
  final List<GiftCardDenomination> denominationsData;
  final List<GiftCardPaymentChannel> paymentChannelsData;
  final List<GiftCardPurchaseHistory> purchaseHistoryData;
  final List<GiftCardRedeemHistory> redeemHistoryData;

  const GiftCardDataLoaded({
    required this.denominationsData,
    required this.paymentChannelsData,
    required this.purchaseHistoryData,
    required this.redeemHistoryData,
  }) : super(
          denominations: denominationsData,
          paymentChannels: paymentChannelsData,
          purchaseHistory: purchaseHistoryData,
          redeemHistory: redeemHistoryData,
        );

  @override
  List<Object?> get props => [
        denominationsData,
        paymentChannelsData,
        purchaseHistoryData,
        redeemHistoryData,
      ];
}

class GiftCardPurchaseSuccess extends GiftCardState {
  final GiftCardPurchaseResponse response;

  const GiftCardPurchaseSuccess({
    required this.response,
  }) : super(purchaseResponse: response);

  @override
  List<Object?> get props => [response];
}

class GiftCardProcessingTransaction extends GiftCardState {
  const GiftCardProcessingTransaction();
}

class GiftCardProcessTransactionSuccess extends GiftCardState {
  final GiftCardProcessTransactionResponse response;

  const GiftCardProcessTransactionSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

// Error states
class GiftCardError extends GiftCardState {
  final String message;

  const GiftCardError(this.message) : super(errorMessage: message);

  @override
  List<Object?> get props => [message];
}

