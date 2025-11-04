# Parental Control Security Tests

This directory contains comprehensive security tests for the parental control system, specifically focusing on the attempt limiting and lockout mechanisms designed to prevent brute force attacks.

## Test Structure

### Unit Tests

#### `services/attempt_limiting_service_test.dart`
Tests the core attempt limiting functionality:
- Basic attempt tracking and counting
- Lockout mechanism after max attempts (3)
- Lockout duration enforcement (5 minutes)
- Multi-user independent tracking
- Manual reset capabilities
- Edge cases and error scenarios

#### `controllers/consent_controller_security_test.dart`
Tests the ConsentController security integration:
- Parental key verification with attempt limiting
- Security question verification
- Hash security and consistency
- Brute force attack prevention
- Error handling without information leakage
- Concurrent access safety

### Integration Tests

#### `parental_control_security_integration_test.dart`
Tests complete security flows:
- End-to-end brute force attack scenarios
- Progressive security warning system
- Recovery scenarios (successful verification, admin reset)
- Multi-user concurrent scenarios
- Security metrics and monitoring
- Edge cases and extreme scenarios

## Key Security Test Scenarios

### Brute Force Attack Prevention
- ✅ Prevents unlimited password attempts
- ✅ Locks out users after 3 failed attempts
- ✅ Enforces 5-minute lockout duration
- ✅ Maintains lockout across multiple verification attempts
- ✅ Tracks attempts independently per user

### Progressive Warning System
- ✅ Normal state: "Enter your parental key to continue"
- ✅ Warning state: "Incorrect key. X attempts remaining before lockout"
- ✅ Locked state: "Too many failed attempts. Try again in X:XX"
- ✅ Real-time countdown during lockout period

### Recovery Mechanisms
- ✅ Successful verification resets attempt counter immediately
- ✅ Administrative reset unlocks users instantly
- ✅ Lockout expires automatically after timeout
- ✅ Recovery works from any security state

### Security Integrity
- ✅ Hash consistency for parental keys and security answers
- ✅ Case-insensitive security answer handling
- ✅ No sensitive information leakage in error messages
- ✅ Concurrent access safety
- ✅ Memory management and cleanup

## Running Tests

### Run All Security Tests
```bash
flutter test test/src/features/consent/consent_security_test_suite.dart
```

### Run Individual Test Files
```bash
# Attempt limiting service tests
flutter test test/src/features/consent/services/attempt_limiting_service_test.dart

# Consent controller security tests
flutter test test/src/features/consent/controllers/consent_controller_security_test.dart

# Security integration tests
flutter test test/src/features/consent/parental_control_security_integration_test.dart
```

### Run with Coverage
```bash
flutter test --coverage test/src/features/consent/
```

## Test Coverage

The test suite provides comprehensive coverage of:

- **Attempt Tracking**: 100% coverage of attempt counting and state management
- **Lockout Mechanism**: Complete lockout flow validation
- **Security States**: All security states (normal, warning, locked) tested
- **Multi-User Support**: Independent user tracking verification
- **Recovery Scenarios**: All recovery paths tested
- **Edge Cases**: Boundary conditions and error scenarios covered
- **Integration Flows**: End-to-end security scenarios validated

## Security Requirements Verification

These tests verify all security-related acceptance criteria:

### Requirement 2.1 ✅
- WHEN a user enters an incorrect parental key, THE Parental_Control_System SHALL increment the failed attempt counter

### Requirement 2.2 ✅
- WHEN the failed attempt counter reaches 3 attempts, THE Parental_Control_System SHALL lock the user out for 5 minutes

### Requirement 2.3 ✅
- WHILE the lockout period is active, THE Parental_Control_System SHALL prevent any parental key verification attempts

### Requirement 2.4 ✅
- WHEN the lockout period expires, THE Parental_Control_System SHALL reset the attempt counter

### Requirement 2.5 ✅
- WHEN a correct parental key is entered, THE Parental_Control_System SHALL reset the attempt counter immediately

## Security Test Categories

### Attack Simulation Tests
- Brute force attack scenarios with common passwords
- Rapid successive attempt scenarios
- Concurrent attack attempts from same user
- Mixed legitimate user and attacker scenarios

### State Transition Tests
- Normal → Warning → Locked state progression
- Recovery from each security state
- Administrative intervention scenarios
- System restart and persistence scenarios

### Boundary Condition Tests
- Exactly 3 attempts triggering lockout
- Lockout duration boundaries (5 minutes)
- Maximum attempt count handling
- Empty and invalid user ID handling

### Performance and Reliability Tests
- Concurrent user access scenarios
- Memory management with many users
- Extreme attempt count scenarios
- Service cleanup and reset scenarios

## Continuous Integration

These security tests should be run as part of the CI/CD pipeline to ensure:
- No security regressions in parental control functionality
- Brute force protection remains effective
- Lockout mechanisms function correctly
- User experience remains consistent during security events

## Security Monitoring

The tests also validate security monitoring capabilities:
- Comprehensive security statistics tracking
- Real-time lockout status reporting
- Security event logging and audit trails
- Performance metrics for security operations