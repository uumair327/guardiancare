import 'package:flutter_test/flutter_test.dart';

// Import all quiz test files
import 'services/quiz_state_manager_test.dart' as quiz_state_manager_tests;
import 'services/quiz_validation_service_test.dart' as quiz_validation_service_tests;
import 'quiz_navigation_integration_test.dart' as quiz_navigation_integration_tests;
import 'quiz_score_calculation_test.dart' as quiz_score_calculation_tests;

/// Comprehensive test suite for all quiz-related functionality
/// 
/// This test suite covers:
/// - QuizStateManager unit tests
/// - QuizValidationService unit tests  
/// - Quiz navigation integration tests
/// - Quiz score calculation tests (first answer only)
/// 
/// Run with: flutter test test/src/features/quiz/quiz_test_suite.dart
void main() {
  group('Quiz Test Suite', () {
    group('QuizStateManager Tests', quiz_state_manager_tests.main);
    group('QuizValidationService Tests', quiz_validation_service_tests.main);
    group('Quiz Navigation Integration Tests', quiz_navigation_integration_tests.main);
    group('Quiz Score Calculation Tests', quiz_score_calculation_tests.main);
  });
}