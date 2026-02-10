import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/models/order_models.dart';

abstract class OrderRepository {
  Future<List<Order>> getUserOrders();
  Future<OrderDetails> getOrderDetails({required String orderId});
  Future<ValidateBundlePurchaseResponse> validateBundlePurchase(
    ValidateBundlePurchaseRequest request,
  );
}

class OrderRepositoryImpl implements OrderRepository {
  final AppDio _appDio;

  OrderRepositoryImpl(this._appDio);

  @override
  Future<List<Order>> getUserOrders() async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET AppOrder/GetUserOrders');
      }

      final response = await _appDio.get(
        'AppOrder/GetUserOrders',
        auth: true,
      );

      if (kDebugMode) {
        debugPrint('✅ GET ${response.requestOptions.uri}');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      // API returns: {success, result: [...], message, statusCode}
      final resultData = response.data as Map<String, dynamic>;
      final result = resultData['result'];

      if (result == null) {
        return [];
      }

      // Handle if result is a string (JSON string) or direct array
      List<dynamic> ordersList;
      if (result is String) {
        try {
          final parsed = jsonDecode(result);
          ordersList = parsed is List ? parsed : [];
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error parsing orders JSON string: $e');
          }
          return [];
        }
      } else if (result is List) {
        ordersList = result;
      } else {
        return [];
      }

      return ordersList
          .map((json) => Order.fromJson(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting user orders: $e');
      }
      rethrow;
    }
  }

  @override
  Future<OrderDetails> getOrderDetails({required String orderId}) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET AppOrder/GetOrderDetails?orderId=$orderId');
      }

      late final dynamic response;
      try {
        response = await _appDio.get(
        'AppOrder/GetOrderDetails',
        queryParameters: {'orderId': orderId},
        auth: true,
      );
      } on DioException catch (dioErr) {
        // Extract the server message from the response body if available
        if (dioErr.response?.data is Map<String, dynamic>) {
          final body = dioErr.response!.data as Map<String, dynamic>;
          final serverMsg = body['message']?.toString() ?? 'Request failed';
          throw Exception(serverMsg);
        }
        rethrow;
      }

      if (kDebugMode) {
        debugPrint('✅ GET ${response.requestOptions.uri}');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      // API returns: {success, result: [...], message, statusCode}
      // result is a LIST of order line items
      final resultData = response.data as Map<String, dynamic>;
      final result = resultData['result'];

      if (result == null) {
        throw Exception('Order details not found');
      }

      // Handle the different shapes the result can come in
      if (result is List) {
        // API returns a list of order line items
        if (result.isEmpty) {
          throw Exception('No order details found for this order');
        }
        return OrderDetails.fromItemsList(orderId, result);
      } else if (result is String) {
        // Result is a JSON string
        try {
          final parsed = jsonDecode(result);
          if (parsed is List) {
            return OrderDetails.fromItemsList(orderId, parsed);
          } else if (parsed is Map<String, dynamic>) {
            return OrderDetails.fromJson(parsed);
          }
        } catch (e) {
          throw Exception('Failed to parse order details: $e');
        }
      } else if (result is Map<String, dynamic>) {
        return OrderDetails.fromJson(result);
      }

      throw Exception('Unexpected order details format');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting order details: $e');
      }
      rethrow;
    }
  }

  @override
  Future<ValidateBundlePurchaseResponse> validateBundlePurchase(
    ValidateBundlePurchaseRequest request,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 POST AppOrder/ValidateBundlePurchase');
        debugPrint(const JsonEncoder.withIndent('  ').convert(request.toJson()));
      }

      final response = await _appDio.post(
        'AppOrder/ValidateBundlePurchase',
        data: request.toJson(),
        auth: true,
      );

      if (kDebugMode) {
        debugPrint('✅ POST ${response.requestOptions.uri}');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      // API returns: {success, result: {...}, message, statusCode}
      final resultData = response.data as Map<String, dynamic>;

      return ValidateBundlePurchaseResponse.fromJson(resultData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error validating bundle purchase: $e');
      }
      rethrow;
    }
  }
}

