import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/core/services/parental_session_manager.dart';
import 'package:guardiancare/core/services/parental_key_verifier.dart';

/// Service to manage parental verification state for the current session
/// Orchestrates ParentalSessionManager, ParentalKeyVerifier, and CryptoService
/// without containing implementation details
/// Requirements: 9.1, 9.2, 9.3, 9.4
class ParentalVerificationService {
  final ParentalSessionManager _sessionManager;
  final ParentalKeyVerifier _keyVerifier;
  final FirebaseAuth _auth;

  // Singleton pattern for backward compatibility
  static ParentalVerificationService? _instance;

  /// Factory constructor for singleton access (backward compatibility)
  factory ParentalVerificationService() {
    if (_instance == null) {
      throw StateError(
        'ParentalVerificationService not initialized. '
        'Call ParentalVerificationService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize the singleton instance with dependencies
  static void initialize({
    required ParentalSessionManager sessionManager,
    required ParentalKeyVerifier keyVerifier,
    FirebaseAuth? auth,
  }) {
    _instance = ParentalVerificationService._internal(
      sessionManager: sessionManager,
      keyVerifier: keyVerifier,
      auth: auth ?? FirebaseAuth.instance,
    );
  }

  /// Internal constructor
  ParentalVerificationService._internal({
    required ParentalSessionManager sessionManager,
    required ParentalKeyVerifier keyVerifier,
    required FirebaseAuth auth,
  })  : _sessionManager = sessionManager,
        _keyVerifier = keyVerifier,
        _auth = auth;

  /// Named constructor for direct instantiation (for testing and DI)
  ParentalVerificationService.withDependencies({
    required ParentalSessionManager sessionManager,
    required ParentalKeyVerifier keyVerifier,
    FirebaseAuth? auth,
  })  : _sessionManager = sessionManager,
        _keyVerifier = keyVerifier,
        _auth = auth ?? FirebaseAuth.instance;

  /// Check if parental key has been verified in this session
  /// Delegates to ParentalSessionManager
  bool get isVerifiedForSession => _sessionManager.isVerified;

  /// Verify parental key against Firestore
  /// Delegates to ParentalKeyVerifier for verification logic
  Future<bool> verifyParentalKey(String enteredKey) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final result = await _keyVerifier.verify(user.uid, enteredKey);

    return result.fold(
      (failure) => false,
      (isValid) {
        if (isValid) {
          // Delegate session state management to ParentalSessionManager
          _sessionManager.setVerified(true);
        }
        return isValid;
      },
    );
  }

  /// Reset verification state (called when app closes or user logs out)
  /// Delegates to ParentalSessionManager
  void resetVerification() {
    _sessionManager.reset();
  }
}
