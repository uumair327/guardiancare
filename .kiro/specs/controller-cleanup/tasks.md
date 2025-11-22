# Implementation Plan

- [x] 1. Analyze and categorize all controller files



  - Scan lib/src/features directory for all controller files
  - Identify which controllers have BLoC replacements by checking for corresponding bloc directories
  - Search for active imports/references to each controller file using grep
  - Create categorization: safe to remove (has BLoC, no references), needs review (has references), utility (static methods)
  - _Requirements: 1.1, 1.2_


- [ ] 2. Remove confirmed legacy controllers with BLoC replacements
- [x] 2.1 Remove report feature controller

  - Delete lib/src/features/report/controllers/report_form_controller.dart
  - Delete lib/src/features/report/models/report_form_state.dart if only used by controller
  - Verify ReportBloc exists as replacement
  - _Requirements: 1.3, 1.5_

- [x] 2.2 Remove forum feature controllers


  - Delete lib/src/features/forum/controllers/comment_controller.dart
  - Delete lib/src/features/forum/controllers/forum_controller.dart if not referenced
  - Verify CommentBloc exists as replacement
  - _Requirements: 1.3, 1.5_

- [ ] 2.3 Remove consent feature controller


  - Delete lib/src/features/consent/controllers/consent_controller.dart
  - Verify ConsentBloc exists as replacement
  - _Requirements: 1.3, 1.5_

- [x] 2.4 Remove quiz feature controller


  - Check if quiz_controller.dart contains only static utility methods
  - If it contains showQuizCompletedDialog, extract to separate utility file if still needed
  - Delete lib/src/features/quiz/controllers/quiz_controller.dart
  - Verify QuizBloc exists as replacement
  - _Requirements: 1.3, 1.5_

- [ ] 3. Analyze and handle authentication controllers
- [x] 3.1 Check authentication controller usage



  - Search for imports of lib/src/features/authentication/controllers/login_controller.dart
  - Determine if authentication still uses controller pattern or has BLoC replacement
  - If no BLoC exists and controller is actively used, document for future migration
  - If BLoC exists or controller is unused, delete the file
  - _Requirements: 1.1, 1.2_

- [x] 3.2 Remove duplicate home controller


  - Delete lib/src/features/authentication/controllers/home_controller.dart (duplicate/dead code)
  - Verify no active references exist
  - _Requirements: 1.3_

- [ ] 4. Handle utility and special-case controllers
- [x] 4.1 Evaluate home controller


  - Check if lib/src/features/home/controllers/home_controller.dart is actively used
  - Search for imports and references to fetchCarouselData method
  - If unused, delete the file
  - If used, determine if it should be migrated to BLoC or kept as utility
  - _Requirements: 1.1, 1.2_

- [x] 4.2 Evaluate explore controller


  - Check if lib/src/features/explore/controllers/explore_controller.dart has BLoC replacement
  - Search for active references
  - If unused and has BLoC, delete the file
  - If actively used, document for future migration
  - _Requirements: 1.1, 1.2_

- [x] 4.3 Evaluate emergency controller

  - Check lib/src/features/emergency/controllers/emergency_contact_controller.dart
  - Determine if static utility methods should remain or be moved
  - If it's a legitimate utility class with static methods, keep it
  - If it's a state management controller, remove it
  - _Requirements: 1.1_


- [ ] 4.4 Evaluate API controllers
  - Check lib/src/api/youtube/controllers/account_controller.dart
  - Determine if API controllers follow different pattern than feature controllers
  - Document decision to keep or remove
  - _Requirements: 1.1_

- [ ] 5. Clean up imports for deleted controllers
- [ ] 5.1 Search for import statements
  - Use grep to find all files importing deleted controller files
  - Create list of files that need import cleanup
  - _Requirements: 3.1_

- [ ] 5.2 Remove controller imports
  - For each file with controller imports, remove the import statement
  - Remove any unused variables or references to deleted controllers
  - _Requirements: 3.2_

- [ ] 5.3 Verify no broken imports
  - Run diagnostics on files with removed imports
  - Fix any compilation errors
  - _Requirements: 3.3, 3.4_

- [ ] 6. Remove controller test files
- [x] 6.1 Remove report controller tests


  - Delete test/src/features/report/controllers/report_form_controller_test.dart
  - Delete test/src/features/report/models/report_form_state_test.dart if exists
  - _Requirements: 2.1, 2.2_

- [x] 6.2 Remove forum controller tests


  - Delete test/src/features/forum/controllers/comment_controller_test.dart
  - _Requirements: 2.1, 2.2_

- [ ] 6.3 Remove consent controller tests
  - Delete test/src/features/consent/controllers/consent_controller_security_test.dart
  - _Requirements: 2.1, 2.2_

- [ ] 6.4 Remove authentication controller tests
  - Delete test/src/features/authentication/controllers/login_controller_test.dart if controller was removed
  - _Requirements: 2.1, 2.2_

- [ ] 6.5 Remove learn controller tests
  - Delete test/src/features/learn/controllers/video_controller_test.dart if controller was removed
  - _Requirements: 2.1, 2.2_

- [ ] 7. Remove empty controller directories
- [x] 7.1 Check and remove empty directories


  - Check if lib/src/features/report/controllers is empty and remove it
  - Check if lib/src/features/forum/controllers is empty and remove it
  - Check if lib/src/features/consent/controllers is empty and remove it
  - Check if lib/src/features/quiz/controllers is empty and remove it
  - Check if lib/src/features/authentication/controllers is empty and remove it
  - Check if test/src/features/*/controllers directories are empty and remove them
  - _Requirements: 1.4_

- [ ] 8. Verify cleanup and generate report
- [x] 8.1 Run diagnostics


  - Run getDiagnostics on entire codebase
  - Verify no new compilation errors introduced
  - Fix any issues found
  - _Requirements: 3.4_

- [ ] 8.2 Search for remaining controller references



  - Search for any remaining imports of deleted controllers
  - Search for any remaining references to controller classes
  - Clean up any missed references
  - _Requirements: 3.1, 3.2_

- [x] 8.3 Generate cleanup summary



  - Count total controller files deleted
  - Count total test files deleted
  - Count empty directories removed
  - Count import statements cleaned
  - List all deleted file paths
  - Display summary to user
  - _Requirements: 4.1, 4.2, 4.3, 4.4_
