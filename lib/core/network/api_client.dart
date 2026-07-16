import 'package:apsaratalent_mobile/core/configs/config_service.dart';
import 'package:apsaratalent_mobile/core/constants/app_constant.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/network/api_interceptors.dart';
import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;
  String? _token;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfigService.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(getToken: () => _token),
      if (AppConfigService.debugMode) LoggingInterceptor(),
    ]);
  }

  void setToken(String? token) => _token = token;

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
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
    final message = e.response?.data?['message'] ?? 'Server error';

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message);
      case 404:
        return ApiException(
            message: 'Resource not found', statusCode: statusCode);
      default:
        return ApiException(message: message, statusCode: statusCode);
    }
  }
}
