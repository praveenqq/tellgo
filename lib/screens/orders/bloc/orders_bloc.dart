import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/repository/order_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository orderRepository;

  OrdersBloc({required this.orderRepository}) : super(const OrdersInitial()) {
    on<LoadUserOrders>(_onLoadUserOrders);
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<ValidateBundlePurchase>(_onValidateBundlePurchase);
    on<UpdateOrderRating>(_onUpdateOrderRating);
  }

  Future<void> _onLoadUserOrders(
    LoadUserOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    try {
      final orders = await orderRepository.getUserOrders();
      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(message: e.toString()));
    }
  }

  Future<void> _onLoadOrderDetails(
    LoadOrderDetails event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrderDetailsLoading());
    try {
      final orderDetails = await orderRepository.getOrderDetails(
        orderId: event.orderId,
      );
      emit(OrderDetailsLoaded(orderDetails: orderDetails));
    } catch (e) {
      emit(OrderDetailsError(message: e.toString()));
    }
  }

  Future<void> _onValidateBundlePurchase(
    ValidateBundlePurchase event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const ValidateBundlePurchaseLoading());
    try {
      final response = await orderRepository.validateBundlePurchase(
        event.request,
      );
      if (response.success) {
        emit(ValidateBundlePurchaseSuccess(response: response));
      } else {
        emit(ValidateBundlePurchaseError(
          message: response.message ?? 'Validation failed',
        ));
      }
    } catch (e) {
      emit(ValidateBundlePurchaseError(message: e.toString()));
    }
  }

  Future<void> _onUpdateOrderRating(
    UpdateOrderRating event,
    Emitter<OrdersState> emit,
  ) async {
    // This is a local update - just update the order in the list if loaded
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      final updatedOrders = currentState.orders.map((order) {
        if (order.orderId == event.orderId) {
          return order.copyWith(rating: event.rating);
        }
        return order;
      }).toList();
      emit(OrdersLoaded(orders: updatedOrders));
    }
  }
}

