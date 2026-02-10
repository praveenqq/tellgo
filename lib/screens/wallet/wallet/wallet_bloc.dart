import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_event.dart';
import 'package:tellgo_app/screens/wallet/wallet/wallet_state.dart';
import 'package:tellgo_app/repository/wallet_repository.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;
  static const int defaultCountryId = 92;

  WalletBloc({required this.walletRepository}) : super(const WalletInitial()) {
    on<LoadWalletData>(_onLoadWalletData);
    on<RefreshWalletBalance>(_onRefreshWalletBalance);
    on<RefreshWalletTransactions>(_onRefreshWalletTransactions);
    on<LoadWalletDenominations>(_onLoadWalletDenominations);
    on<TopUpWalletRequested>(_onTopUpWalletRequested);
    on<ProcessTransactionRequested>(_onProcessTransactionRequested);
  }

  Future<void> _onLoadWalletData(
    LoadWalletData event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      // Load all data in parallel
      final balance = await walletRepository.getUserWalletBalance();
      final transactions = await walletRepository.getWalletTransactions();
      final denominations = await walletRepository.getWalletTopUpDenominations(
        countryId: defaultCountryId,
      );

      emit(WalletDataLoaded(
        balanceData: balance,
        transactionsData: transactions,
        denominationsData: denominations,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onRefreshWalletBalance(
    RefreshWalletBalance event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(isLoadingBalance: true, clearError: true));
    try {
      final balance = await walletRepository.getUserWalletBalance();
      emit(state.copyWith(
        balance: balance,
        isLoadingBalance: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingBalance: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshWalletTransactions(
    RefreshWalletTransactions event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(isLoadingTransactions: true, clearError: true));
    try {
      final transactions = await walletRepository.getWalletTransactions();
      emit(state.copyWith(
        transactions: transactions,
        isLoadingTransactions: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingTransactions: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadWalletDenominations(
    LoadWalletDenominations event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(isLoadingDenominations: true, clearError: true));
    try {
      final denominations = await walletRepository.getWalletTopUpDenominations(
        countryId: event.countryId,
      );
      emit(state.copyWith(
        denominations: denominations,
        isLoadingDenominations: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDenominations: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onTopUpWalletRequested(
    TopUpWalletRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletToppingUp());
    try {
      final response = await walletRepository.topUpUserWallet(event.request);
      
      if (response.success) {
        // If payment URL is present, emit success state with payment URL
        // The UI will handle showing the payment screen
        if (response.paymentUrl != null && response.paymentUrl!.isNotEmpty) {
          emit(WalletTopUpSuccess(
            response: response,
            updatedBalance: null, // Will be updated after payment processing
          ));
        } else {
          // Direct success (no payment gateway needed)
          final balance = await walletRepository.getUserWalletBalance();
          final transactions = await walletRepository.getWalletTransactions();
          emit(WalletTopUpSuccess(
            response: response,
            updatedBalance: balance,
          ));
          // After showing success, update to loaded state with fresh data
          emit(WalletDataLoaded(
            balanceData: balance,
            transactionsData: transactions,
            denominationsData: state.denominations,
          ));
        }
      } else {
        emit(WalletError(response.message ?? 'Top-up failed'));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onProcessTransactionRequested(
    ProcessTransactionRequested event,
    Emitter<WalletState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint('💳 Processing transaction: ${event.transactionId}');
    }
    
    emit(const WalletProcessingTransaction());
    try {
      final response = await walletRepository.processTransaction(event.transactionId);
      
      if (response.success) {
        // Refresh balance and transactions after successful transaction processing
        final balance = await walletRepository.getUserWalletBalance();
        final transactions = await walletRepository.getWalletTransactions();
        emit(WalletProcessTransactionSuccess(
          response: response,
          updatedBalance: balance,
        ));
        // After showing success, update to loaded state with fresh data
        emit(WalletDataLoaded(
          balanceData: balance,
          transactionsData: transactions,
          denominationsData: state.denominations,
        ));
      } else {
        emit(WalletError(
          response.errorMessage ?? 
          response.message ?? 
          'Transaction processing failed'
        ));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}

