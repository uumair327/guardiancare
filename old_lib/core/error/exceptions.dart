/// Base class for all exceptions in the application
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server-related exceptions
class ServerException extends AppException {
  ServerException(super.message, {super.code});
}

/// Cache-related exceptions
class CacheException extends AppException {
  CacheException(super.message, {super.code});
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

/// Authentication-related exceptions
class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

/// Validation-related exceptions
class ValidationException extends AppException {
  ValidationException(super.message, {super.code});
}

/// Permission-related exceptions
class PermissionException extends AppException {
  PermissionException(super.message, {super.code});
}

/// Not found exceptions
class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code});
}
