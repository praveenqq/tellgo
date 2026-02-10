import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/models/gift_card_models.dart';

abstract class GiftCardRepository {
  Future<GiftCardDenominationResult> getGiftCardDenominations({
    required int countryId,
  });
  Future<List<GiftCardPurchaseHistory>> getUserGiftCardPurchaseHistory();
  Future<List<GiftCardRedeemHistory>> getUserGiftCardRedeemHistory();
  Future<GiftCardPurchaseResponse> purchaseGiftCard(
    GiftCardPurchaseRequest request,
  );
  Future<GiftCardProcessTransactionResponse> processTransaction(String transactionId);
}

class GiftCardRepositoryImpl implements GiftCardRepository {
  final AppDio _appDio;

  GiftCardRepositoryImpl(this._appDio);

  @override
  Future<GiftCardDenominationResult> getGiftCardDenominations({
    required int countryId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET GiftCard/GetGiftCardDenomination?countryId=$countryId');
      }

      final response = await _appDio.get(
        'GiftCard/GetGiftCardDenomination',
        queryParameters: {'countryId': countryId},
        auth: true,
      );

      if (kDebugMode) {
        debugPrint('✅ GET ${response.requestOptions.uri}');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      // API returns: {success, result: {giftCardDenomination: [...], paymentChannels: [...]}, message, statusCode}
      final resultData = response.data as Map<String, dynamic>;
      final result = resultData['result'];

      if (result == null) {
        return const GiftCardDenominationResult(
          denominations: [],
          paymentChannels: [],
        );
      }

      // Handle different response structures
      List<dynamic> denominationsList = [];
      List<dynamic> paymentChannelsList = [];
      
      if (result is String) {
        try {
          final parsed = jsonDecode(result);
          if (parsed is List) {
            denominationsList = parsed;
          } else if (parsed is Map) {
            // Nested structure: {giftCardDenomination: [...], paymentChannels: [...]}
            denominationsList = (parsed['giftCardDenomination'] as List?) ?? [];
            paymentChannelsList = (parsed['paymentChannels'] as List?) ?? [];
          }
        } catch (e) {
          // Return empty result on parse error
        }
      } else if (result is List) {
        // Direct array of denominations (old format)
        denominationsList = result;
      } else if (result is Map) {
        // Nested structure: {giftCardDenomination: [...], paymentChannels: [...]}
        denominationsList = (result['giftCardDenomination'] as List?) ?? [];
        paymentChannelsList = (result['paymentChannels'] as List?) ?? [];
        if (kDebugMode) {
          debugPrint('📌 Parsed ${denominationsList.length} gift card denominations');
          debugPrint('📌 Parsed ${paymentChannelsList.length} payment channels');
        }
      }

      final denominations = denominationsList
          .map((json) => GiftCardDenomination.fromJson(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ))
          .toList();

      // Parse payment channels - check if it's the new format with individual channel info
      List<GiftCardPaymentChannel> paymentChannels = [];
      
      if (paymentChannelsList.isNotEmpty) {
        // Check if it's the new format (array of {paymentChannelId, paymentChannelName, paymentChannelCode, paymentChannelLogo})
        final firstChannel = paymentChannelsList.first;
        if (firstChannel is Map && firstChannel.containsKey('paymentChannelCode')) {
          // New format - parse as individual PaymentChannelInfo objects
          final channelInfos = paymentChannelsList
              .map((json) => PaymentChannelInfo.fromJson(
                    json is Map<String, dynamic>
                        ? json
                        : Map<String, dynamic>.from(json),
                  ))
              .toList();
          
          // Create a single GiftCardPaymentChannel containing all channel infos
          paymentChannels = [GiftCardPaymentChannel.fromChannelsList(channelInfos)];
          
          if (kDebugMode) {
            debugPrint('📌 Parsed ${channelInfos.length} payment channel infos (new format)');
            for (final ch in channelInfos) {
              debugPrint('   - ${ch.name} (${ch.code}): logo=${ch.logo}');
            }
          }
        } else {
          // Old format
          paymentChannels = paymentChannelsList
              .map((json) => GiftCardPaymentChannel.fromJson(
                    json is Map<String, dynamic>
                        ? json
                        : Map<String, dynamic>.from(json),
                  ))
              .toList();
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Returning ${denominations.length} denominations and ${paymentChannels.length} payment channels');
        for (final channel in paymentChannels) {
          debugPrint('   Channel codes: ${channel.channelCodes}');
        }
      }

      return GiftCardDenominationResult(
        denominations: denominations,
        paymentChannels: paymentChannels,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting gift card denominations: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<GiftCardPurchaseHistory>> getUserGiftCardPurchaseHistory() async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET GiftCard/GetUserGiftCardPurchaseHistory');
      }

      final response = await _appDio.get(
        'GiftCard/GetUserGiftCardPurchaseHistory',
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
      List<dynamic> historyList;
      if (result is String) {
        try {
          final parsed = jsonDecode(result);
          historyList = parsed is List ? parsed : [];
        } catch (e) {
          return [];
        }
      } else if (result is List) {
        historyList = result;
      } else {
        return [];
      }

      return historyList
          .map((json) => GiftCardPurchaseHistory.fromJson(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting gift card purchase history: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<GiftCardRedeemHistory>> getUserGiftCardRedeemHistory() async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET GiftCard/GetUserGiftCardRedeemHistory');
      }

      final response = await _appDio.get(
        'GiftCard/GetUserGiftCardRedeemHistory',
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
      List<dynamic> historyList;
      if (result is String) {
        try {
          final parsed = jsonDecode(result);
          historyList = parsed is List ? parsed : [];
        } catch (e) {
          return [];
        }
      } else if (result is List) {
        historyList = result;
      } else {
        return [];
      }

      return historyList
          .map((json) => GiftCardRedeemHistory.fromJson(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting gift card redeem history: $e');
      }
      rethrow;
    }
  }

  @override
  Future<GiftCardPurchaseResponse> purchaseGiftCard(
    GiftCardPurchaseRequest request,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 POST GiftCard/PurchaseGiftCard');
        debugPrint(const JsonEncoder.withIndent('  ').convert(request.toJson()));
      }

      final response = await _appDio.post(
        'GiftCard/PurchaseGiftCard',
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

      return GiftCardPurchaseResponse.fromJson(resultData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error purchasing gift card: $e');
      }
      rethrow;
    }
  }

  @override
  Future<GiftCardProcessTransactionResponse> processTransaction(String transactionId) async {
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
      
      return GiftCardProcessTransactionResponse.fromJson(resultData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error processing transaction: $e');
      }
      rethrow;
    }
  }
}

