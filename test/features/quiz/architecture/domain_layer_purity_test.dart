import 'dart:io';
import 'package:flutter_test/flutter_test.dart' hide test, group, setUp, tearDown, expect;
import 'package:glados/glados.dart';

/// **Feature: clean-architecture-audit-fix, Property 1: Domain Layer Purity**
/// **Validates: Requirements 1.3, 2.1, 2.2, 2.4, 6.2**
///
/// Property: For any Dart file in the domain layer (`lib/features/*/domain/**/*.dart`),
/// the file SHALL NOT contain imports from the data layer (`lib/features/*/data/`)
/// or the old services folder (`lib/features/*/services/`), AND if the file defines
/// a service interface, it SHALL be an abstract class.

// ============================================================================
// Test Data and Generators
// ============================================================================

/// Represents a domain layer file with its path and content
class DomainFile {
  final String path;
  final String content;
  final List<String> imports;

  DomainFile({
    required this.path,
    required this.content,
    required this.imports,
  });

  /// Checks if any import references the data layer
  bool get hasDataLayerImport {
    return imports.any((import) =>
        import.contains('/data/') ||
        import.contains('data/repositories') ||
        import.contains('data/datasources') ||
        import.contains('data/models') ||
        import.contains('data/services'));
  }

  /// Checks if any import references the old services folder (outside layers)
  bool get hasOldServicesImport {
    // Match imports like 'features/quiz/services/' but NOT 'features/quiz/domain/services/'
    return imports.any((import) {
      // Check for services folder that is NOT inside domain or data
      final servicesPattern = RegExp(r'features/\w+/services/');
      final domainServicesPattern = RegExp(r'features/\w+/domain/services/');
      final dataServicesPattern = RegExp(r'features/\w+/data/services/');

      return servicesPattern.hasMatch(import) &&
          !domainServicesPattern.hasMatch(import) &&
          !dataServicesPattern.hasMatch(import);
    });
  }

  /// Returns list of violating imports
  List<String> get violatingImports {
    return imports.where((import) {
      // Check for data layer imports
      if (import.contains('/data/') ||
          import.contains('data/repositories') ||
          import.contains('data/datasources') ||
          import.contains('data/models') ||
          import.contains('data/services')) {
        return true;
      }

      // Check for old services folder imports
      final servicesPattern = RegExp(r'features/\w+/services/');
      final domainServicesPattern = RegExp(r'features/\w+/domain/services/');
      final dataServicesPattern = RegExp(r'features/\w+/data/services/');

      return servicesPattern.hasMatch(import) &&
          !domainServicesPattern.hasMatch(import) &&
          !dataServicesPattern.hasMatch(import);
    }).toList();
  }
}

/// Collects all domain layer files from the project
List<DomainFile> collectDomainFiles() {
  final domainFiles = <DomainFile>[];
  final libDir = Directory('lib/features');

  if (!libDir.existsSync()) {
    return domainFiles;
  }

  // Find all domain directories
  for (final featureDir in libDir.listSync()) {
    if (featureDir is Directory) {
      final domainDir = Directory('${featureDir.path}/domain');
      if (domainDir.existsSync()) {
        _collectDartFiles(domainDir, domainFiles);
      }
    }
  }

  return domainFiles;
}

void _collectDartFiles(Directory dir, List<DomainFile> files) {
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final imports = _extractImports(content);
      files.add(DomainFile(
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
    if (trimmed.startsWith('import ')) {
      imports.add(trimmed);
    }
  }

  return imports;
}

/// Generator for domain file indices
extension DomainFileGenerators on Any {
  Generator<int> domainFileIndex(int maxIndex) {
    if (maxIndex <= 0) return always(0);
    return intInRange(0, maxIndex);
  }
}

// ============================================================================
// Property-Based Tests
// ============================================================================

void main() {
  final domainFiles = collectDomainFiles();

  group('Property 1: Domain Layer Purity', () {
    // ========================================================================
    // Property 1.1: Domain files SHALL NOT import from data layer
    // Validates: Requirements 1.3, 2.4
    // ========================================================================
    if (domainFiles.isNotEmpty) {
      Glados(any.domainFileIndex(domainFiles.length), ExploreConfig(numRuns: 100))
          .test(
        'For any domain layer file, it SHALL NOT import from data layer',
        (index) {
          final file = domainFiles[index % domainFiles.length];

          expect(
            file.hasDataLayerImport,
            isFalse,
            reason:
                'Domain file ${file.path} imports from data layer:\n${file.violatingImports.join('\n')}',
          );
        },
      );
    }

    // ========================================================================
    // Property 1.2: Domain files SHALL NOT import from old services folder
    // Validates: Requirements 2.1, 2.2
    // ========================================================================
    if (domainFiles.isNotEmpty) {
      Glados(any.domainFileIndex(domainFiles.length), ExploreConfig(numRuns: 100))
          .test(
        'For any domain layer file, it SHALL NOT import from old services folder',
        (index) {
          final file = domainFiles[index % domainFiles.length];

          expect(
            file.hasOldServicesImport,
            isFalse,
            reason:
                'Domain file ${file.path} imports from old services folder:\n${file.violatingImports.join('\n')}',
          );
        },
      );
    }

    // ========================================================================
    // Property 1.3: All domain files SHALL have no architectural violations
    // Validates: Requirements 1.3, 2.1, 2.2, 2.4, 6.2
    // ========================================================================
    if (domainFiles.isNotEmpty) {
      Glados(any.domainFileIndex(domainFiles.length), ExploreConfig(numRuns: 100))
          .test(
        'For any domain layer file, it SHALL have no architectural violations',
        (index) {
          final file = domainFiles[index % domainFiles.length];
          final violations = file.violatingImports;

          expect(
            violations.isEmpty,
            isTrue,
            reason:
                'Domain file ${file.path} has ${violations.length} architectural violation(s):\n${violations.join('\n')}',
          );
        },
      );
    }
  });

  // ==========================================================================
  // Comprehensive Domain Layer Scan (Unit Test)
  // ==========================================================================
  group('Domain Layer Purity - Comprehensive Scan', () {
    test('All domain layer files should be free of architectural violations',
        () {
      final violations = <String>[];

      for (final file in domainFiles) {
        final fileViolations = file.violatingImports;
        if (fileViolations.isNotEmpty) {
          violations.add(
              '${file.path}:\n  ${fileViolations.map((v) => '- $v').join('\n  ')}');
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Found ${violations.length} file(s) with architectural violations:\n\n${violations.join('\n\n')}',
      );
    });

    test('Domain service interfaces should be abstract classes', () {
      final serviceFiles = domainFiles
          .where((f) => f.path.replaceAll('\\', '/').contains('/domain/services/'))
          .where((f) => !f.path.endsWith('services.dart')) // Skip barrel files
          .toList();

      for (final file in serviceFiles) {
        // Check if file contains abstract class definition
        final hasAbstractClass =
            file.content.contains(RegExp(r'abstract\s+class\s+\w+'));

        expect(
          hasAbstractClass,
          isTrue,
          reason:
              'Domain service file ${file.path} should define an abstract class',
        );
      }
    });

    test('Domain layer should not have concrete service implementations', () {
      final serviceFiles = domainFiles
          .where((f) => f.path.replaceAll('\\', '/').contains('/domain/services/'))
          .where((f) => !f.path.endsWith('services.dart'))
          .toList();

      for (final file in serviceFiles) {
        // Check for concrete class implementations (class without abstract)
        final hasConcreteClass = RegExp(r'(?<!abstract\s)class\s+\w+Impl')
            .hasMatch(file.content);

        expect(
          hasConcreteClass,
          isFalse,
          reason:
              'Domain service file ${file.path} should not contain concrete implementations (Impl classes)',
        );
      }
    });
  });

  // ==========================================================================
  // Edge Cases
  // ==========================================================================
  group('Domain Layer Purity - Edge Cases', () {
    test('Empty domain directory should not cause errors', () {
      // This test verifies the test infrastructure handles edge cases
      expect(() => collectDomainFiles(), returnsNormally);
    });

    test('Domain files count should be greater than zero', () {
      expect(
        domainFiles.isNotEmpty,
        isTrue,
        reason: 'Expected to find domain layer files in lib/features/*/domain/',
      );
    });

    test('Quiz domain should have service interfaces', () {
      final quizDomainServices = domainFiles
          .where((f) => f.path.replaceAll('\\', '/').contains('quiz/domain/services'))
          .where((f) => !f.path.endsWith('services.dart'))
          .toList();

      expect(
        quizDomainServices.isNotEmpty,
        isTrue,
        reason: 'Quiz feature should have domain service interfaces',
      );
    });
  });
}
