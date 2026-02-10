import 'package:tellgo_app/core/bloc/base_state.dart';
import 'package:tellgo_app/models/loyalty_models.dart';

class LoyaltyState extends BaseState {
  final LoyaltyPoints? points;
  final List<LoyaltyTransaction> transactions;
  final bool isLoading;
  final bool isLoadingPoints;
  final bool isLoadingTransactions;
  final String? errorMessage;

  const LoyaltyState({
    this.points,
    this.transactions = const [],
    this.isLoading = false,
    this.isLoadingPoints = false,
    this.isLoadingTransactions = false,
    this.errorMessage,
  });

  LoyaltyState copyWith({
    LoyaltyPoints? points,
    List<LoyaltyTransaction>? transactions,
    bool? isLoading,
    bool? isLoadingPoints,
    bool? isLoadingTransactions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoyaltyState(
      points: points ?? this.points,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingPoints: isLoadingPoints ?? this.isLoadingPoints,
      isLoadingTransactions: isLoadingTransactions ?? this.isLoadingTransactions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        points,
        transactions,
        isLoading,
        isLoadingPoints,
        isLoadingTransactions,
        errorMessage,
      ];
}

// Initial state
class LoyaltyInitial extends LoyaltyState {
  const LoyaltyInitial();
}

// Loading states
class LoyaltyLoading extends LoyaltyState {
  const LoyaltyLoading() : super(isLoading: true);
}

class LoyaltyPointsLoading extends LoyaltyState {
  const LoyaltyPointsLoading() : super(isLoadingPoints: true);
}

class LoyaltyTransactionsLoading extends LoyaltyState {
  const LoyaltyTransactionsLoading() : super(isLoadingTransactions: true);
}

// Success states
class LoyaltyDataLoaded extends LoyaltyState {
  final LoyaltyPoints pointsData;
  final List<LoyaltyTransaction> transactionsData;

  const LoyaltyDataLoaded({
    required this.pointsData,
    required this.transactionsData,
  }) : super(
          points: pointsData,
          transactions: transactionsData,
        );

  @override
  List<Object?> get props => [pointsData, transactionsData];
}

// Error states
class LoyaltyError extends LoyaltyState {
  final String message;

  const LoyaltyError(this.message) : super(errorMessage: message);

  @override
  List<Object?> get props => [message];
}

