# Requirements Document

## Introduction

This specification addresses the removal of dead and redundant controller code from the GuardianCare Flutter application. The application has been migrated to use the BLoC (Business Logic Component) pattern for state management, but legacy controller files remain in the codebase. These files are no longer used and should be removed to maintain code cleanliness, reduce confusion, and prevent accidental usage of deprecated patterns.

## Glossary

- **System**: The GuardianCare Flutter application codebase
- **Controller**: Legacy state management classes that extend ChangeNotifier or contain business logic without using BLoC pattern
- **BLoC**: Business Logic Component pattern implementation using flutter_bloc package
- **Dead Code**: Code files that are no longer referenced or used in the application
- **Controller Directory**: A directory named "controllers" within a feature module

## Requirements

### Requirement 1

**User Story:** As a developer, I want all legacy controller files removed from the codebase, so that I only work with the BLoC pattern and avoid confusion about which state management approach to use.

#### Acceptance Criteria

1. WHEN the System scans the lib/src/features directory, THE System SHALL identify all controller files that have corresponding BLoC implementations
2. WHEN a controller file is identified for removal, THE System SHALL verify that no active imports reference the controller file
3. WHEN all references to a controller are verified as removed, THE System SHALL delete the controller file
4. WHEN all controller files in a controllers directory are deleted, THE System SHALL delete the empty controllers directory
5. THE System SHALL preserve all BLoC implementation files during the cleanup process

### Requirement 2

**User Story:** As a developer, I want all test files for legacy controllers removed, so that the test suite only contains tests for current BLoC implementations.

#### Acceptance Criteria

1. WHEN the System scans the test directory, THE System SHALL identify all controller test files
2. WHEN a controller test file is identified, THE System SHALL verify that the corresponding controller no longer exists in the lib directory
3. WHEN verification is complete, THE System SHALL delete the controller test file
4. THE System SHALL preserve all BLoC-related test files during the cleanup process

### Requirement 3

**User Story:** As a developer, I want any imports of deleted controllers removed from remaining files, so that the codebase has no broken import statements.

#### Acceptance Criteria

1. WHEN the System deletes a controller file, THE System SHALL search for all files that import the deleted controller
2. WHEN an import statement for a deleted controller is found, THE System SHALL remove the import line from the file
3. IF a file has unused imports after controller import removal, THEN THE System SHALL remove those unused imports
4. THE System SHALL verify that no compilation errors exist after import cleanup

### Requirement 4

**User Story:** As a developer, I want a summary report of all removed files, so that I can verify the cleanup was performed correctly.

#### Acceptance Criteria

1. WHEN the cleanup process begins, THE System SHALL create a list of all controller files to be removed
2. WHEN each file is deleted, THE System SHALL record the file path in a deletion log
3. WHEN the cleanup process completes, THE System SHALL display a summary showing the count of deleted controller files and test files
4. THE System SHALL display the list of deleted file paths in the summary report
