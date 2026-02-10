import 'package:equatable/equatable.dart';
import 'package:tellgo_app/models/order_models.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;

  const OrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Order Details States
class OrderDetailsLoading extends OrdersState {
  const OrderDetailsLoading();
}

class OrderDetailsLoaded extends OrdersState {
  final OrderDetails orderDetails;

  const OrderDetailsLoaded({required this.orderDetails});

  @override
  List<Object?> get props => [orderDetails];
}

class OrderDetailsError extends OrdersState {
  final String message;

  const OrderDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Validate Bundle Purchase States
class ValidateBundlePurchaseLoading extends OrdersState {
  const ValidateBundlePurchaseLoading();
}

class ValidateBundlePurchaseSuccess extends OrdersState {
  final ValidateBundlePurchaseResponse response;

  const ValidateBundlePurchaseSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class ValidateBundlePurchaseError extends OrdersState {
  final String message;

  const ValidateBundlePurchaseError({required this.message});

  @override
  List<Object?> get props => [message];
}

