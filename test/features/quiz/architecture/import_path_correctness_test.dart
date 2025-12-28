import 'dart:io';
import 'package:flutter_test/flutter_test.dart' hide test, group, setUp, tearDown, expect;
import 'package:glados/glados.dart';

/// **Feature: clean-architecture-audit-fix, Property 2: Import Path Correctness**
/// **Validates: Requirements 1.5, 4.4**
///
/// Property: For any Dart file in the codebase that imports quiz services,
/// the import path SHALL reference either the domain layer abstract interface
/// (`lib/features/quiz/domain/services/`) or the data layer implementation
/// (`lib/features/quiz/data/services/`), and SHALL NOT reference the old
/// services folder (`lib/features/quiz/services/`).

// ============================================================================
// Test Data and Generators
// ============================================================================

/// Represents a Dart file with its path and imports
class DartFile {
  final String path;
  final String content;
  final List<String> imports;

  DartFile({
    required this.path,
    required this.content,
    required this.imports,
  });

  /// Checks if any import references the old services folder
  /// Old services folder pattern: 'features/quiz/services/' but NOT
  /// 'features/quiz/domain/services/' or 'features/quiz/data/services/'
  bool get hasOldServicesImport {
    return imports.any((import) => _isOldServicesImport(import));
  }

  /// Returns list of imports that reference the old services folder
  List<String> get oldServicesImports {
    return imports.where((import) => _isOldServicesImport(import)).toList();
  }

  /// Checks if an import references the old services folder
  static bool _isOldServicesImport(String import) {
    // Normalize path separators for cross-platform compatibility
    final normalizedImport = import.replaceAll('\\', '/');
    
    // Pattern for old services folder: features/quiz/services/
    // This should NOT match: features/quiz/domain/services/ or features/quiz/data/services/
    final oldServicesPattern = RegExp(r'features/quiz/services/');
    final domainServicesPattern = RegExp(r'features/quiz/domain/services/');
    final dataServicesPattern = RegExp(r'features/quiz/data/services/');

    // Check if it matches old services but NOT domain or data services
    return oldServicesPattern.hasMatch(normalizedImport) &&
        !domainServicesPattern.hasMatch(normalizedImport) &&
        !dataServicesPattern.hasMatch(normalizedImport);
  }
}

/// Collects all Dart files from the lib directory
List<DartFile> collectAllDartFiles() {
  final dartFiles = <DartFile>[];
  final libDir = Directory('lib');

  if (!libDir.existsSync()) {
    return dartFiles;
  }

  _collectDartFilesRecursive(libDir, dartFiles);
  return dartFiles;
}

void _collectDartFilesRecursive(Directory dir, List<DartFile> files) {
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final imports = _extractImports(content);
      files.add(DartFile(
        path: entity.path,
        content: content,
        imports: imports,
      ));
    }
  }
}

List<String> _extractImports(String content) {
  final imports = <String>[];
  final lines = content.split('\n');

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('import ') || trimmed.startsWith("import '")) {
      imports.add(trimmed);
    }
  }

  return imports;
}

/// Generator for Dart file indices
extension DartFileGenerators on Any {
  Generator<int> dartFileIndex(int maxIndex) {
    if (maxIndex <= 0) return always(0);
    return intInRange(0, maxIndex);
  }
}

// ============================================================================
// Property-Based Tests
// ============================================================================

void main() {
  final allDartFiles = collectAllDartFiles();
  
  // Filter to files that have any quiz-related imports
  final filesWithQuizImports = allDartFiles.where((file) {
    return file.imports.any((import) => 
        import.contains('quiz/services') ||
        import.contains('quiz/domain/services') ||
        import.contains('quiz/data/services'));
  }).toList();

  group('Property 2: Import Path Correctness', () {
    // ========================================================================
    // Property 2.1: No file SHALL import from old services folder
    // Validates: Requirements 1.5, 4.4
    // ========================================================================
    if (allDartFiles.isNotEmpty) {
      Glados(any.dartFileIndex(allDartFiles.length), ExploreConfig(numRuns: 100))
          .test(
        'For any Dart file, it SHALL NOT import from old quiz services folder',
        (index) {
          final file = allDartFiles[index % allDartFiles.length];

          expect(
            file.hasOldServicesImport,
            isFalse,
            reason:
                'File ${file.path} imports from old services folder:\n${file.oldServicesImports.join('\n')}',
          );
        },
      );
    }

    // ========================================================================
    // Property 2.2: Files with quiz service imports SHALL use correct paths
    // Validates: Requirements 1.5, 4.4
    // ========================================================================
    if (filesWithQuizImports.isNotEmpty) {
      Glados(any.dartFileIndex(filesWithQuizImports.length), ExploreConfig(numRuns: 100))
          .test(
        'For any file importing quiz services, imports SHALL use domain or data layer paths',
        (index) {
          final file = filesWithQuizImports[index % filesWithQuizImports.length];
          final violations = file.oldServicesImports;

          expect(
            violations.isEmpty,
            isTrue,
            reason:
                'File ${file.path} has ${violations.length} import(s) from old services folder:\n${violations.join('\n')}',
          );
        },
      );
    }
  });

  // ==========================================================================
  // Comprehensive Import Path Scan (Unit Test)
  // ==========================================================================
  group('Import Path Correctness - Comprehensive Scan', () {
    test('All Dart files should not import from old quiz services folder', () {
      final violations = <String>[];

      for (final file in allDartFiles) {
        final fileViolations = file.oldServicesImports;
        if (fileViolations.isNotEmpty) {
          violations.add(
              '${file.path}:\n  ${fileViolations.map((v) => '- $v').join('\n  ')}');
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Found ${violations.length} file(s) importing from old services folder:\n\n${violations.join('\n\n')}',
      );
    });

    test('Quiz service imports should reference domain or data layer only', () {
      for (final file in filesWithQuizImports) {
        for (final import in file.imports) {
          if (import.contains('quiz') && import.contains('services')) {
            final normalizedImport = import.replaceAll('\\', '/');
            
            // If it's a quiz services import, it must be from domain or data
            final isValidPath = 
                normalizedImport.contains('quiz/domain/services') ||
                normalizedImport.contains('quiz/data/services');
            
            final isOldPath = normalizedImport.contains('quiz/services/') &&
                !normalizedImport.contains('quiz/domain/services') &&
                !normalizedImport.contains('quiz/data/services');

            if (isOldPath) {
              fail('File ${file.path} imports from old services folder: $import\n'
                  'Should import from quiz/domain/services/ or quiz/data/services/ instead');
            }
          }
        }
      }
    });

    test('Injection container should import services from correct locations', () {
      final injectionContainerFiles = allDartFiles
          .where((f) => f.path.replaceAll('\\', '/').contains('injection_container'))
          .toList();

      for (final file in injectionContainerFiles) {
        final violations = file.oldServicesImports;
        
        expect(
          violations.isEmpty,
          isTrue,
          reason:
              'Injection container ${file.path} imports from old services folder:\n${violations.join('\n')}',
        );
      }
    });
  });

  // ==========================================================================
  // Edge Cases
  // ==========================================================================
  group('Import Path Correctness - Edge Cases', () {
    test('Empty lib directory should not cause errors', () {
      expect(() => collectAllDartFiles(), returnsNormally);
    });

    test('Dart files count should be greater than zero', () {
      expect(
        allDartFiles.isNotEmpty,
        isTrue,
        reason: 'Expected to find Dart files in lib/',
      );
    });

    test('Should correctly identify old services path pattern', () {
      // Test the pattern matching logic
      expect(
        DartFile._isOldServicesImport("import 'package:guardiancare/features/quiz/services/gemini_ai_service.dart';"),
        isTrue,
        reason: 'Should identify old services folder import',
      );
      
      expect(
        DartFile._isOldServicesImport("import 'package:guardiancare/features/quiz/domain/services/gemini_ai_service.dart';"),
        isFalse,
        reason: 'Should NOT identify domain services as old services',
      );
      
      expect(
        DartFile._isOldServicesImport("import 'package:guardiancare/features/quiz/data/services/gemini_ai_service_impl.dart';"),
        isFalse,
        reason: 'Should NOT identify data services as old services',
      );
    });
  });
}
