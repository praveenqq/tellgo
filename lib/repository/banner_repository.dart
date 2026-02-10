import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:tellgo_app/core/network/app_dio.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class BannerItem {
  final String bannerName;
  final String bannerUrl;
  final String source;
  final bool isActive;
  final int sequence;
  final int posUserId;
  final int timer;
  final bool isDefault;

  const BannerItem({
    required this.bannerName,
    required this.bannerUrl,
    required this.source,
    required this.isActive,
    required this.sequence,
    required this.posUserId,
    required this.timer,
    required this.isDefault,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      bannerName: json['bannerName']?.toString() ?? '',
      bannerUrl: json['bannerUrl']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      isActive: json['isActive'] == true,
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      posUserId: (json['posuserId'] as num?)?.toInt() ?? 0,
      timer: (json['timmer'] as num?)?.toInt() ?? 0, // API typo: "timmer"
      isDefault: json['isDefault'] == true,
    );
  }
}

// ─── Repository ──────────────────────────────────────────────────────────────

abstract class BannerRepository {
  Future<List<BannerItem>> getBanners();
}

class BannerRepositoryImpl implements BannerRepository {
  final AppDio _appDio;

  BannerRepositoryImpl([AppDio? appDio]) : _appDio = appDio ?? AppDio();

  @override
  Future<List<BannerItem>> getBanners() async {
    try {
      if (kDebugMode) {
        debugPrint('📤 GET Banners/GetBanners');
      }

      final response = await _appDio.get(
        'Banners/GetBanners',
        auth: true,
      );

      if (kDebugMode) {
        debugPrint('✅ GET ${response.requestOptions.uri}');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      final resultData = response.data as Map<String, dynamic>;
      final result = resultData['result'];

      if (result == null) return [];

      List<dynamic> bannersList;
      if (result is String) {
        try {
          final parsed = jsonDecode(result);
          bannersList = parsed is List ? parsed : [];
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error parsing banners JSON string: $e');
          }
          return [];
        }
      } else if (result is List) {
        bannersList = result;
      } else {
        return [];
      }

      final banners = bannersList
          .map((json) => BannerItem.fromJson(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ))
          .where((b) => b.isActive) // Only active banners
          .toList();

      // Sort by sequence
      banners.sort((a, b) => a.sequence.compareTo(b.sequence));

      return banners;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioError fetching banners: ${e.type} ${e.message}');
        debugPrint('   @ ${e.requestOptions.method} ${e.requestOptions.uri}');
        debugPrint(
            '   ↳ status: ${e.response?.statusCode}, data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching banners: $e');
      }
      rethrow;
    }
  }
}

