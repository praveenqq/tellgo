import 'package:tellgo_app/core/bloc/base_state.dart';
import 'package:tellgo_app/models/wallet_models.dart';

class WalletState extends BaseState {
  final WalletBalance? balance;
  final List<WalletTransaction> transactions;
  final List<WalletDenomination> denominations;
  final bool isLoading;
  final bool isLoadingBalance;
  final bool isLoadingTransactions;
  final bool isLoadingDenominations;
  final bool isToppingUp;
  final bool isProcessingTransaction;
  final String? errorMessage;
  final TopUpResponse? topUpResponse;
  final ProcessTransactionResponse? processTransactionResponse;

  const WalletState({
    this.balance,
    this.transactions = const [],
    this.denominations = const [],
    this.isLoading = false,
    this.isLoadingBalance = false,
    this.isLoadingTransactions = false,
    this.isLoadingDenominations = false,
    this.isToppingUp = false,
    this.isProcessingTransaction = false,
    this.errorMessage,
    this.topUpResponse,
    this.processTransactionResponse,
  });

  WalletState copyWith({
    WalletBalance? balance,
    List<WalletTransaction>? transactions,
    List<WalletDenomination>? denominations,
    bool? isLoading,
    bool? isLoadingBalance,
    bool? isLoadingTransactions,
    bool? isLoadingDenominations,
    bool? isToppingUp,
    bool? isProcessingTransaction,
    String? errorMessage,
    TopUpResponse? topUpResponse,
    ProcessTransactionResponse? processTransactionResponse,
    bool clearError = false,
    bool clearTopUpResponse = false,
    bool clearProcessTransactionResponse = false,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      denominations: denominations ?? this.denominations,
      isLoading: isLoading ?? this.isLoading,
      isLoadingBalance: isLoadingBalance ?? this.isLoadingBalance,
      isLoadingTransactions: isLoadingTransactions ?? this.isLoadingTransactions,
      isLoadingDenominations: isLoadingDenominations ?? this.isLoadingDenominations,
      isToppingUp: isToppingUp ?? this.isToppingUp,
      isProcessingTransaction: isProcessingTransaction ?? this.isProcessingTransaction,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      topUpResponse: clearTopUpResponse ? null : (topUpResponse ?? this.topUpResponse),
      processTransactionResponse: clearProcessTransactionResponse ? null : (processTransactionResponse ?? this.processTransactionResponse),
    );
  }

  @override
  List<Object?> get props => [
        balance,
        transactions,
        denominations,
        isLoading,
        isLoadingBalance,
        isLoadingTransactions,
        isLoadingDenominations,
        isToppingUp,
        isProcessingTransaction,
        errorMessage,
        topUpResponse,
        processTransactionResponse,
      ];
}

// Initial state
class WalletInitial extends WalletState {
  const WalletInitial();
}

// Loading states
class WalletLoading extends WalletState {
  const WalletLoading() : super(isLoading: true);
}

class WalletBalanceLoading extends WalletState {
  const WalletBalanceLoading() : super(isLoadingBalance: true);
}

class WalletTransactionsLoading extends WalletState {
  const WalletTransactionsLoading() : super(isLoadingTransactions: true);
}

class WalletDenominationsLoading extends WalletState {
  const WalletDenominationsLoading() : super(isLoadingDenominations: true);
}

class WalletToppingUp extends WalletState {
  const WalletToppingUp() : super(isToppingUp: true);
}

class WalletProcessingTransaction extends WalletState {
  const WalletProcessingTransaction() : super(isProcessingTransaction: true);
}

// Success states
class WalletDataLoaded extends WalletState {
  final WalletBalance balanceData;
  final List<WalletTransaction> transactionsData;
  final List<WalletDenomination> denominationsData;

  const WalletDataLoaded({
    required this.balanceData,
    required this.transactionsData,
    required this.denominationsData,
  }) : super(
          balance: balanceData,
          transactions: transactionsData,
          denominations: denominationsData,
        );

  @override
  List<Object?> get props => [balanceData, transactionsData, denominationsData];
}

class WalletTopUpSuccess extends WalletState {
  final TopUpResponse response;
  final WalletBalance? updatedBalance;

  const WalletTopUpSuccess({
    required this.response,
    this.updatedBalance,
  }) : super(topUpResponse: response, balance: updatedBalance);

  @override
  List<Object?> get props => [response, updatedBalance];
}

class WalletProcessTransactionSuccess extends WalletState {
  final ProcessTransactionResponse response;
  final WalletBalance? updatedBalance;

  const WalletProcessTransactionSuccess({
    required this.response,
    this.updatedBalance,
  }) : super(processTransactionResponse: response, balance: updatedBalance);

  @override
  List<Object?> get props => [response, updatedBalance];
}

// Error states
class WalletError extends WalletState {
  final String message;

  const WalletError(this.message) : super(errorMessage: message);

  @override
  List<Object?> get props => [message];
}

