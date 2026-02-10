import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/models/wallet_models.dart';

abstract class WalletRepository {
  Future<WalletBalance> getUserWalletBalance();
  Future<List<WalletTransaction>> getWalletTransactions();
  Future<List<WalletDenomination>> getWalletTopUpDenominations({required int countryId});
  Future<TopUpResponse> topUpUserWallet(TopUpRequest request);
  Future<ProcessTransactionResponse> processTransaction(String transactionId);
}

class WalletRepositoryImpl implements WalletRepository {
  final AppDio _appDio;

  WalletRepositoryImpl(this._appDio);

  /// Helper to parse payment channels from the API response
  /// API returns: [{serviceId: 3, paymentChannelId: [3, 2], channelCode: ["TGWallet", "MyFatoorah"]}]
  List<PaymentChannel> _parsePaymentChannels(dynamic paymentChannelsData) {
    if (paymentChannelsData == null) return [];
    
    final List<PaymentChannel> channels = [];
    
    try {
      if (paymentChannelsData is List) {
        for (final item in paymentChannelsData) {
          if (item is Map) {
            final channelCodes = item['channelCode'];
            
            if (channelCodes is List) {
              for (int i = 0; i < channelCodes.length; i++) {
                final code = channelCodes[i]?.toString() ?? '';
                if (code.isNotEmpty) {
                  channels.add(PaymentChannel(
                    code: code,
                    name: _getPaymentChannelDisplayName(code),
                    isActive: true,
                  ));
                }
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error parsing payment channels: $e');
      }
    }
    
    if (kDebugMode) {
      debugPrint('📌 Parsed ${channels.length} payment channels: ${channels.map((c) => c.code).toList()}');
    }
    
    return channels;
  }

  /// Get display name for payment channel code
  String _getPaymentChannelDisplayName(String code) {
    switch (code.toLowerCase()) {
      case 'myfatoorah':
        return 'MyFatoorah';
      case 'tgwallet':
        return 'TellGo Wallet';
      case 'tellgowallet':
        return 'TellGo Wallet';
      default:
        return code;
    }
  }

  @override
  Future<WalletBalance> getUserWalletBalance() async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET AppWallet/GetUserWalletBalance');
      }

      final response = await _appDio.get(
        'AppWallet/GetUserWalletBalance',
        auth: true,
      );

      if (kDebugMode) {
        debugPrint('✅ GET ${response.requestOptions.uri}');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      // API returns: {success, result: {balance, currency, ...}, message, statusCode}
      final resultData = response.data as Map<String, dynamic>;
      final result = resultData['result'];
      
      if (result == null) {
        throw Exception('No balance data received');
      }

      // Handle if result is a string (JSON string) or direct object
      Map<String, dynamic> balanceData;
      if (result is String) {
        try {
          balanceData = Map<String, dynamic>.from(jsonDecode(result));
        } catch (e) {
          throw Exception('Failed to parse balance data: $e');
        }
      } else if (result is Map) {
        balanceData = Map<String, dynamic>.from(result);
      } else {
        throw Exception('Invalid balance data format');
      }

      return WalletBalance.fromJson(balanceData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting wallet balance: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<WalletTransaction>> getWalletTransactions() async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET AppWallet/GetWalletTransaction');
      }

      final response = await _appDio.get(
        'AppWallet/GetWalletTransaction',
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
          .map((json) => WalletTransaction.fromJson(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting wallet transactions: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<WalletDenomination>> getWalletTopUpDenominations({
    required int countryId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET AppWallet/GetWalletTopUpDenomination?countryId=$countryId');
      }

      final response = await _appDio.get(
        'AppWallet/GetWalletTopUpDenomination',
        queryParameters: {'countryId': countryId},
        auth: true,
      );

      if (kDebugMode) {
        debugPrint('✅ GET ${response.requestOptions.uri}');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      // API returns: {success, result: {paymentChannels: [...], denominations: [...]}, message, statusCode}
      final resultData = response.data as Map<String, dynamic>;
      final result = resultData['result'];
      
      if (result == null) {
        return [];
      }

      // Handle different response structures
      List<dynamic> denominationsList;
      List<PaymentChannel> paymentChannels = [];
      
      if (result is String) {
        // Result is a JSON string
        try {
          final parsed = jsonDecode(result);
          if (parsed is List) {
            denominationsList = parsed;
          } else if (parsed is Map) {
            // Nested structure: {paymentChannels: [...], denominations: [...]}
            denominationsList = (parsed['denominations'] as List?) ?? [];
            paymentChannels = _parsePaymentChannels(parsed['paymentChannels']);
          } else {
            return [];
          }
        } catch (e) {
          return [];
        }
      } else if (result is List) {
        // Direct array of denominations
        denominationsList = result;
      } else if (result is Map) {
        // Nested structure: {paymentChannels: [...], denominations: [...]}
        denominationsList = (result['denominations'] as List?) ?? [];
        paymentChannels = _parsePaymentChannels(result['paymentChannels']);
      } else {
        return [];
      }

      return denominationsList
          .map((json) {
            final denomJson = json is Map<String, dynamic>
                    ? json
                : Map<String, dynamic>.from(json);
            // Attach payment channels to each denomination
            denomJson['paymentChannels'] = paymentChannels.map((c) => {
              'code': c.code,
              'name': c.name,
              'isActive': c.isActive,
            }).toList();
            return WalletDenomination.fromJson(denomJson);
          })
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting wallet denominations: $e');
      }
      rethrow;
    }
  }

  @override
  Future<TopUpResponse> topUpUserWallet(TopUpRequest request) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 POST AppWallet/TopUpUserWallet');
        debugPrint(const JsonEncoder.withIndent('  ').convert(request.toJson()));
      }

      final response = await _appDio.post(
        'AppWallet/TopUpUserWallet',
        data: request.toJson(),
        auth: true,
      );

      if (kDebugMode) {
        debugPrint('✅ POST ${response.requestOptions.uri}');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      // API returns: {success, result: {transactionId, paymentTransactionId, ...}, message, statusCode}
      final resultData = response.data as Map<String, dynamic>;
      
      return TopUpResponse.fromJson(resultData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error topping up wallet: $e');
      }
      rethrow;
    }
  }

  @override
  Future<ProcessTransactionResponse> processTransaction(String transactionId) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 POST api/AppPayments/ProcessTransaction');
        debugPrint('↳ transactionId (as JSON string body): ${jsonEncode(transactionId)}');
      }

      // The API expects the transactionId as a JSON-encoded string in the request body
      // Must use jsonEncode to add quotes and set Content-Type to application/json
      final response = await _appDio.post(
        'api/AppPayments/ProcessTransaction',
        data: jsonEncode(transactionId), // JSON-encode the string (adds quotes)
        options: Options(contentType: 'application/json'),
        auth: true,
      );

      if (kDebugMode) {
        debugPrint('✅ POST ${response.requestOptions.uri}');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      // API returns: {success, result: string, message, statusCode}
      final resultData = response.data as Map<String, dynamic>;
      
      return ProcessTransactionResponse.fromJson(resultData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error processing transaction: $e');
      }
      rethrow;
    }
  }
}

