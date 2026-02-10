import 'package:equatable/equatable.dart';

abstract class LoyaltyEvent extends Equatable {
  const LoyaltyEvent();

  @override
  List<Object?> get props => [];
}

/// Load all loyalty data (points and transactions)
class LoadLoyaltyData extends LoyaltyEvent {
  final String? currency;

  const LoadLoyaltyData({this.currency});

  @override
  List<Object?> get props => [currency];
}

/// Refresh only the loyalty points
class RefreshLoyaltyPoints extends LoyaltyEvent {
  final String? currency;

  const RefreshLoyaltyPoints({this.currency});

  @override
  List<Object?> get props => [currency];
}

/// Refresh only the loyalty transactions
class RefreshLoyaltyTransactions extends LoyaltyEvent {
  const RefreshLoyaltyTransactions();
}

