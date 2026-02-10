// lib/presentation/features/home/data/home_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/core/storage/auth_storage.dart'; // ← added
import 'models.dart';

class HomeRepository {
  HomeRepository({Dio? client}) : _dio = client ?? AppDio().dio;
  final Dio _dio;

  // Build Authorization header from saved user (SharedPreferences)
  Future<Map<String, String>> _authHeaders() async {
    try {
      final user = await AuthStorage().readUser();
      final token = user?.accessToken?.trim();
      if (token == null || token.isEmpty) {
        return const {'Accept': 'application/json'};
      }
      return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
    } catch (_) {
      return const {'Accept': 'application/json'};
    }
  }

  Future<List<BundleCategory>> fetchCategories() async {
    try {
      final r = await _dio.get(
        'BundleCategory/GetAll',
        options: Options(headers: await _authHeaders()), // ← token here
      );
      _logResponse(r, tag: 'fetchCategories');
      final data = r.data is Map ? r.data : {};
      final list = (data['result'] as List?) ?? const [];
      return list
          .map((e) => BundleCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _logError(e, tag: 'fetchCategories');
      rethrow;
    }
  }

  Future<List<BundleSubCategory>> fetchSubCategories(int categoryId) async {
    try {
      final r = await _dio.get(
        'BundleSubCategory/GetByCategoryId',
        queryParameters: {'categoryId': categoryId},
        options: Options(headers: await _authHeaders()), // ← token here
      );
      _logResponse(r, tag: 'fetchSubCategories');
      final data = r.data is Map ? r.data : {};
      final list = (data['result'] as List?) ?? const [];
      return list
          .map((e) => BundleSubCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _logError(e, tag: 'fetchSubCategories');
      rethrow;
    }
  }

  Future<List<Bundle>> fetchBundles({int page = 1, int pageSize = 5000}) async {
    if (kDebugMode) {
      debugPrint(' Fetching bundles: page=$page, pageSize=$pageSize ');
    }
    try {
      final r = await _dio.get(
        'Bundles',
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: Options(headers: await _authHeaders()),
      );

      if (kDebugMode) {
        debugPrint(' Bundles fetched successfully: ${r.data} ');
      }

      _logResponse(r, tag: 'fetchBundles');
      final data = r.data is Map ? r.data : {};
      final list = (data['result']?['bundles'] as List?) ?? const [];
      return list
          .map((e) => Bundle.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _logError(e, tag: 'fetchBundles');
      rethrow;
    }
  }

  /* ------------------------------- logging ------------------------------- */

  void _logResponse(Response r, {String tag = ''}) {
    if (!kDebugMode) return;
    final pretty = _pretty(r.data);
    final hdrs = _pretty(r.headers.map);
    debugPrint('''
🔵 $tag RESPONSE
${r.requestOptions.method} ${r.requestOptions.uri}
Status: ${r.statusCode}
Headers: $hdrs
Body: $pretty
''');
  }

  void _logError(DioException e, {String tag = ''}) {
    if (!kDebugMode) return;
    final ro = e.requestOptions;
    final resp = e.response;
    debugPrint('''
🔴 $tag ERROR
${ro.method} ${ro.uri}
Type: ${e.type}
Message: ${e.message}
Resp.Status: ${resp?.statusCode}
Resp.Body: ${_pretty(resp?.data)}
''');
  }

  String _pretty(dynamic data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data?.toString() ?? 'null';
    }
  }
}
