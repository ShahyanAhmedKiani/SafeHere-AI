import 'package:dio/dio.dart';

import '../core/constants.dart';
import 'secure_storage_service.dart';

/// Single Dio instance shared across services. Attaches the bearer token to
/// every request and transparently refreshes it once on a 401 before retrying.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isAuthRoute(error.requestOptions.path)) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final clone = await _retry(error.requestOptions);
            return handler.resolve(clone);
          }
        }
        handler.next(error);
      },
    ));
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  bool _isAuthRoute(String path) => path.contains('/api/auth/login') || path.contains('/api/auth/register');

  Future<bool> _tryRefresh() async {
    final refresh = await SecureStorageService.refreshToken;
    if (refresh == null) return false;
    try {
      final response = await Dio(BaseOptions(baseUrl: ApiConfig.baseUrl))
          .post('/api/auth/refresh', data: {'refresh_token': refresh});
      await SecureStorageService.saveTokens(
        access: response.data['access_token'],
        refresh: response.data['refresh_token'],
      );
      return true;
    } catch (_) {
      await SecureStorageService.clear();
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await SecureStorageService.accessToken;
    final options = Options(method: requestOptions.method, headers: {
      ...requestOptions.headers,
      'Authorization': 'Bearer $token',
    });
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

/// Turns Dio's error payloads into a readable message for the UI layer.
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) return first['msg'].toString();
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Could not reach the server. Check your connection and try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}
