import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/screens/go_points/bloc/loyalty_event.dart';
import 'package:tellgo_app/screens/go_points/bloc/loyalty_state.dart';
import 'package:tellgo_app/repository/loyalty_repository.dart';

class LoyaltyBloc extends Bloc<LoyaltyEvent, LoyaltyState> {
  final LoyaltyRepository loyaltyRepository;

  LoyaltyBloc({required this.loyaltyRepository}) : super(const LoyaltyInitial()) {
    on<LoadLoyaltyData>(_onLoadLoyaltyData);
    on<RefreshLoyaltyPoints>(_onRefreshLoyaltyPoints);
    on<RefreshLoyaltyTransactions>(_onRefreshLoyaltyTransactions);
  }

  Future<void> _onLoadLoyaltyData(
    LoadLoyaltyData event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(const LoyaltyLoading());
    try {
      if (kDebugMode) {
        debugPrint('🎯 Loading loyalty data...');
      }

      // Currency is required by the API - default to KWD if not provided
      final currency = event.currency ?? 'KWD';

      // Load points and transactions in parallel
      final results = await Future.wait([
        loyaltyRepository.getUserLoyaltyPoints(currency: currency),
        loyaltyRepository.getUserLoyaltyTransactions(),
      ]);

      final points = results[0] as dynamic;
      final transactions = results[1] as List;

      if (kDebugMode) {
        debugPrint('✅ Loyalty data loaded: ${points.availablePoints} points, ${transactions.length} transactions');
      }

      emit(LoyaltyDataLoaded(
        pointsData: points,
        transactionsData: transactions.cast(),
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading loyalty data: $e');
      }
      emit(LoyaltyError(e.toString()));
    }
  }

  Future<void> _onRefreshLoyaltyPoints(
    RefreshLoyaltyPoints event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(isLoadingPoints: true, clearError: true));
    try {
      // Currency is required by the API - default to KWD if not provided
      final currency = event.currency ?? 'KWD';
      final points = await loyaltyRepository.getUserLoyaltyPoints(currency: currency);
      emit(state.copyWith(
        points: points,
        isLoadingPoints: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingPoints: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshLoyaltyTransactions(
    RefreshLoyaltyTransactions event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(isLoadingTransactions: true, clearError: true));
    try {
      final transactions = await loyaltyRepository.getUserLoyaltyTransactions();
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
}

