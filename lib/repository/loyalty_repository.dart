import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/models/loyalty_models.dart';

abstract class LoyaltyRepository {
  Future<LoyaltyPoints> getUserLoyaltyPoints({String? currency});
  Future<List<LoyaltyTransaction>> getUserLoyaltyTransactions();
}

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  final AppDio _appDio;

  LoyaltyRepositoryImpl(this._appDio);

  @override
  Future<LoyaltyPoints> getUserLoyaltyPoints({String? currency}) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET AppLoyality/GetUserLoyalityPoints${currency != null ? '?currency=$currency' : ''}');
      }

      final response = await _appDio.get(
        'AppLoyality/GetUserLoyalityPoints',
        queryParameters: currency != null ? {'currency': currency} : null,
        auth: true,
      );

      if (kDebugMode) {
        debugPrint('✅ GET ${response.requestOptions.uri}');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      // API returns: {success, result: {...}, message, statusCode}
      final resultData = response.data as Map<String, dynamic>;
      final result = resultData['result'];

      if (result == null) {
        throw Exception('No loyalty points data received');
      }

      // Handle if result is a string (JSON string) or direct object
      Map<String, dynamic> pointsData;
      if (result is String) {
        try {
          pointsData = Map<String, dynamic>.from(jsonDecode(result));
        } catch (e) {
          throw Exception('Failed to parse loyalty points data: $e');
        }
      } else if (result is Map) {
        pointsData = Map<String, dynamic>.from(result);
      } else {
        throw Exception('Invalid loyalty points data format');
      }

      return LoyaltyPoints.fromJson(pointsData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting loyalty points: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<LoyaltyTransaction>> getUserLoyaltyTransactions() async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET AppLoyality/GetUserLoyalityTransactions');
      }

      final response = await _appDio.get(
        'AppLoyality/GetUserLoyalityTransactions',
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
      List<dynamic> transactionsList;
      if (result is String) {
        try {
          final parsed = jsonDecode(result);
          transactionsList = parsed is List ? parsed : [];
        } catch (e) {
          return [];
        }
      } else if (result is List) {
        transactionsList = result;
      } else {
        return [];
      }

      return transactionsList
          .map((json) => LoyaltyTransaction.fromJson(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting loyalty transactions: $e');
      }
      rethrow;
    }
  }
}

