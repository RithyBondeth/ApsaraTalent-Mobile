class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'No internet connection'});
}

class TimeoutException extends ApiException {
  TimeoutException({super.message = 'Request timed out'});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Unauthorized'});
}
