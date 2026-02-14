import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {

  const Failure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

/// Gemini API-related failures
class GeminiApiFailure extends Failure {
  const GeminiApiFailure(super.message, {super.code});
}

/// YouTube API-related failures
class YoutubeApiFailure extends Failure {
  const YoutubeApiFailure(super.message, {super.code});
}

/// Storage-related failures (SharedPreferences, Hive, SQLite)
class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code});
}

/// Authentication-related failures (more specific than AuthFailure)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code});
}
