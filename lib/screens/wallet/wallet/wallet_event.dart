import 'package:equatable/equatable.dart';
import 'package:tellgo_app/models/wallet_models.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletData extends WalletEvent {
  const LoadWalletData();
}

class RefreshWalletBalance extends WalletEvent {
  const RefreshWalletBalance();
}

class RefreshWalletTransactions extends WalletEvent {
  const RefreshWalletTransactions();
}

class LoadWalletDenominations extends WalletEvent {
  final int countryId;

  const LoadWalletDenominations({required this.countryId});

  @override
  List<Object?> get props => [countryId];
}

class TopUpWalletRequested extends WalletEvent {
  final TopUpRequest request;

  const TopUpWalletRequested({required this.request});

  @override
  List<Object?> get props => [request];
}

class ProcessTransactionRequested extends WalletEvent {
  final String transactionId;

  const ProcessTransactionRequested({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

