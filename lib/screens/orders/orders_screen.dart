import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/models/order_models.dart';
import 'package:tellgo_app/repository/order_repository.dart';
import 'bloc/orders_bloc.dart';
import 'bloc/orders_event.dart';
import 'bloc/orders_state.dart';

/// Single-file implementation based on the provided screenshot (design width = 523px).
/// Uses proportional scaling so it matches on typical mobile widths (360/375/390).


/// =======================
/// THEME / TOKENS
/// =======================
class AppTheme {
  // Colors (from screenshot; some are best-fit approximations)
  static const Color screenBg = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFF1F1F1);
  static const Color cardBorderLavender = Color(0xFFCFAED8);
  static const Color dividerLight = Color(0xFFEDEDED);
  static const Color primaryPurple = Color(0xFF832D9F);
  static const Color starYellow = Color(0xFFF9F900);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF595857);

  static const Color outlineGrey = Color(0xFF787878);

  static const Color successDot = Color(0xFF00C844);
  static const Color errorDot = Color(0xFFFF0021);

  static ThemeData get theme {
    final base = ThemeData(useMaterial3: false);
    return base.copyWith(
      scaffoldBackgroundColor: screenBg,
      textTheme: base.textTheme.copyWith(
        // We'll still size text manually in widgets to match px, but these help defaults.
        bodyMedium: const TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
        ),
      ),
    );
  }
}

/// =======================
/// SCREEN
/// =======================
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersBloc(
        orderRepository: OrderRepositoryImpl(AppDio()),
      )..add(const LoadUserOrders()),
      child: const _OrdersScreenContent(),
    );
  }
}

class _OrdersScreenContent extends StatelessWidget {
  const _OrdersScreenContent();

  @override
  Widget build(BuildContext context) {
    // Base design width from the screenshot.
    const designWidth = 523.0;
    final screenW = MediaQuery.sizeOf(context).width;
    final scale = screenW / designWidth;

    double px(double v) => v * scale;

    // Outer padding from screenshot: L/R ~20px, top ~13px, between cards ~38px.
    final outerH = px(20);
    final outerTop = px(13);
    final betweenCards = px(38);

    return Scaffold(
      backgroundColor: AppTheme.screenBg,
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(
            fontSize: px(20),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.screenBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        automaticallyImplyLeading: false,
        actions: [
          // Dark grey vertical strip on the right (as per design)
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF787878), // Dark grey
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(px(24)),
                child: const CircularProgressIndicator(),
              ),
            );
          }

          if (state is OrdersError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(px(24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading orders',
                      style: TextStyle(
                        fontSize: px(16),
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: px(16)),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: px(14),
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: px(24)),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OrdersBloc>().add(const LoadUserOrders());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is OrdersLoaded) {
            final orders = state.orders;

            if (orders.isEmpty) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: AppTheme.screenBg, // White background
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(px(24)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: px(64),
                          color: Colors.grey[500],
                        ),
                        SizedBox(height: px(16)),
                        Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: px(18),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary, // Dark text on white
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: px(8)),
                        Text(
                          'Your orders will appear here',
                          style: TextStyle(
                            fontSize: px(14),
                            color: AppTheme.textSecondary, // Secondary dark text
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Container(
              color: AppTheme.screenBg, // White background for orders list
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<OrdersBloc>().add(const LoadUserOrders());
                  // Wait a bit for the state to update
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(outerH, outerTop, outerH, px(24)),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final item = _convertOrderToItemModel(order);
                  return OrderCard(
                    scale: scale,
                    item: item,
                    thumbnailAssetPath: order.thumbnailUrl ?? 'assets/icons/bottomNav/esim.png',
                    onTapViewDetails: () {
                      // Use appOrderId (the unique string identifier) for details lookup
                      final orderId = order.appOrderId ?? order.orderNumber ?? '';
                      // Navigate to order details screen (it will load its own data)
                      context.push('/orders/$orderId');
                    },
                    onTapOrderAgain: () {
                      // TODO: reorder action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order again tapped')),
                      );
                    },
                    onSetRating: (newRating) {
                      if (order.orderId != null) {
                        context.read<OrdersBloc>().add(
                              UpdateOrderRating(
                                orderId: order.orderId!,
                                rating: newRating,
                              ),
                            );
                      }
                    },
                  );
                },
                separatorBuilder: (_, __) => SizedBox(height: betweenCards),
                  itemCount: orders.length,
                ),
              ),
            );
          }

          // Initial state
          return const SizedBox.shrink();
        },
      ),
    );
  }

  OrderItemModel _convertOrderToItemModel(Order order) {
    Color statusColor;
    if (order.statusLabel?.toLowerCase().contains('complete') ?? false) {
      statusColor = AppTheme.successDot;
    } else if (order.statusLabel?.toLowerCase().contains('refund') ?? false) {
      statusColor = AppTheme.errorDot;
    } else {
      statusColor = const Color(0xFF787878); // grey
    }

    return OrderItemModel(
      deliveredText: order.deliveredText,
      statusLabel: order.statusLabel ?? order.status ?? 'Unknown',
      statusDotColor: statusColor,
      title: order.title ?? 'Order',
      orderId: order.orderNumber ?? order.orderId?.toString() ?? 'N/A',
      totalPrice: order.formattedTotalPrice,
      rating: order.rating ?? 0,
    );
  }
}

/// =======================
/// MODEL
/// =======================
class OrderItemModel {
  final String deliveredText;
  final String statusLabel;
  final Color statusDotColor;

  final String title;
  final String orderId;
  final String totalPrice;

  final int rating; // 0..5

  const OrderItemModel({
    required this.deliveredText,
    required this.statusLabel,
    required this.statusDotColor,
    required this.title,
    required this.orderId,
    required this.totalPrice,
    required this.rating,
  });

  OrderItemModel copyWith({int? rating}) {
    return OrderItemModel(
      deliveredText: deliveredText,
      statusLabel: statusLabel,
      statusDotColor: statusDotColor,
      title: title,
      orderId: orderId,
      totalPrice: totalPrice,
      rating: rating ?? this.rating,
    );
  }
}

/// =======================
/// ORDER CARD (pixel-matched)
/// =======================
class OrderCard extends StatelessWidget {
  final double scale;
  final OrderItemModel item;

  final String? thumbnailAssetPath;
  final VoidCallback onTapViewDetails;
  final VoidCallback onTapOrderAgain;
  final ValueChanged<int> onSetRating;

  const OrderCard({
    super.key,
    required this.scale,
    required this.item,
    required this.onTapViewDetails,
    required this.onTapOrderAgain,
    required this.onSetRating,
    this.thumbnailAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    double px(double v) => v * scale;

    // Card tokens (from screenshot measurements)
    final cardRadius = px(12); // acceptable 10–14
    final borderW = 1.0; // keep 1 logical px
    final headerHPad = px(24);
    final bodyHPad = px(24);

    final dividerH = 1.0;

    final ratingBarH = px(36);

    // Thumbnail
    final thumbW = px(85);
    final thumbH = px(84);
    final thumbRadius = px(8);

    // Body spacing
    final thumbTextGap = px(16);
    final bodyVPad = px(12);

    // Button (Order again)
    final btnW = px(146);
    final btnH = px(44);
    final btnRadius = btnH / 2;

    // Reserve space on right so left column doesn't slide under the button.
    final rightReserve = btnW + px(24); // ~170px at design scale

    // Positioning: button appears around mid-body aligned near price line.
    // This offset is approximate; tweak if needed when comparing to screenshot.
    final buttonTop = px(82);

    // Typography (approx sizes from screenshot)
    final headerTextStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: px(14),
      fontWeight: FontWeight.w600,
      color: AppTheme.textPrimary,
      height: 1.1,
    );

    final statusTextStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: px(14),
      fontWeight: FontWeight.w700,
      color: AppTheme.textPrimary,
      height: 1.1,
    );

    final titleStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: px(18),
      fontWeight: FontWeight.w700,
      color: AppTheme.textPrimary,
      height: 1.1,
    );

    final orderIdStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: px(14),
      fontWeight: FontWeight.w500,
      color: AppTheme.textSecondary,
      height: 1.1,
    );

    final priceStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: px(14),
      fontWeight: FontWeight.w700,
      color: AppTheme.textPrimary,
      height: 1.1,
    );

    final linkStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: px(14),
      fontWeight: FontWeight.w700,
      color: AppTheme.textPrimary,
      decoration: TextDecoration.underline,
      height: 1.1,
    );

    final buttonTextStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: px(14),
      fontWeight: FontWeight.w600,
      color: AppTheme.textPrimary,
      height: 1.0,
    );

    final rateLabelStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: px(14),
      fontWeight: FontWeight.w700,
      color: AppTheme.onPrimary,
      height: 1.0,
    );

    return GestureDetector(
      onTap: onTapViewDetails,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: AppTheme.cardBorderLavender, width: borderW),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Padding(
            padding: EdgeInsets.symmetric(horizontal: headerHPad),
            child: SizedBox(
              height: px(44), // approx
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      item.deliveredText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: headerTextStyle,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: px(10),
                        height: px(10),
                        decoration: BoxDecoration(
                          color: item.statusDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: px(10)),
                      Text(
                        item.statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: statusTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // DIVIDER
          Container(height: dividerH, color: AppTheme.dividerLight),

          // BODY (Stack for button alignment)
          Padding(
            padding: EdgeInsets.fromLTRB(bodyHPad, bodyVPad, bodyHPad, bodyVPad),
            child: Stack(
              children: [
                // Left flow content
                Padding(
                  padding: EdgeInsets.only(right: rightReserve),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: thumbnail + title/id
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(thumbRadius),
                            child: SizedBox(
                              width: thumbW,
                              height: thumbH,
                              child: _Thumbnail(
                                assetPath: thumbnailAssetPath,
                              ),
                            ),
                          ),
                          SizedBox(width: thumbTextGap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: titleStyle,
                                ),
                                SizedBox(height: px(10)),
                                Text(
                                  'Order ID: ${item.orderId}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: orderIdStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: px(16)),

                      // Price + link
                      Text(
                        'Total Price: ${item.totalPrice}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: priceStyle,
                      ),
                      SizedBox(height: px(10)),
                      GestureDetector(
                        onTap: onTapViewDetails,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          'View Details',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: linkStyle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right button overlay
                Positioned(
                  right: 0,
                  top: buttonTop,
                  child: SizedBox(
                    width: btnW,
                    height: btnH,
                    child: OutlinedButton(
                      onPressed: onTapOrderAgain,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: AppTheme.outlineGrey, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(btnRadius),
                        ),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Center(
                        child: Text('Order again', style: buttonTextStyle),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // RATING BAR
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(cardRadius),
              bottomRight: Radius.circular(cardRadius),
            ),
            child: Container(
              height: ratingBarH,
              color: AppTheme.primaryPurple,
              padding: EdgeInsets.symmetric(horizontal: px(24)),
              child: Row(
                children: [
                  Text('Rate', style: rateLabelStyle),
                  const Spacer(),
                  RatingStars(
                    scale: scale,
                    rating: item.rating,
                    onSetRating: onSetRating,
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnail loader with safe fallback (won't crash if asset missing).
class _Thumbnail extends StatelessWidget {
  final String? assetPath;
  const _Thumbnail({this.assetPath});

  @override
  Widget build(BuildContext context) {
    if (assetPath == null) {
      return _placeholder();
    }
    return Image.asset(
      assetPath!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE0E0E0),
      alignment: Alignment.center,
      child: const Icon(Icons.image, color: Color(0xFF9E9E9E)),
    );
  }
}

/// =======================
/// RATING STARS (5 icons)
/// =======================
class RatingStars extends StatelessWidget {
  final double scale;
  final int rating;
  final ValueChanged<int> onSetRating;

  const RatingStars({
    super.key,
    required this.scale,
    required this.rating,
    required this.onSetRating,
  });

  @override
  Widget build(BuildContext context) {
    double px(double v) => v * scale;

    final iconSize = px(24); // looks like 24px icons in screenshot
    final gap = px(18); // approx spacing between stars

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final idx = i + 1;
        final selected = idx <= rating;

        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : gap),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSetRating(idx),
            child: Icon(
              selected ? Icons.star : Icons.star_border,
              size: iconSize,
              color: selected ? AppTheme.starYellow : AppTheme.onPrimary,
            ),
          ),
        );
      }),
    );
  }
}
  