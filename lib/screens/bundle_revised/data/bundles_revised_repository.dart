// lib/screens/bundle_revised/data/bundles_revised_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/core/storage/token_storage.dart';

import 'models.dart';

class BundlesRevisedRepository {
  BundlesRevisedRepository({Dio? client}) : _dio = client ?? AppDio().dio;
  final Dio _dio;

  // Build Authorization header from TokenStorage
  Future<Map<String, String>> _authHeaders() async {
    try {
      final token = await TokenStorage.I.getAccess();
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ No access token found in TokenStorage');
        return const {'Accept': 'application/json'};
      }
      return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
    } catch (e) {
      debugPrint('❌ Error reading token from TokenStorage: $e');
      return const {'Accept': 'application/json'};
    }
  }

  /// Get all categories (Local eSIMs, Regional eSIMs, Global eSIMs)
  /// Endpoint: /Bundles/GetAllCategories
  Future<List<BundleCategory>> getAllCategories() async {
    const label = 'GET AllCategories';
    final url = '${_dio.options.baseUrl}Bundles/GetAllCategories';
    _logRequest(label, url);

    try {
      final r = await _dio.get(
        'Bundles/GetAllCategories',
        options: Options(
          responseType: ResponseType.json,
          headers: await _authHeaders(),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      _logResponse(label, r);

      final data = r.data as Map<String, dynamic>? ?? {};
      final result = (data['result'] as List?) ?? [];
      
      final categories = result
          .map((e) => BundleCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      
      debugPrint('📊 GetAllCategories - returned ${categories.length} categories');
      return categories;
    } on DioException catch (e) {
      _logError(label, e);
      rethrow;
    }
  }

  /// Get subcategories (countries/regions) for a specific category
  /// Uses /Bundles/GetAllSubCategories?currencyCode=USD to get prices
  /// Then filters by categoryId client-side
  Future<List<BundleSubCategory>> getSubCategoriesByCategoryId(int categoryId) async {
    final label = 'GET SubCategories for category $categoryId';
    final url = '${_dio.options.baseUrl}Bundles/GetAllSubCategories?currencyCode=USD';
    _logRequest(label, url);

    try {
      final r = await _dio.get(
        'Bundles/GetAllSubCategories',
        queryParameters: {'currencyCode': 'USD'},
        options: Options(
          responseType: ResponseType.json,
          headers: await _authHeaders(),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      _logResponse(label, r);

      final data = r.data as Map<String, dynamic>? ?? {};
      final result = (data['result'] as List?) ?? [];
      
      // Debug: Print raw JSON for first item to see all available fields
      if (result.isNotEmpty) {
        debugPrint('📋 RAW SubCategory JSON (first item): ${result.first}');
      }
      
      final allSubCategories = result
          .map((e) => BundleSubCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // Filter by categoryId
      final subCategories = allSubCategories
          .where((sc) => sc.categoryId == categoryId)
          .toList();
      
      debugPrint('📊 GetAllSubCategories filtered for categoryId=$categoryId - returned ${subCategories.length} subcategories');
      // Debug: Log lowestPrice for each subcategory
      for (final sc in subCategories.take(3)) {
        debugPrint('   → ${sc.name}: lowestPrice = ${sc.lowestPrice}');
      }
      return subCategories;
    } on DioException catch (e) {
      _logError(label, e);
      rethrow;
    }
  }

  /// Get bundles for a specific subcategory (country/region)
  /// Endpoint: /Bundles?subCategoryId=X&page=Y&pageSize=Z
  Future<BundlesRevisedPage> getBundlesBySubCategoryId({
    required int subCategoryId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final label = 'GET Bundles for subCategory $subCategoryId';
    
    final queryParams = <String, dynamic>{
      'subCategoryId': subCategoryId,
      'page': page,
      'pageSize': pageSize,
    };
    
    final url = '${_dio.options.baseUrl}Bundles?${Uri(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString()))).query}';
    _logRequest(label, url);

    try {
      final r = await _dio.get(
        'Bundles',
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.json,
          headers: await _authHeaders(),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      _logResponse(label, r);

      final data = r.data as Map<String, dynamic>? ?? {};
      final bundlesPage = BundlesRevisedPage.fromEnvelope(data);
      
      debugPrint('📊 GetBundlesBySubCategoryId($subCategoryId) - returned ${bundlesPage.bundles.length} bundles');
      return bundlesPage;
    } on DioException catch (e) {
      _logError(label, e);
      rethrow;
    }
  }

  /// DEPRECATED: Get bundles by category (old API - kept for backward compatibility)
  /// Use getSubCategoriesByCategoryId + getBundlesBySubCategoryId instead
  Future<BundlesRevisedPage> getBundlesByCategory({
    int? categoryId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final label = 'GET Bundles${categoryId != null ? ' (category: $categoryId)' : ''}';
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    
    final url = '${_dio.options.baseUrl}Bundles?${Uri(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString()))).query}';
    _logRequest(label, url);

    try {
      final r = await _dio.get(
        'Bundles',
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.json,
          headers: await _authHeaders(),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      if (r.statusCode != null && r.statusCode! >= 400) {
        throw DioException(
          requestOptions: r.requestOptions,
          response: r,
          type: DioExceptionType.badResponse,
          error: 'Failed to load bundles (Status: ${r.statusCode})',
        );
      }

      _logResponse(label, r);

      final data = r.data is Map ? r.data : {};
      final bundlesPage = BundlesRevisedPage.fromEnvelope(data as Map<String, dynamic>);
      
      // Filter by categoryId client-side if provided
      if (categoryId != null) {
        final filtered = bundlesPage.bundles.where((b) => b.categoryId == categoryId).toList();
        debugPrint('📊 Filtered ${bundlesPage.bundles.length} bundles to ${filtered.length} for categoryId $categoryId');
        
        return BundlesRevisedPage(
          bundles: filtered,
          totalCount: filtered.length,
          page: bundlesPage.page,
          pageSize: bundlesPage.pageSize,
          totalPages: (filtered.length / bundlesPage.pageSize).ceil(),
          hasNextPage: bundlesPage.hasNextPage,
          hasPreviousPage: bundlesPage.hasPreviousPage,
        );
      }
      
      return bundlesPage;
    } on DioException catch (e) {
      _logError(label, e);
      rethrow;
    }
  }

  // ───────────────────────── helpers ─────────────────────────

  void _logRequest(String label, String fullUrl) {
    debugPrint('>>> [$label] REQUEST\n$fullUrl\n');
  }

  void _logResponse(String label, Response r) {
    debugPrint('⬇️  [$label] RESPONSE - Status: ${r.statusCode}');
  }

  void _logError(String label, DioException e) {
    debugPrint('❌ [$label] ERROR - Status: ${e.response?.statusCode}, Message: ${e.message}');
    }
  }
