class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  AppException({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({String? message})
      : super(message: message ?? 'Network error. Please check your connection.', code: 'NETWORK_ERROR');
}

class ServerException extends AppException {
  ServerException({String? message, int? statusCode})
      : super(message: message ?? 'Server error. Please try again.', code: 'SERVER_ERROR', statusCode: statusCode);
}

class CacheException extends AppException {
  CacheException({String? message})
      : super(message: message ?? 'Cache error.', code: 'CACHE_ERROR');
}

class NotFoundException extends AppException {
  NotFoundException({String? message})
      : super(message: message ?? 'Resource not found.', code: 'NOT_FOUND');
}

class TimeoutException extends AppException {
  TimeoutException({String? message})
      : super(message: message ?? 'Request timed out. Please try again.', code: 'TIMEOUT');
}