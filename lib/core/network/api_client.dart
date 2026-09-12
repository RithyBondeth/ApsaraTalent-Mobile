import 'package:apsaratalent_mobile/core/configs/config_service.dart';
import 'package:apsaratalent_mobile/core/constants/app_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/api_interceptors.dart';
import 'package:apsaratalent_mobile/core/session/session_store.dart';
import 'package:apsaratalent_mobile/core/session/token_refresher.dart';
import 'package:dio/dio.dart';

/// The app's HTTP client. Obtain it from `apiClientProvider`.
///
/// It used to be a process-wide singleton holding a token that nothing ever
/// set. It is now constructed with the [SessionStore] it reads tokens from, so
/// every request carries the current session and tests can build one against a
/// fake adapter.
class ApiClient {
  ApiClient({
    required SessionStore sessionStore,
    String? baseUrl,
    HttpClientAdapter? adapter,
  }) {
    final options = BaseOptions(
      baseUrl: normalizeBaseUrl(baseUrl ?? AppConfigService.apiBaseUrl),
      connectTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);
    // The refresh call goes through its own Dio with no session interceptor,
    // so a refused refresh cannot trigger another refresh.
    final refreshDio = Dio(options);
    if (adapter != null) {
      _dio.httpClientAdapter = adapter;
      refreshDio.httpClientAdapter = adapter;
    }

    _dio.interceptors.add(
      SessionInterceptor(
        store: sessionStore,
        refresher: TokenRefresher(dio: refreshDio, store: sessionStore),
        dio: _dio,
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;

  /// Strips a trailing slash. Every path constant starts with `/`, so a base
  /// URL ending in one produced `https://host//auth/login` — which the API
  /// answers with a 404.
  static String normalizeBaseUrl(String url) {
    var normalized = url.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _send(() => _dio.get<dynamic>(
            path,
            queryParameters: queryParameters,
            options: options,
          ));

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _send(() => _dio.post<dynamic>(path, data: data, options: options));

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _send(() => _dio.put<dynamic>(path, data: data, options: options));

  Future<Response<dynamic>> delete(String path, {Options? options}) =>
      _send(() => _dio.delete<dynamic>(path, options: options));

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.badResponse:
        return _handleBadResponse(e);
      default:
        return ApiException(message: e.message ?? 'Unknown error');
    }
  }

  ApiException _handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = messageFrom(e.response?.data) ?? 'Server error';

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message);
      case 404:
        return ApiException(
          message: 'Resource not found',
          statusCode: statusCode,
        );
      case 429:
        // The throttler's own text is "ThrottlerException: Too Many
        // Requests", which is not something to show a person.
        return ApiException(
          message: 'Too many attempts. Please wait a minute and try again.',
          statusCode: statusCode,
        );
      default:
        return ApiException(message: message, statusCode: statusCode);
    }
  }

  /// The human-readable message from an API error body.
  ///
  /// NestJS's validation pipe answers 400 with `message` as a **list** of
  /// strings, one per failed constraint. Passing that straight into a `String`
  /// field was a runtime type error, so a single malformed request crashed the
  /// screen instead of showing an error.
  static String? messageFrom(dynamic data) {
    if (data is! Map) return null;
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) {
      return message.map((m) => '$m').join('\n');
    }
    return null;
  }
}
