import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
class AuthStateEvent extends Equatable {
  /// The type of authentication event
  final AuthStateEventType type;

  /// The user associated with this event (null for logout/sessionExpired)
  final User? user;

  /// Timestamp when the event occurred
  final DateTime timestamp;

  /// Creates an AuthStateEvent
  const AuthStateEvent({
    required this.type,
    this.user,
    required this.timestamp,
  });

  /// Factory constructor for login events
  factory AuthStateEvent.login(User user) {
    return AuthStateEvent(
      type: AuthStateEventType.login,
      user: user,
      timestamp: DateTime.now(),
    );
  }

  /// Factory constructor for logout events
  factory AuthStateEvent.logout() {
    return AuthStateEvent(
      type: AuthStateEventType.logout,
      user: null,
      timestamp: DateTime.now(),
    );
  }

  /// Factory constructor for session expired events
  factory AuthStateEvent.sessionExpired() {
    return AuthStateEvent(
      type: AuthStateEventType.sessionExpired,
      user: null,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [type, user?.uid, timestamp];

  @override
  String toString() =>
      'AuthStateEvent(type: $type, user: ${user?.uid}, timestamp: $timestamp)';
}
