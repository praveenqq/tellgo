import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../storage/token_storage.dart';

const String _webProxy = String.fromEnvironment(
  'WEB_API_PROXY',
  defaultValue: '',
);

class AppDio {
  AppDio._();
  static final AppDio _i = AppDio._();
  factory AppDio() => _i;

  late final Dio dio = _create();

  Dio _create() {
    final base =
        kIsWeb && _webProxy.isNotEmpty
            ? _webProxy
            : 'https://appapi.tellgo.org/';
    final d = Dio(
      BaseOptions(
        baseUrl: base,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: const {'accept': '*/*'},
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );

    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          // DEFAULT = no auth. Only add when explicitly requested.
          if ((o.extra['auth'] as bool?) == true) {
            final t = await TokenStorage.I.getAccess();
            if (t != null && t.isNotEmpty) {
              o.headers['Authorization'] = 'Bearer $t';
            }
          }
          h.next(o);
        },
        onResponse: (r, h) => h.next(r),
        onError: (e, h) {
          final ro = e.requestOptions;
          // ignore: avoid_print
          print('❌ DioError: ${e.type} ${e.message}  @ ${ro.method} ${ro.uri}');
          if (e.response != null) {
            // ignore: avoid_print
            print(
              '   ↳ status: ${e.response!.statusCode}, data: ${e.response!.data}',
            );
          }
          h.next(e);
        },
      ),
    );
    return d;
  }

  // ---------- Convenience wrappers (default auth=false) ----------
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool auth = false,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: _mergeOptions(options, auth: auth),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool auth = false,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _mergeOptions(options, auth: auth),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool auth = false,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _mergeOptions(options, auth: auth),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool auth = false,
    CancelToken? cancelToken,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _mergeOptions(options, auth: auth),
      cancelToken: cancelToken,
    );
  }

  Options _mergeOptions(Options? options, {bool auth = false}) {
    final o = options ?? Options();
    final extra = Map<String, dynamic>.from(o.extra ?? const {});
    if (auth) extra['auth'] = true; // default remains false
    return o.copyWith(extra: extra);
  }
}
