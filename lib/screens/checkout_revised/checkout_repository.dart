import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tellgo_app/core/network/app_dio.dart';

/// Repository for checkout-related API calls
class CheckoutRepository {
  final Dio _dio = AppDio().dio;

  /// Get available payment channels for a service
  /// 
  /// [serviceId] - The service ID to get channels for (default: 1 for eSIM bundles)
  /// Returns a list of [PaymentChannel] or empty list on error
  Future<List<PaymentChannel>> getServiceChannels({int serviceId = 1}) async {
    try {
      final response = await _dio.get(
        'AppPayment/GetServiceChannels',
        queryParameters: {'serviceId': serviceId},
        options: Options(
          extra: {'auth': true},
        ),
      );

      final data = response.data as Map<String, dynamic>?;
      
      if (data != null && data['success'] == true) {
        final result = data['result'] as List?;
        if (result != null) {
          return result
              .map((e) => PaymentChannel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      
      return [];
    } on DioException catch (e) {
      // Log error but return empty list
      // ignore: avoid_print
      print('❌ GetServiceChannels error: ${e.message}');
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('❌ GetServiceChannels unexpected error: $e');
      return [];
    }
  }

  /// Apply coupon code to an order
  /// 
  /// Returns a [CouponResult] with discount information or error message
  Future<CouponResult> applyCouponCode({
    required int bundleId,
    required int quantity,
    required double orderAmount,
    required String couponCode,
    int? orderId,
    bool processCoupon = true,
  }) async {
    try {
      final response = await _dio.post(
        'TelgoPromotion/ApplyCouponCode',
        data: {
          'purchaseItems': [
            {
              'bunddleId': bundleId, // Note: API has typo 'bunddleId'
              'purchaseQuantity': quantity,
            }
          ],
          'couponCode': couponCode,
          'orderAmount': orderAmount,
          'orderId': orderId ?? 0,
          'processCoupon': processCoupon,
        },
        options: Options(
          extra: {'auth': true},
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final data = response.data as Map<String, dynamic>?;
      
      if (data != null && data['success'] == true) {
        final result = data['result'];
        
        // Parse the result - could be a discount amount or discount object
        double? discountAmount;
        String? discountType;
        double? discountPercentage;
        
        if (result is num) {
          discountAmount = result.toDouble();
        } else if (result is String) {
          discountAmount = double.tryParse(result);
        } else if (result is Map<String, dynamic>) {
          discountAmount = (result['discountAmount'] as num?)?.toDouble();
          discountType = result['discountType']?.toString();
          discountPercentage = (result['discountPercentage'] as num?)?.toDouble();
        }
        
        return CouponResult(
          success: true,
          message: data['message']?.toString() ?? 'Coupon applied successfully',
          discountAmount: discountAmount,
          discountType: discountType,
          discountPercentage: discountPercentage,
        );
      } else {
        return CouponResult(
          success: false,
          message: data?['message']?.toString() ?? 'Failed to apply coupon',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to apply coupon';
      
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        final serverMessage = data['message']?.toString();
        
        // Map server messages to more user-friendly messages
        if (serverMessage != null) {
          if (serverMessage.toLowerCase().contains('promotion rules not found')) {
            errorMessage = 'This coupon is not applicable for this product';
          } else if (serverMessage.toLowerCase().contains('invalid or inactive')) {
            errorMessage = 'Invalid or expired coupon code';
          } else if (serverMessage.toLowerCase().contains('already used')) {
            errorMessage = 'This coupon has already been used';
          } else if (serverMessage.toLowerCase().contains('expired')) {
            errorMessage = 'This coupon has expired';
          } else {
            errorMessage = serverMessage;
          }
        }
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Please login to apply coupon';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Invalid coupon code';
      }
      
      return CouponResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      return CouponResult(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Validate bundle purchase and get payment URL
  /// 
  /// [paymentChannelCode] - The payment channel code (e.g., 'MyFatoorah', 'GiftCard')
  /// [cartTotal] - Total cart amount (full price, before discount)
  /// [finalTotal] - Final total (should be same as cartTotal - backend applies discount)
  /// [purchaseItems] - List of items to purchase
  /// [giftCardCode] - Gift card code (required for GiftCard payment)
  /// [discountCoupon] - Applied coupon code (backend calculates & applies discount)
  /// [currency] - Currency code (default: 'USD')
  /// 
  /// Note: Send FULL price in both cartTotal and finalTotal. The backend will
  /// calculate and apply the discount based on the discountCoupon code.
  /// 
  /// Returns [BundlePurchaseValidationResult] with payment URL or error
  Future<BundlePurchaseValidationResult> validateBundlePurchase({
    required String paymentChannelCode,
    required double cartTotal,
    required double finalTotal,
    required List<PurchaseItem> purchaseItems,
    String? giftCardCode,
    String? discountCoupon,
    String loyalityRedeemPoints = '0',
    String currency = 'USD',
  }) async {
    try {
      final requestBody = {
        'paymentChannelCode': paymentChannelCode,
        'loyalityRedeemPoints': loyalityRedeemPoints,
        'cartTotal': cartTotal,
        'discountCoupon': discountCoupon ?? '',
        'finalTotal': finalTotal,
        'purchaseItems': purchaseItems.map((item) => item.toJson()).toList(),
        'giftCardCode': giftCardCode ?? '',
        'currency': currency,
      };

      if (kDebugMode) {
        debugPrint('🛒 ValidateBundlePurchase request: $requestBody');
      }

      final response = await _dio.post(
        'AppOrder/ValidateBundlePurchase',
        data: requestBody,
        options: Options(
          extra: {'auth': true},
          headers: {'Content-Type': 'application/json'},
          // Longer timeout for gift card validation (can take time on server)
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data as Map<String, dynamic>?;

      if (kDebugMode) {
        debugPrint('🛒 ValidateBundlePurchase response: $data');
      }

      if (data != null && data['success'] == true) {
        final result = data['result'] as Map<String, dynamic>?;
        
        return BundlePurchaseValidationResult(
          success: true,
          message: data['message']?.toString() ?? 'Transaction validated successfully',
          orderId: result?['orderId']?.toString(),
          appOrderId: result?['appOrderId'] as int?,
          paymentUrl: result?['paymentUrl']?.toString(),
          paymentTransactionId: result?['paymentTransactionId']?.toString(),
          totalAmount: (result?['totalAmount'] as num?)?.toDouble(),
          remainingAmount: (result?['remainingAmount'] as num?)?.toDouble(),
          paymentChannel: result?['paymentChannel']?.toString(),
          currency: result?['currency']?.toString(),
        );
      } else {
        return BundlePurchaseValidationResult(
          success: false,
          message: data?['message']?.toString() ?? 'Failed to validate purchase',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to validate purchase';
      
      // Handle timeout errors
      if (e.type == DioExceptionType.receiveTimeout || 
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Request timed out. Please check your connection and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error. Please check your internet connection.';
      } else if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        final serverMessage = data['message']?.toString();
        
        if (serverMessage != null) {
          if (serverMessage.toLowerCase().contains('gift card not found')) {
            errorMessage = 'Invalid gift card code';
          } else if (serverMessage.toLowerCase().contains('insufficient balance')) {
            errorMessage = 'Insufficient gift card balance';
          } else if (serverMessage.toLowerCase().contains('expired')) {
            errorMessage = 'Gift card has expired';
          } else {
            errorMessage = serverMessage;
          }
        }
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Please login to continue';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Invalid request. Please check your details.';
      }
      
      if (kDebugMode) {
        debugPrint('❌ ValidateBundlePurchase error: $errorMessage');
      }
      
      return BundlePurchaseValidationResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ValidateBundlePurchase unexpected error: $e');
      }
      return BundlePurchaseValidationResult(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Process a payment transaction after payment completion
  /// 
  /// [transactionId] - The transaction ID from payment callback
  /// [paymentStatus] - The payment status from callback URL (optional)
  /// 
  /// Returns [TransactionProcessResult] with purchase details or error
  Future<TransactionProcessResult> processTransaction(
    String transactionId, {
    String? paymentStatus,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('💳 ProcessTransaction request: transactionId=$transactionId');
      }

      final response = await _dio.post(
        'api/AppPayments/ProcessTransaction',
        data: '"$transactionId"',
        options: Options(
          extra: {'auth': true},
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final data = response.data as Map<String, dynamic>?;

      if (kDebugMode) {
        debugPrint('💳 ProcessTransaction response: $data');
      }

      if (data != null && data['success'] == true) {
        return TransactionProcessResult(
          success: true,
          message: data['message']?.toString() ?? 'Transaction processed successfully',
          result: data['result'],
        );
      } else {
        return TransactionProcessResult(
          success: false,
          message: data?['message']?.toString() ?? 'Failed to process transaction',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to process transaction';
      bool isKnownOrderTypeError = false;
      
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        final serverMessage = data['message']?.toString();
        errorMessage = serverMessage ?? errorMessage;
        
        // Check if this is the "Unknown order type" error for bundle purchases
        // This happens because backend ProcessTransaction doesn't support bundle orders yet
        if (serverMessage != null && serverMessage.toLowerCase().contains('unknown order type')) {
          isKnownOrderTypeError = true;
          if (kDebugMode) {
            debugPrint('⚠️ Bundle order type not supported by ProcessTransaction API');
          }
        }
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Session expired. Please login again.';
      }
      
      if (kDebugMode) {
        debugPrint('❌ ProcessTransaction error: $errorMessage');
      }
      
      // If payment was successful (from callback URL) but ProcessTransaction failed
      // due to "unknown order type", treat as success since payment went through
      if (isKnownOrderTypeError && paymentStatus?.toLowerCase() == 'success') {
        if (kDebugMode) {
          debugPrint('✅ Payment was successful despite ProcessTransaction error');
        }
        return TransactionProcessResult(
          success: true,
          message: 'Your bundle purchase was successful!',
          isPartialSuccess: true,
        );
      }
      
      return TransactionProcessResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ProcessTransaction unexpected error: $e');
      }
      return TransactionProcessResult(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }
}

/// Result of bundle purchase validation
class BundlePurchaseValidationResult {
  final bool success;
  final String message;
  final String? orderId;
  final int? appOrderId;
  final String? paymentUrl;
  final String? paymentTransactionId;
  final double? totalAmount;
  final double? remainingAmount;
  final String? paymentChannel;
  final String? currency;

  const BundlePurchaseValidationResult({
    required this.success,
    required this.message,
    this.orderId,
    this.appOrderId,
    this.paymentUrl,
    this.paymentTransactionId,
    this.totalAmount,
    this.remainingAmount,
    this.paymentChannel,
    this.currency,
  });
}

/// Result of transaction processing
class TransactionProcessResult {
  final bool success;
  final String message;
  final dynamic result;
  /// True if payment succeeded but backend processing had issues (e.g., unknown order type)
  final bool isPartialSuccess;

  const TransactionProcessResult({
    required this.success,
    required this.message,
    this.result,
    this.isPartialSuccess = false,
  });
}

/// Purchase item for validation request
class PurchaseItem {
  final int bundleId;
  final int categoryId;
  final int subCategoryId;
  final int purchasedQuantity;
  final double pricePerunit;

  const PurchaseItem({
    required this.bundleId,
    required this.categoryId,
    required this.subCategoryId,
    required this.purchasedQuantity,
    required this.pricePerunit,
  });

  Map<String, dynamic> toJson() => {
    'bundleId': bundleId,
    'categoryId': categoryId,
    'subCategoryId': subCategoryId,
    'purchasedQuantity': purchasedQuantity,
    'pricePerunit': pricePerunit,
  };
}

/// Result of applying a coupon code
class CouponResult {
  final bool success;
  final String message;
  final double? discountAmount;
  final String? discountType;
  final double? discountPercentage;

  const CouponResult({
    required this.success,
    required this.message,
    this.discountAmount,
    this.discountType,
    this.discountPercentage,
  });
}

/// Payment channel model from GetServiceChannels API
class PaymentChannel {
  final int id;
  final String name;
  final String code;
  final String? logo;

  const PaymentChannel({
    required this.id,
    required this.name,
    required this.code,
    this.logo,
  });

  factory PaymentChannel.fromJson(Map<String, dynamic> json) {
    return PaymentChannel(
      id: json['paymentChannelId'] ?? 0,
      name: json['paymentChannelName']?.toString() ?? '',
      code: json['paymentChannelCode']?.toString() ?? '',
      logo: json['paymentChannelLogo']?.toString(),
    );
  }

  /// Check if this is a wallet payment method
  bool get isWallet => code.toLowerCase().contains('wallet');

  /// Check if this is a gift card payment method
  bool get isGiftCard => code.toLowerCase().contains('giftcard');

  /// Check if this is an external payment gateway (like MyFatoorah)
  bool get isExternalGateway => !isWallet && !isGiftCard;
}

