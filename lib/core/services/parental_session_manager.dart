/// Abstract interface for parental session state management
/// Handles session state management exclusively
/// Requirements: 9.1
abstract class ParentalSessionManager {
  /// Check if parental key has been verified in this session
  bool get isVerified;

  /// Set the verification state
  void setVerified(bool value);

  /// Reset verification state (called when app closes or user logs out)
  void reset();
}

/// Implementation of ParentalSessionManager
/// Manages session-based verification state that resets when app closes
class ParentalSessionManagerImpl implements ParentalSessionManager {
  factory ParentalSessionManagerImpl() => _instance;
  ParentalSessionManagerImpl._internal();
  // Singleton pattern for session state persistence within app lifecycle
  static final ParentalSessionManagerImpl _instance =
      ParentalSessionManagerImpl._internal();

  // Session state - resets when app closes
  bool _isVerified = false;

  @override
  bool get isVerified => _isVerified;

  @override
  void setVerified(bool value) {
    _isVerified = value;
  }

  @override
  void reset() {
    _isVerified = false;
  }
}
