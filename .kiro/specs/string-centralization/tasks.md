w# Implementation Plan: String Centralization

## Overview

This implementation plan outlines the tasks for centralizing all hardcoded strings in the GuardianCare Flutter application following Clean Architecture and SOLID principles. The approach creates new string constant files, updates the barrel file, and migrates hardcoded strings feature by feature.

## Tasks

- [x] 1. Create core string constant files
  - [x] 1.1 Create `error_strings.dart` with categorized error messages
    - Create file at `lib/core/constants/error_strings.dart`
    - Add generic, network, cache, server, and authentication error constants
    - Include template methods for dynamic error messages
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 1.2 Create `validation_strings.dart` with input validation messages
    - Create file at `lib/core/constants/validation_strings.dart`
    - Add email, password, required field, and format validation messages
    - Include template methods for min/max length validation
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 1.3 Create `ui_strings.dart` with common UI text constants
    - Create file at `lib/core/constants/ui_strings.dart`
    - Add button labels (OK, Cancel, Save, Sign In, etc.)
    - Add common titles, labels, and time-based greetings
    - Add content state messages (loading, empty, unavailable)
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [x] 1.4 Create `feedback_strings.dart` with SnackBar/toast messages
    - Create file at `lib/core/constants/feedback_strings.dart`
    - Add success, error, warning, and info feedback messages
    - Include template methods for dynamic feedback
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [x] 1.5 Create `firebase_strings.dart` with Firebase constants
    - Create file at `lib/core/constants/firebase_strings.dart`
    - Add collection name constants
    - Add common document field name constants
    - _Requirements: 7.1, 7.2_

  - [x] 1.6 Create `api_strings.dart` with API-related constants
    - Create file at `lib/core/constants/api_strings.dart`
    - Add API base URLs and endpoints
    - Add query parameters and header constants
    - _Requirements: 7.3_

- [x] 2. Update barrel file and extend existing strings
  - [x] 2.1 Update `constants.dart` barrel file to export all new string classes
    - Add exports for error_strings.dart, validation_strings.dart, ui_strings.dart
    - Add exports for feedback_strings.dart, firebase_strings.dart, api_strings.dart
    - _Requirements: 8.2_

  - [x] 2.2 Extend `app_strings.dart` with additional core constants
    - Review and add any missing core application strings
    - Ensure backward compatibility with existing usage
    - _Requirements: 1.2, 1.3_

- [x] 3. Checkpoint - Verify core string files
  - Ensure all new string files compile without errors
  - Run `flutter analyze` to check for issues
  - Ask the user if questions arise

- [ ]* 4. Write unit tests for string constants
  - [ ]* 4.1 Create test file for string constant verification
    - Create `test/core/constants/string_constants_test.dart`
    - Test that all string classes have expected constants
    - Test barrel file exports all classes correctly
    - _Requirements: 8.2_

  - [ ]* 4.2 Write property test for string value preservation
    - **Property 1: String Value Preservation**
    - **Validates: Requirements 8.3**

- [x] 5. Migrate authentication feature strings
  - [x] 5.1 Migrate `email_verification_page.dart` hardcoded strings
    - Replace SnackBar messages with FeedbackStrings constants
    - Replace error messages with ErrorStrings constants
    - _Requirements: 6.2, 6.3, 8.1, 8.3_

  - [x] 5.2 Migrate `signup_page.dart` hardcoded strings
    - Replace role labels with UIStrings constants
    - _Requirements: 4.2, 8.1, 8.3_

  - [x] 5.3 Migrate `terms_and_conditions_dialog.dart` hardcoded strings
    - Replace button labels with UIStrings constants
    - _Requirements: 4.2, 8.1, 8.3_

- [x] 6. Migrate consent feature strings
  - [x] 6.1 Migrate `enhanced_consent_form_page.dart` hardcoded strings
    - Replace form labels with UIStrings constants
    - Replace SnackBar messages with FeedbackStrings constants
    - _Requirements: 4.2, 6.2, 6.3, 8.1, 8.3_

  - [x] 6.2 Migrate `forgot_parental_key_dialog.dart` hardcoded strings
    - Replace dialog text with UIStrings constants
    - Replace feedback messages with FeedbackStrings constants
    - _Requirements: 4.3, 6.2, 6.3, 8.1, 8.3_

- [x] 7. Migrate forum feature strings
  - [x] 7.1 Create forum feature-specific strings file
    - Create `lib/features/forum/presentation/constants/strings.dart`
    - Add ForumStrings class with feature-specific constants
    - _Requirements: 5.1, 5.2, 5.3_

  - [x] 7.2 Migrate `forum_page.dart` hardcoded strings
    - Replace dialog titles with ForumStrings constants
    - Replace button labels with UIStrings constants
    - Replace feedback messages with FeedbackStrings constants
    - _Requirements: 4.2, 4.3, 6.2, 8.1, 8.3_

  - [x] 7.3 Migrate `comment_input.dart` hardcoded strings
    - Replace validation messages with ValidationStrings or FeedbackStrings
    - Replace success messages with FeedbackStrings constants
    - _Requirements: 3.2, 6.2, 8.1, 8.3_

  - [x] 7.4 Migrate `comment_item.dart` and `forum_list_item.dart` hardcoded strings
    - Replace time-related strings with UIStrings constants
    - Replace action labels with UIStrings constants
    - _Requirements: 4.2, 8.1, 8.3_

  - [x] 7.5 Migrate `forum_detail_page.dart` hardcoded strings
    - Replace labels and time strings with appropriate constants
    - _Requirements: 4.2, 8.1, 8.3_

- [x] 8. Checkpoint - Verify forum feature migration
  - Ensure forum feature compiles without errors
  - Run `flutter analyze` to check for issues
  - Ask the user if questions arise

- [x] 9. Migrate home feature strings
  - [x] 9.1 Migrate `home_page.dart` hardcoded strings
    - Replace feedback messages with FeedbackStrings constants
    - _Requirements: 6.2, 8.1, 8.3_

  - [x] 9.2 Migrate `welcome_header.dart` hardcoded strings
    - Replace greeting strings with UIStrings constants
    - _Requirements: 4.2, 8.1, 8.3_

  - [x] 9.3 Migrate `home_carousel.dart` hardcoded strings
    - Replace content state messages with UIStrings constants
    - Replace action labels with UIStrings constants
    - _Requirements: 4.2, 8.1, 8.3_

- [x] 10. Migrate video player feature strings
  - [x] 10.1 Create video player feature-specific strings file
    - Create `lib/features/video_player/presentation/constants/strings.dart`
    - Add VideoPlayerStrings class with feature-specific constants
    - _Requirements: 5.1, 5.2, 5.3_

  - [x] 10.2 Migrate `video_player_page.dart` hardcoded strings
    - Replace page titles with VideoPlayerStrings constants
    - Replace action labels with UIStrings constants
    - _Requirements: 4.2, 8.1, 8.3_

  - [x] 10.3 Migrate `video_player_page_web.dart` hardcoded strings
    - Replace page titles and labels with appropriate constants
    - Replace feedback messages with FeedbackStrings constants
    - _Requirements: 4.2, 6.2, 8.1, 8.3_

  - [x] 10.4 Migrate `playback_speed_selector.dart` hardcoded strings
    - Replace labels with VideoPlayerStrings constants
    - _Requirements: 4.2, 8.1, 8.3_

- [x] 11. Migrate remaining features
  - [x] 11.1 Migrate `explore_page.dart` hardcoded strings
    - Replace button labels with UIStrings constants
    - _Requirements: 4.2, 8.1, 8.3_

  - [x] 11.2 Migrate `account_page.dart` hardcoded strings
    - Replace section titles and button labels with UIStrings constants
    - _Requirements: 4.2, 8.1, 8.3_

  - [x] 11.3 Migrate `video_page.dart` (learn feature) hardcoded strings
    - Replace section titles with UIStrings constants
    - _Requirements: 4.2, 8.1, 8.3_

  - [x] 11.4 Migrate quiz feature hardcoded strings
    - Replace quiz-related labels with appropriate constants
    - _Requirements: 4.2, 8.1, 8.3_

- [x] 12. Migrate data layer strings
  - [x] 12.1 Migrate repository error messages
    - Replace hardcoded error messages in repositories with ErrorStrings
    - Update `report_repository_impl.dart` error messages
    - _Requirements: 2.2, 8.1, 8.3_

  - [x] 12.2 Migrate datasource error messages
    - Replace hardcoded error messages in datasources with ErrorStrings
    - Update `report_local_datasource.dart` error messages
    - _Requirements: 2.2, 8.1, 8.3_

  - [x] 12.3 Migrate service error messages
    - Replace hardcoded error messages in services with ErrorStrings
    - Update YouTube and Gemini service error messages
    - _Requirements: 2.2, 8.1, 8.3_

- [x] 13. Checkpoint - Verify all migrations
  - Ensure all features compile without errors
  - Run `flutter analyze` to check for issues
  - Run existing tests to verify no behavioral changes
  - Ask the user if questions arise

- [x] 14. Update documentation
  - [x] 14.1 Update `README.md` with string constant usage guidelines
    - Add section on string constant classes
    - Add examples of correct usage
    - Document when to use constants vs. AppLocalizations
    - _Requirements: 9.1, 9.3, 9.4_

  - [x] 14.2 Add documentation comments to each string class
    - Document the purpose of each string category
    - Add usage examples in class documentation
    - _Requirements: 9.2_

- [x] 15. Final checkpoint - Complete verification
  - Run `flutter analyze` to ensure no issues
  - Run all tests to verify no regressions
  - Verify all hardcoded strings have been migrated
  - Ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Migration is done feature by feature to minimize risk
- Existing localized strings (AppLocalizations) should NOT be duplicated in constants
