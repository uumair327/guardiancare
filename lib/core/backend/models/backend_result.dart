/// Generic result wrapper for backend operations.
///
/// This class provides a type-safe way to handle both success and failure
/// cases from backend operations without throwing exceptions.
///
/// ## Usage
/// ```dart
/// Future<BackendResult<User>> getUser(String id) async {
///   try {
///     final user = await dataStore.get('users', id);
///     return BackendResult.success(user);
///   } on Object catch (e) {
///     return BackendResult.failure(BackendError.fromException(e));
///   }
/// }
///
/// // Consuming the result
/// final result = await getUser('123');
/// result.when(
///   success: (user) => print('Got user: ${user.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
sealed class BackendResult<T> {
  const BackendResult._();

  /// Create a success result
  const factory BackendResult.success(T data) = BackendSuccess<T>;

  /// Create a failure result
  const factory BackendResult.failure(BackendError error) = BackendFailure<T>;

  /// Returns true if this is a success result
  bool get isSuccess => this is BackendSuccess<T>;

  /// Returns true if this is a failure result
  bool get isFailure => this is BackendFailure<T>;

  /// Get the data if success, or null if failure
  T? get dataOrNull => switch (this) {
        BackendSuccess<T>(:final data) => data,
        BackendFailure<T>() => null,
      };

  /// Get the error if failure, or null if success
  BackendError? get errorOrNull => switch (this) {
        BackendSuccess<T>() => null,
        BackendFailure<T>(:final error) => error,
      };

  /// Pattern match on the result
  R when<R>({
    required R Function(T data) success,
    required R Function(BackendError error) failure,
  }) {
    return switch (this) {
      BackendSuccess<T>(:final data) => success(data),
      BackendFailure<T>(:final error) => failure(error),
    };
  }

  /// Map the success value
  BackendResult<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      BackendSuccess<T>(:final data) => BackendResult.success(mapper(data)),
      BackendFailure<T>(:final error) => BackendResult.failure(error),
    };
  }

  /// FlatMap the success value
  Future<BackendResult<R>> flatMap<R>(
    Future<BackendResult<R>> Function(T data) mapper,
  ) async {
    return switch (this) {
      BackendSuccess<T>(:final data) => await mapper(data),
      BackendFailure<T>(:final error) => BackendResult.failure(error),
    };
  }

  /// Get data or throw
  T getOrThrow() {
    return switch (this) {
      BackendSuccess<T>(:final data) => data,
      BackendFailure<T>(:final error) => throw error.toException(),
    };
  }

  /// Get data or default
  T getOrElse(T defaultValue) {
    return switch (this) {
      BackendSuccess<T>(:final data) => data,
      BackendFailure<T>() => defaultValue,
    };
  }
}

/// Success result
final class BackendSuccess<T> extends BackendResult<T> {
  const BackendSuccess(this.data) : super._();

  final T data;
}

/// Failure result
final class BackendFailure<T> extends BackendResult<T> {
  const BackendFailure(this.error) : super._();

  final BackendError error;
}

/// Backend error with code and message
class BackendError {
  const BackendError({
    required this.code,
    required this.message,
    this.details,
    this.stackTrace,
  });

  /// Create from exception
  factory BackendError.fromException(Object e, [StackTrace? stackTrace]) {
    if (e is BackendError) return e;

    // Map common exception types
    final code = switch (e.runtimeType.toString()) {
      'FirebaseAuthException' => BackendErrorCode.authError,
      'FirebaseException' => BackendErrorCode.serverError,
      'SocketException' => BackendErrorCode.networkError,
      'TimeoutException' => BackendErrorCode.timeout,
      _ => BackendErrorCode.unknown,
    };

    return BackendError(
      code: code,
      message: e.toString(),
      stackTrace: stackTrace,
    );
  }

  /// Error code for programmatic handling
  final BackendErrorCode code;

  /// Human-readable error message
  final String message;

  /// Optional additional details
  final Map<String, dynamic>? details;

  /// Stack trace for debugging
  final StackTrace? stackTrace;

  /// Convert to exception for throwing
  Exception toException() {
    return BackendException(code: code, message: message);
  }

  @override
  String toString() => 'BackendError($code): $message';
}

/// Backend error codes
enum BackendErrorCode {
  // Auth errors
  authError,
  invalidCredentials,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  tokenExpired,

  // Data errors
  notFound,
  alreadyExists,
  invalidData,
  permissionDenied,

  // Network errors
  networkError,
  timeout,
  serverError,
  serviceUnavailable,

  // Storage errors
  storageFull,
  fileTooLarge,
  invalidFileType,

  // Rate limiting
  rateLimited,

  // Operation errors
  operationNotAllowed,
  invalidEmail,
  unauthorized,

  // Unknown
  unknown,
}

/// Exception class for backend errors
class BackendException implements Exception {
  const BackendException({required this.code, required this.message});

  final BackendErrorCode code;
  final String message;

  @override
  String toString() => 'BackendException($code): $message';
}
