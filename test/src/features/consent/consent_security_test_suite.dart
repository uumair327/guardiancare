import 'package:flutter_test/flutter_test.dart';

// Import all consent security test files
import 'services/attempt_limiting_service_test.dart' as attempt_limiting_service_tests;
import 'controllers/consent_controller_security_test.dart' as consent_controller_security_tests;
import 'parental_control_security_integration_test.dart' as security_integration_tests;

/// Comprehensive test suite for parental control security functionality
/// 
/// This test suite covers:
/// - AttemptLimitingService unit tests
/// - ConsentController security tests
/// - Parental control security integration tests
/// - Brute force attack prevention
/// - Lockout mechanism validation
/// - Security event tracking
/// 
/// Run with: flutter test test/src/features/consent/consent_security_test_suite.dart
void main() {
  group('Consent Security Test Suite', () {
    group('AttemptLimitingService Tests', attempt_limiting_service_tests.main);
    group('ConsentController Security Tests', consent_controller_security_tests.main);
    group('Security Integration Tests', security_integration_tests.main);
  });
}