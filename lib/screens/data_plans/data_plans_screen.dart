import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/models/order_models.dart';
import 'package:tellgo_app/repository/order_repository.dart';
import 'package:tellgo_app/screens/data_plans/cards_revised.dart';
import 'package:tellgo_app/screens/data_plans/data_plans_details_revised.dart';
import 'package:tellgo_app/screens/orders/bloc/orders_bloc.dart';
import 'package:tellgo_app/screens/orders/bloc/orders_event.dart';
import 'package:tellgo_app/screens/orders/bloc/orders_state.dart';
import 'package:tellgo_app/screens/profile/user_header.dart';

class DataPlansScreen extends StatelessWidget {
  const DataPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersBloc(
        orderRepository: OrderRepositoryImpl(AppDio()),
      )..add(const LoadUserOrders()),
      child: const _DataPlansContent(),
    );
  }
}

class _DataPlansContent extends StatelessWidget {
  const _DataPlansContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Column(
        children: [
          // Common Header
          const CommonAppHeader(
            notificationCount: 3,
          ),
          // Content
          Expanded(
            child: RefreshIndicator(
              color: CardColors.primary,
              onRefresh: () async {
                context.read<OrdersBloc>().add(const LoadUserOrders());
                await Future.delayed(const Duration(milliseconds: 500));
                    },
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return const _LoadingState();
                  } else if (state is OrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return const _EmptyState();
                    }
                    return _OrdersList(orders: state.orders);
                  } else if (state is OrdersError) {
                    return _ErrorState(
                      message: state.message,
                      onRetry: () {
                        context
                            .read<OrdersBloc>()
                            .add(const LoadUserOrders());
                      },
                    );
                  }
                  return const _LoadingState();
                },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading State ───────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: CardColors.primary),
    );
    }
  }

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        const SizedBox(height: 80),
        Center(
      child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sim_card_outlined,
                size: 64,
                color: CardColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No eSIMs yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CardColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Purchase an eSIM to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: CardColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Error State ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
          ),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: CardColors.cancelledDot.withValues(alpha: 0.7),
          ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load orders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CardColors.textPrimary,
                    ),
                  ),
              const SizedBox(height: 8),
                  Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  color: CardColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                width: 120,
                child: Material(
                  color: CardColors.primary,
                  borderRadius: BorderRadius.circular(CardRadii.button),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(CardRadii.button),
                    onTap: onRetry,
                    child: const Center(
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CardColors.white,
                        ),
                      ),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Orders List (using revised EsimUsageCard) ──────────────────────────────

class _OrdersList extends StatelessWidget {
  final List<Order> orders;

  const _OrdersList({required this.orders});

  void _navigateToDetails(BuildContext context, Order order) {
    final id = order.appOrderId ?? order.orderNumber ?? '';
    if (id.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EsimDetailsScreen(
          orderId: id,
          orderTitle: order.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () => _navigateToDetails(context, order),
          child: EsimUsageCard(
            order: order,
            onEdit: () {/* TODO: open name edit */},
            onPrimary: () {/* TODO: activate action */},
            onSecondary: () {/* TODO: share/top-up action */},
            onTapDetails: () => _navigateToDetails(context, order),
          ),
        );
      },
    );
  }
}
