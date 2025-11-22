# Design Document

## Overview

This design outlines the systematic approach to removing all legacy controller files and their associated tests from the GuardianCare Flutter application. The application has successfully completed BLoC migration for all features, and the legacy controller files are no longer used. This cleanup will eliminate dead code, reduce codebase size, and prevent confusion about which state management pattern to use.

## Architecture

### Current State Analysis

Based on the migration documentation and codebase scan, the following controller files exist:

**Feature Controllers (Legacy - To Remove):**
1. `lib/src/features/report/controllers/report_form_controller.dart` - Replaced by `ReportBloc`
2. `lib/src/features/quiz/controllers/quiz_controller.dart` - Replaced by `QuizBloc`
3. `lib/src/features/forum/controllers/forum_controller.dart` - Replaced by `CommentBloc`
4. `lib/src/features/forum/controllers/comment_controller.dart` - Replaced by `CommentBloc`
5. `lib/src/features/home/controllers/home_controller.dart` - Static utility methods
6. `lib/src/features/explore/controllers/explore_controller.dart` - May still be in use
7. `lib/src/features/consent/controllers/consent_controller.dart` - Replaced by `ConsentBloc`
8. `lib/src/features/emergency/controllers/emergency_contact_controller.dart` - Static utility methods
9. `lib/src/features/authentication/controllers/login_controller.dart` - May still be in use
10. `lib/src/features/authentication/controllers/home_controller.dart` - Duplicate/dead code
11. `lib/src/api/youtube/controllers/account_controller.dart` - API controller

**Controller Test Files (To Remove):**
1. `test/src/features/report/controllers/report_form_controller_test.dart`
2. `test/src/features/forum/controllers/comment_controller_test.dart`
3. `test/src/features/authentication/controllers/login_controller_test.dart`
4. `test/src/features/consent/controllers/consent_controller_security_test.dart`
5. `test/src/features/learn/controllers/video_controller_test.dart`

### Cleanup Strategy

The cleanup will follow a phased approach:

**Phase 1: Analysis**
- Scan all controller files
- Identify which controllers have BLoC replacements
- Search for active imports/references to each controller
- Categorize controllers: confirmed dead, potentially active, utility classes

**Phase 2: Safe Removal**
- Remove controllers with zero references and confirmed BLoC replacements
- Remove associated test files
- Remove empty controller directories

**Phase 3: Import Cleanup**
- Search for and remove import statements for deleted controllers
- Verify no compilation errors

**Phase 4: Verification**
- Run diagnostics to check for errors
- Generate cleanup report

## Components and Interfaces

### 1. Controller Analyzer

**Purpose**: Identify all controller files and their usage status

**Interface**:
```dart
class ControllerAnalyzer {
  List<ControllerInfo> analyzeControllers();
  bool hasActiveReferences(String filePath);
  bool hasBlocReplacement(String controllerPath);
}

class ControllerInfo {
  String filePath;
  String featureName;
  bool hasReferences;
  bool hasBlocReplacement;
  ControllerType type; // Feature, Utility, API
}
```

**Implementation Approach**:
- Use `grepSearch` to find all controller class definitions
- Use `grepSearch` to find imports of each controller
- Cross-reference with BLoC files in the same feature directory
- Categorize based on file location and class structure

### 2. File Remover

**Purpose**: Safely delete controller files and directories

**Interface**:
```dart
class FileRemover {
  void removeFile(String filePath);
  void removeEmptyDirectory(String dirPath);
  List<String> getRemovedFiles();
}
```

**Implementation Approach**:
- Use `deleteFile` tool for each controller file
- Check if controller directory is empty after deletion
- Remove empty directories
- Track all deletions for reporting

### 3. Import Cleaner

**Purpose**: Remove import statements for deleted controllers

**Interface**:
```dart
class ImportCleaner {
  List<String> findFilesWithImport(String controllerPath);
  void removeImportFromFile(String filePath, String importPath);
  void cleanUnusedImports(String filePath);
}
```

**Implementation Approach**:
- Use `grepSearch` to find files importing deleted controllers
- Use `strReplace` to remove import lines
- Verify file still compiles after import removal

### 4. Cleanup Reporter

**Purpose**: Generate summary of cleanup operations

**Interface**:
```dart
class CleanupReporter {
  void recordDeletion(String filePath, String reason);
  void recordImportCleanup(String filePath, int importsRemoved);
  String generateReport();
}
```

**Implementation Approach**:
- Maintain lists of deleted files and cleaned imports
- Generate formatted summary with counts and file paths
- Display report to user

## Data Models

### Controller Classification

```dart
enum ControllerType {
  feature,      // Feature-specific controller with BLoC replacement
  utility,      // Static utility methods (may keep)
  api,          // API-specific controller (may keep)
  dead          // Confirmed dead code
}

enum RemovalStatus {
  safe,         // Safe to remove (no references, has BLoC)
  caution,      // Has references but BLoC exists
  keep,         // Should not remove (utility/API)
  unknown       // Needs manual review
}
```

### Deletion Record

```dart
class DeletionRecord {
  String filePath;
  String featureName;
  String reason;
  DateTime timestamp;
  bool isTestFile;
}
```

## Detailed Cleanup Plan

### Controllers to Remove (Confirmed Safe)

Based on migration documentation, these controllers have BLoC replacements and are marked as legacy:

1. **Report Feature**
   - File: `lib/src/features/report/controllers/report_form_controller.dart`
   - Replacement: `ReportBloc`
   - Status: Safe to remove
   - Test: `test/src/features/report/controllers/report_form_controller_test.dart`

2. **Forum Feature**
   - File: `lib/src/features/forum/controllers/comment_controller.dart`
   - Replacement: `CommentBloc`
   - Status: Safe to remove
   - Test: `test/src/features/forum/controllers/comment_controller_test.dart`

3. **Consent Feature**
   - File: `lib/src/features/consent/controllers/consent_controller.dart`
   - Replacement: `ConsentBloc`
   - Status: Safe to remove
   - Test: `test/src/features/consent/controllers/consent_controller_security_test.dart`

### Controllers Requiring Analysis

These need reference checking before removal:

1. **Quiz Feature**
   - File: `lib/src/features/quiz/controllers/quiz_controller.dart`
   - Replacement: `QuizBloc`
   - Note: Contains static utility method `showQuizCompletedDialog`
   - Action: Check if dialog is still used, may need to extract utility

2. **Forum Feature**
   - File: `lib/src/features/forum/controllers/forum_controller.dart`
   - Replacement: `CommentBloc`
   - Action: Verify no active usage

3. **Authentication Feature**
   - File: `lib/src/features/authentication/controllers/login_controller.dart`
   - Note: May still be in use for authentication
   - Action: Check for active references before removal

4. **Home Feature**
   - File: `lib/src/features/home/controllers/home_controller.dart`
   - Note: Contains `fetchCarouselData` method
   - Action: Check if still used

5. **Explore Feature**
   - File: `lib/src/features/explore/controllers/explore_controller.dart`
   - Action: Check for BLoC replacement and active usage

### Utility Controllers (Evaluate)

These may be legitimate utility classes:

1. **Emergency Feature**
   - File: `lib/src/features/emergency/controllers/emergency_contact_controller.dart`
   - Note: Static utility for launching phone calls
   - Action: Evaluate if this should remain as utility class

2. **API Controllers**
   - File: `lib/src/api/youtube/controllers/account_controller.dart`
   - Note: API-specific controller
   - Action: Evaluate if API controllers follow different pattern

## Error Handling

### Scenarios and Responses

1. **File Not Found**
   - Scenario: Controller file doesn't exist when trying to delete
   - Response: Log warning, continue with next file

2. **Active References Found**
   - Scenario: Controller has active imports after analysis
   - Response: Skip deletion, report to user for manual review

3. **Compilation Errors After Import Removal**
   - Scenario: Removing import breaks compilation
   - Response: Revert import removal, report issue to user

4. **Empty Directory Removal Fails**
   - Scenario: Directory not empty or permission issue
   - Response: Log warning, continue cleanup

5. **BLoC Replacement Not Found**
   - Scenario: Controller marked for removal but no BLoC exists
   - Response: Skip deletion, report for manual review

## Testing Strategy

### Pre-Cleanup Verification

1. **Baseline Compilation**
   - Run `getDiagnostics` on entire codebase
   - Record any existing errors
   - Ensure clean baseline before cleanup

2. **Reference Mapping**
   - Map all controller imports
   - Identify all files that reference controllers
   - Create dependency graph

### Post-Cleanup Verification

1. **Compilation Check**
   - Run `getDiagnostics` on affected files
   - Verify no new errors introduced
   - Compare against baseline

2. **Import Verification**
   - Search for any remaining controller imports
   - Verify all imports point to valid files

3. **Directory Structure**
   - Verify empty controller directories removed
   - Verify BLoC directories intact

### Test File Cleanup

1. **Identify Orphaned Tests**
   - Find test files for deleted controllers
   - Verify corresponding controller no longer exists

2. **Remove Test Files**
   - Delete controller test files
   - Remove empty test directories

3. **Verify Test Suite**
   - Ensure BLoC tests remain intact
   - Verify test suite still runs

## Implementation Steps

### Step 1: Pre-Cleanup Analysis
1. Scan for all controller files
2. Identify BLoC replacements
3. Search for active references
4. Generate analysis report
5. Get user confirmation

### Step 2: Safe Deletions
1. Delete controllers with zero references and confirmed BLoC replacements
2. Delete associated test files
3. Track all deletions

### Step 3: Import Cleanup
1. Search for imports of deleted controllers
2. Remove import statements
3. Verify compilation

### Step 4: Directory Cleanup
1. Check for empty controller directories
2. Remove empty directories
3. Verify structure

### Step 5: Verification
1. Run diagnostics
2. Generate cleanup report
3. Display summary to user

## Rollback Strategy

Since this is a deletion operation, rollback relies on version control:

1. **Git Safety**
   - Ensure all changes are committed before cleanup
   - User can revert via git if needed

2. **Incremental Approach**
   - Delete files in batches
   - Verify after each batch
   - Stop if errors detected

3. **Reporting**
   - Provide detailed list of deleted files
   - User can manually restore if needed

## Success Criteria

1. All legacy controller files with BLoC replacements removed
2. All associated test files removed
3. No broken imports remaining
4. No compilation errors introduced
5. Empty controller directories removed
6. Comprehensive cleanup report generated
7. Codebase size reduced
8. Only BLoC pattern remains for state management

## Cleanup Report Format

```
Controller Cleanup Summary
==========================

Deleted Controller Files: X
Deleted Test Files: Y
Empty Directories Removed: Z
Import Statements Cleaned: W

Deleted Controllers:
- lib/src/features/report/controllers/report_form_controller.dart (Replaced by ReportBloc)
- lib/src/features/forum/controllers/comment_controller.dart (Replaced by CommentBloc)
...

Deleted Test Files:
- test/src/features/report/controllers/report_form_controller_test.dart
...

Cleaned Imports:
- lib/src/features/report/screens/case_questions_page.dart (1 import removed)
...

Verification:
✅ No compilation errors
✅ All imports valid
✅ BLoC files intact

Status: Cleanup Complete
```

## Notes

- The cleanup focuses on feature controllers that have been replaced by BLoCs
- Utility classes with static methods may be preserved if they serve a valid purpose
- API controllers may follow a different pattern and should be evaluated separately
- All deletions are tracked for transparency and potential rollback
- The cleanup is conservative - when in doubt, skip deletion and report for manual review
