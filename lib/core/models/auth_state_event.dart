// ignore_for_file: deprecated_member_use_from_same_package
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/core/backend/backend.dart';

/// Enum representing the type of authentication state event
enum AuthStateEventType {
  /// User has logged in
  login,

  /// User has logged out
  logout,

  /// User session has expired
  sessionExpired,
}

/// Model representing an authentication state change event
/// Used by AuthStateManager to notify dependent services about auth changes
///
/// This model supports both Firebase User (legacy) and BackendUser (new abstraction)
/// for backward compatibility during migration.
class AuthStateEvent extends Equatable {
  /// Creates an AuthStateEvent
  const AuthStateEvent({
    required this.type,
    this.user,
    this.backendUser,
    required this.timestamp,
  });

  /// Factory constructor for login events (legacy - Firebase User)
  @Deprecated('Use loginFromBackendUser instead')
  factory AuthStateEvent.login(User user) {
    return AuthStateEvent(
      type: AuthStateEventType.login,
      user: user,
      backendUser: BackendUser(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        emailVerified: user.emailVerified,
        isAnonymous: user.isAnonymous,
      ),
      timestamp: DateTime.now(),
    );
  }

  /// Factory constructor for login events using BackendUser
  factory AuthStateEvent.loginFromBackendUser(BackendUser backendUser) {
    return AuthStateEvent(
      type: AuthStateEventType.login,
      backendUser: backendUser,
      timestamp: DateTime.now(),
    );
  }

  /// Factory constructor for logout events
  factory AuthStateEvent.logout() {
    return AuthStateEvent(
      type: AuthStateEventType.logout,
      timestamp: DateTime.now(),
    );
  }

  /// Factory constructor for session expired events
  factory AuthStateEvent.sessionExpired() {
    return AuthStateEvent(
      type: AuthStateEventType.sessionExpired,
      timestamp: DateTime.now(),
    );
  }

  /// The type of authentication event
  final AuthStateEventType type;

  /// The Firebase user associated with this event (legacy - will be deprecated)
  @Deprecated(
      'Use backendUser instead. This will be removed in future versions.')
  final User? user;

  /// The backend-agnostic user associated with this event
  final BackendUser? backendUser;

  /// Timestamp when the event occurred
  final DateTime timestamp;

  /// Get the user ID (works with both legacy and new user types)
  String? get userId => backendUser?.id ?? user?.uid;

  /// Get the user email (works with both legacy and new user types)
  String? get email => backendUser?.email ?? user?.email;

  /// Get the display name (works with both legacy and new user types)
  String? get displayName => backendUser?.displayName ?? user?.displayName;

  @override
  List<Object?> get props => [type, userId, timestamp];

  @override
  String toString() =>
      'AuthStateEvent(type: $type, userId: $userId, timestamp: $timestamp)';
}
