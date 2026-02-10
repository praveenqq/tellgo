import 'package:equatable/equatable.dart';
import 'package:tellgo_app/models/order_models.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserOrders extends OrdersEvent {
  const LoadUserOrders();
}

class LoadOrderDetails extends OrdersEvent {
  final String orderId;

  const LoadOrderDetails({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class ValidateBundlePurchase extends OrdersEvent {
  final ValidateBundlePurchaseRequest request;

  const ValidateBundlePurchase({required this.request});

  @override
  List<Object?> get props => [request];
}

class UpdateOrderRating extends OrdersEvent {
  final int orderId;
  final int rating;

  const UpdateOrderRating({
    required this.orderId,
    required this.rating,
  });

  @override
  List<Object?> get props => [orderId, rating];
}

