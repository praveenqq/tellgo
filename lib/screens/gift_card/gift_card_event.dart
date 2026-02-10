import 'package:equatable/equatable.dart';
import 'package:tellgo_app/models/gift_card_models.dart';

abstract class GiftCardEvent extends Equatable {
  const GiftCardEvent();

  @override
  List<Object?> get props => [];
}

class LoadGiftCardData extends GiftCardEvent {
  final int countryId;

  const LoadGiftCardData({required this.countryId});

  @override
  List<Object?> get props => [countryId];
}

class RefreshGiftCardDenominations extends GiftCardEvent {
  final int countryId;

  const RefreshGiftCardDenominations({required this.countryId});

  @override
  List<Object?> get props => [countryId];
}

class RefreshGiftCardPurchaseHistory extends GiftCardEvent {
  const RefreshGiftCardPurchaseHistory();
}

class RefreshGiftCardRedeemHistory extends GiftCardEvent {
  const RefreshGiftCardRedeemHistory();
}

class PurchaseGiftCardRequested extends GiftCardEvent {
  final GiftCardPurchaseRequest request;

  const PurchaseGiftCardRequested({required this.request});

  @override
  List<Object?> get props => [request];
}

class ProcessGiftCardTransactionRequested extends GiftCardEvent {
  final String transactionId;

  const ProcessGiftCardTransactionRequested({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

