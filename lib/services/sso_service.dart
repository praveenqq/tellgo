import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tellgo_app/core/storage/token_storage.dart';
import 'package:tellgo_app/models/user_model.dart';

/// Service for handling SSO registration/login with backend API
class SSOService {
  SSOService._();
  static final SSOService I = SSOService._();
  factory SSOService() => I;

  // API base URL - using same base as login API
  static const String _ssoBaseUrl = 'https://appapi.tellgo.org';
  static const String _ssoEndpoint = '/User/SSORegisterUser';

  /// Register/login user via SSO API
  /// Returns UserModel with tokens stored automatically
  Future<UserModel> registerSSOUser({
    required String email,
    required String displayName,
    String? phoneNumber,
    required bool isNewUser,
    required String providerName, // "Google", "Apple", "Facebook"
    required String providerId, // "google.com", "apple.com", "facebook.com"
    required bool isEmailVerified,
  }) async {
    final requestStartTime = DateTime.now();
    
    try {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔄 SSO REGISTRATION STARTED');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📅 Time: ${requestStartTime.toIso8601String()}');
      debugPrint('🌐 Base URL: $_ssoBaseUrl');
      debugPrint('📍 Endpoint: $_ssoEndpoint');
      debugPrint('───────────────────────────────────────────────────────────');

      // Create Dio instance with SSO base URL if different
      final dio = Dio(BaseOptions(
        baseUrl: _ssoBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ));

      final requestData = {
        'email': email,
        'displayName': displayName,
        'phoneNumber': phoneNumber ?? '',
        'isNewUser': isNewUser,
        'providerName': providerName,
        'providerId': providerId,
        'isEmailVerified': isEmailVerified,
      };

      // Log request body
      debugPrint('📤 REQUEST BODY:');
      debugPrint('   Email: $email');
      debugPrint('   Display Name: $displayName');
      debugPrint('   Phone Number: ${phoneNumber ?? 'N/A'}');
      debugPrint('   Is New User: $isNewUser');
      debugPrint('   Provider Name: $providerName');
      debugPrint('   Provider ID: $providerId');
      debugPrint('   Is Email Verified: $isEmailVerified');
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('📦 Full Request JSON:');
      debugPrint(jsonEncode(requestData));
      debugPrint('───────────────────────────────────────────────────────────');

      debugPrint('⏳ Sending POST request to $_ssoBaseUrl$_ssoEndpoint...');

      final response = await dio.post(
        _ssoEndpoint,
        data: requestData,
      );

      final requestDuration = DateTime.now().difference(requestStartTime);
      debugPrint('⏱️  Request Duration: ${requestDuration.inMilliseconds}ms');
      debugPrint('───────────────────────────────────────────────────────────');

      // Log response status
      debugPrint('📥 RESPONSE RECEIVED:');
      debugPrint('   Status Code: ${response.statusCode}');
      debugPrint('   Status Message: ${response.statusMessage ?? 'N/A'}');
      debugPrint('───────────────────────────────────────────────────────────');

      if (response.statusCode != 200 || response.data == null) {
        debugPrint('❌ INVALID RESPONSE:');
        debugPrint('   Status Code: ${response.statusCode}');
        debugPrint('   Response Data: ${response.data}');
        debugPrint('═══════════════════════════════════════════════════════════');
        throw Exception('SSO registration failed: Invalid response');
      }

      final data = response.data;
      
      // Log full response
      debugPrint('📋 RESPONSE DATA:');
      if (data is Map) {
        debugPrint(jsonEncode(data));
      } else if (data is String) {
        debugPrint('   Response is a string: $data');
        // Try to parse if it's a JSON string
        try {
          final parsed = jsonDecode(data);
          debugPrint('   Parsed JSON: ${jsonEncode(parsed)}');
        } catch (_) {
          debugPrint('   Could not parse as JSON');
        }
      } else {
        debugPrint('   Response type: ${data.runtimeType}');
        debugPrint('   Response: $data');
      }
      debugPrint('───────────────────────────────────────────────────────────');
      
      // Handle both Map and String responses
      Map<String, dynamic> responseMap;
      if (data is Map) {
        responseMap = Map<String, dynamic>.from(data);
      } else if (data is String) {
        try {
          responseMap = Map<String, dynamic>.from(jsonDecode(data));
        } catch (_) {
          throw Exception('SSO registration failed: Invalid response format');
        }
      } else {
        throw Exception('SSO registration failed: Unexpected response type');
      }
      
      if (responseMap['success'] != true || responseMap['result'] == null) {
        final message = responseMap['message']?.toString() ?? 'SSO registration failed';
        final statusCode = responseMap['statusCode'] ?? 'N/A';
        debugPrint('❌ SSO REGISTRATION FAILED:');
        debugPrint('   Success: ${responseMap['success']}');
        debugPrint('   Status Code: $statusCode');
        debugPrint('   Message: $message');
        debugPrint('═══════════════════════════════════════════════════════════');
        throw Exception(message);
      }

      // Handle result - it might be a string (JSON) or an object
      dynamic resultData = responseMap['result'];
      Map<String, dynamic> result;
      
      if (resultData is String) {
        try {
          result = Map<String, dynamic>.from(jsonDecode(resultData));
        } catch (_) {
          throw Exception('SSO registration failed: Could not parse result');
        }
      } else if (resultData is Map) {
        result = Map<String, dynamic>.from(resultData);
      } else {
        throw Exception('SSO registration failed: Invalid result format');
      }
      
      // Extract tokens
      final accessToken = result['accessToken'] as String?;
      final refreshToken = result['refreshToken'] as String?;

      debugPrint('🔑 TOKEN EXTRACTION:');
      debugPrint('   Access Token Present: ${accessToken != null && accessToken.isNotEmpty}');
      debugPrint('   Refresh Token Present: ${refreshToken != null && refreshToken.isNotEmpty}');
      
      if (accessToken != null) {
        debugPrint('   Access Token Length: ${accessToken.length}');
        debugPrint('   Access Token Preview: ${accessToken.substring(0, accessToken.length > 50 ? 50 : accessToken.length)}...');
      }
      
      if (refreshToken != null) {
        debugPrint('   Refresh Token Length: ${refreshToken.length}');
        debugPrint('   Refresh Token Preview: ${refreshToken.substring(0, refreshToken.length > 50 ? 50 : refreshToken.length)}...');
      }
      debugPrint('───────────────────────────────────────────────────────────');

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('❌ NO ACCESS TOKEN RECEIVED');
        debugPrint('═══════════════════════════════════════════════════════════');
        throw Exception('SSO registration failed: No access token received');
      }

      // Store tokens
      debugPrint('💾 STORING TOKENS...');
      await TokenStorage.I.save(
        access: accessToken,
        refresh: refreshToken,
      );
      debugPrint('✅ Tokens stored successfully');
      debugPrint('───────────────────────────────────────────────────────────');

      // Build UserModel from API response
      // Combine firstName and lastName if available
      String fullName = displayName;
      if (result['firstName'] != null) {
        final firstName = result['firstName']?.toString() ?? '';
        final lastName = result['lastName']?.toString() ?? '';
        if (lastName.isNotEmpty) {
          fullName = '$firstName $lastName'.trim();
        } else {
          fullName = firstName;
        }
      }
      
      final userModel = UserModel(
        id: result['id']?.toString() ?? result['userIdentifier'] ?? '',
        email: result['email'] ?? email,
        name: fullName,
        phoneNumber: result['mobileNumber'] ?? phoneNumber,
        emailVerified: result['isOtpVerify'] == true || isEmailVerified,
      );

      debugPrint('👤 USER MODEL CREATED:');
      debugPrint('   ID: ${userModel.id}');
      debugPrint('   User Identifier: ${result['userIdentifier'] ?? 'N/A'}');
      debugPrint('   Email: ${userModel.email}');
      debugPrint('   First Name: ${result['firstName'] ?? 'N/A'}');
      debugPrint('   Last Name: ${result['lastName'] ?? 'N/A'}');
      debugPrint('   Mobile Number: ${result['mobileNumber'] ?? 'N/A'}');
      debugPrint('   Country Code: ${result['countryCode'] ?? 'N/A'}');
      debugPrint('   Is Active: ${result['isActive'] ?? 'N/A'}');
      debugPrint('   Is OTP Verified: ${result['isOtpVerify'] ?? 'N/A'}');
      debugPrint('   Last Login Date: ${result['lastLoginDate'] ?? 'N/A'}');
      debugPrint('   Email Verified: ${userModel.emailVerified}');
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('✅ SSO REGISTRATION SUCCESSFUL');
      debugPrint('═══════════════════════════════════════════════════════════');

      return userModel;
    } on DioException catch (e) {
      final requestDuration = DateTime.now().difference(requestStartTime);
      debugPrint('❌ DIO EXCEPTION:');
      debugPrint('   Error Type: ${e.type}');
      debugPrint('   Error Message: ${e.message}');
      debugPrint('   Request Duration: ${requestDuration.inMilliseconds}ms');
      
      if (e.response != null) {
        debugPrint('   Response Status Code: ${e.response!.statusCode}');
        debugPrint('   Response Data: ${e.response!.data}');
        
        // Safely extract error message from response
        String message = 'SSO registration failed';
        try {
          final responseData = e.response!.data;
          if (responseData is Map) {
            message = responseData['message']?.toString() ?? 
                     responseData['error']?.toString() ?? 
                     'SSO registration failed';
          } else if (responseData is String) {
            message = responseData.isNotEmpty ? responseData : 'SSO registration failed';
          }
        } catch (_) {
          // If parsing fails, use default message
          message = 'SSO registration failed (Status: ${e.response!.statusCode})';
        }
        
        debugPrint('   Error Message: $message');
        debugPrint('═══════════════════════════════════════════════════════════');
        throw Exception(message);
      } else {
        debugPrint('   No response received');
        debugPrint('═══════════════════════════════════════════════════════════');
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      final requestDuration = DateTime.now().difference(requestStartTime);
      debugPrint('❌ UNEXPECTED ERROR:');
      debugPrint('   Error: $e');
      debugPrint('   Request Duration: ${requestDuration.inMilliseconds}ms');
      debugPrint('   Stack Trace:');
      debugPrint(stackTrace.toString());
      debugPrint('═══════════════════════════════════════════════════════════');
      throw Exception('SSO registration failed: ${e.toString()}');
    }
  }
}
