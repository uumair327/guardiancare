/// Base class for all exceptions in the application
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// Network-related exceptions
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException(super.message, {super.code, this.statusCode});

  @override
  String toString() =>
      'NetworkException: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}

/// Rate limit exceptions
class RateLimitException extends AppException {
  final Duration? retryAfter;

  const RateLimitException(super.message, {super.code, this.retryAfter});
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code});
}
