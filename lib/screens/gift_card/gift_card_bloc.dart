import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/screens/gift_card/gift_card_event.dart';
import 'package:tellgo_app/screens/gift_card/gift_card_state.dart';
import 'package:tellgo_app/repository/gift_card_repository.dart';

class GiftCardBloc extends Bloc<GiftCardEvent, GiftCardState> {
  final GiftCardRepository giftCardRepository;
  static const int defaultCountryId = 92;

  GiftCardBloc({required this.giftCardRepository}) : super(const GiftCardInitial()) {
    on<LoadGiftCardData>(_onLoadGiftCardData);
    on<RefreshGiftCardDenominations>(_onRefreshGiftCardDenominations);
    on<RefreshGiftCardPurchaseHistory>(_onRefreshGiftCardPurchaseHistory);
    on<RefreshGiftCardRedeemHistory>(_onRefreshGiftCardRedeemHistory);
    on<PurchaseGiftCardRequested>(_onPurchaseGiftCardRequested);
    on<ProcessGiftCardTransactionRequested>(_onProcessGiftCardTransactionRequested);
  }

  Future<void> _onLoadGiftCardData(
    LoadGiftCardData event,
    Emitter<GiftCardState> emit,
  ) async {
    emit(const GiftCardLoading());
    try {
      // Load all data in parallel
      final denominationResult = await giftCardRepository.getGiftCardDenominations(
        countryId: event.countryId,
      );
      final purchaseHistory =
          await giftCardRepository.getUserGiftCardPurchaseHistory();
      final redeemHistory =
          await giftCardRepository.getUserGiftCardRedeemHistory();

      if (kDebugMode) {
        debugPrint('📦 Loaded ${denominationResult.denominations.length} denominations');
        debugPrint('📦 Loaded ${denominationResult.paymentChannels.length} payment channels');
      }

      emit(GiftCardDataLoaded(
        denominationsData: denominationResult.denominations,
        paymentChannelsData: denominationResult.paymentChannels,
        purchaseHistoryData: purchaseHistory,
        redeemHistoryData: redeemHistory,
      ));
    } catch (e) {
      emit(GiftCardError(e.toString()));
    }
  }

  Future<void> _onRefreshGiftCardDenominations(
    RefreshGiftCardDenominations event,
    Emitter<GiftCardState> emit,
  ) async {
    emit(state.copyWith(isLoadingDenominations: true, clearError: true));
    try {
      final result = await giftCardRepository.getGiftCardDenominations(
        countryId: event.countryId,
      );
      emit(state.copyWith(
        denominations: result.denominations,
        paymentChannels: result.paymentChannels,
        isLoadingDenominations: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDenominations: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshGiftCardPurchaseHistory(
    RefreshGiftCardPurchaseHistory event,
    Emitter<GiftCardState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint('🔄 Refreshing gift card purchase history...');
    }
    emit(state.copyWith(isLoadingPurchaseHistory: true, clearError: true));
    try {
      final purchaseHistory =
          await giftCardRepository.getUserGiftCardPurchaseHistory();
      if (kDebugMode) {
        debugPrint('✅ Got ${purchaseHistory.length} purchase history items');
        // Log the latest transaction status
        if (purchaseHistory.isNotEmpty) {
          final latest = purchaseHistory.first;
          debugPrint('📝 Latest transaction: id=${latest.id}, status=${latest.transactionStatus}, paymentStatus=${latest.paymentStatus}');
        }
      }
      emit(state.copyWith(
        purchaseHistory: purchaseHistory,
        isLoadingPurchaseHistory: false,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error refreshing purchase history: $e');
      }
      emit(state.copyWith(
        isLoadingPurchaseHistory: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshGiftCardRedeemHistory(
    RefreshGiftCardRedeemHistory event,
    Emitter<GiftCardState> emit,
  ) async {
    emit(state.copyWith(isLoadingRedeemHistory: true, clearError: true));
    try {
      final redeemHistory =
          await giftCardRepository.getUserGiftCardRedeemHistory();
      emit(state.copyWith(
        redeemHistory: redeemHistory,
        isLoadingRedeemHistory: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingRedeemHistory: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPurchaseGiftCardRequested(
    PurchaseGiftCardRequested event,
    Emitter<GiftCardState> emit,
  ) async {
    emit(const GiftCardPurchasing());
    try {
      final response =
          await giftCardRepository.purchaseGiftCard(event.request);

      if (response.success) {
        emit(GiftCardPurchaseSuccess(response: response));
        // Refresh purchase history after successful purchase
        final purchaseHistory =
            await giftCardRepository.getUserGiftCardPurchaseHistory();
        // Update state with fresh data - emit proper data-loaded state
        emit(GiftCardDataLoaded(
          denominationsData: state.denominations,
          paymentChannelsData: state.paymentChannels,
          purchaseHistoryData: purchaseHistory,
          redeemHistoryData: state.redeemHistory,
        ));
      } else {
        emit(GiftCardError(
          response.message ?? 'Gift card purchase failed',
        ));
      }
    } catch (e) {
      emit(GiftCardError(e.toString()));
    }
  }

  Future<void> _onProcessGiftCardTransactionRequested(
    ProcessGiftCardTransactionRequested event,
    Emitter<GiftCardState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint('💳 Processing gift card transaction: ${event.transactionId}');
    }
    emit(const GiftCardProcessingTransaction());
    try {
      final response = await giftCardRepository.processTransaction(event.transactionId);
      
      if (kDebugMode) {
        debugPrint('✅ Gift card transaction processed - success: ${response.success}');
        debugPrint('   - status: ${response.status}');
        debugPrint('   - message: ${response.message}');
      }
      
      if (response.success) {
        emit(GiftCardProcessTransactionSuccess(response: response));
        // Refresh purchase history after successful transaction processing
        final purchaseHistory =
            await giftCardRepository.getUserGiftCardPurchaseHistory();
        emit(GiftCardDataLoaded(
          denominationsData: state.denominations,
          paymentChannelsData: state.paymentChannels,
          purchaseHistoryData: purchaseHistory,
          redeemHistoryData: state.redeemHistory,
        ));
      } else {
        emit(GiftCardError(
          response.errorMessage ?? 
          response.message ?? 
          'Transaction processing failed'
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error processing gift card transaction: $e');
      }
      emit(GiftCardError(e.toString()));
    }
  }
}

