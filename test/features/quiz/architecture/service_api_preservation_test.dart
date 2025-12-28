import 'dart:io';
import 'package:flutter_test/flutter_test.dart' hide test, group, setUp, tearDown, expect;
import 'package:glados/glados.dart';

/// **Feature: clean-architecture-audit-fix, Property 3: Service API Preservation**
/// **Validates: Requirements 5.1**
///
/// Property: For any public method defined in the original service implementations
/// (GeminiAIService, YoutubeSearchService), the relocated service implementations
/// SHALL maintain the identical method signature (name, parameters, return type).

// ============================================================================
// Test Data and Structures
// ============================================================================

/// Represents a method signature extracted from source code
class MethodSignature {
  final String name;
  final String returnType;
  final List<String> parameters;
  final bool isAsync;

  MethodSignature({
    required this.name,
    required this.returnType,
    required this.parameters,
    required this.isAsync,
  });

  @override
  String toString() =>
      '${isAsync ? 'Future<' : ''}$returnType${isAsync ? '>' : ''} $name(${parameters.join(', ')})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MethodSignature) return false;
    return name == other.name &&
        returnType == other.returnType &&
        _listEquals(parameters, other.parameters);
  }

  @override
  int get hashCode => Object.hash(name, returnType, parameters.join(','));

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Represents a service file with its interface and implementation
class ServicePair {
  final String serviceName;
  final String interfacePath;
  final String implementationPath;
  final String interfaceContent;
  final String implementationContent;

  ServicePair({
    required this.serviceName,
    required this.interfacePath,
    required this.implementationPath,
    required this.interfaceContent,
    required this.implementationContent,
  });

  /// Extracts method signatures from the interface (abstract class)
  List<MethodSignature> get interfaceMethods {
    return _extractMethodSignatures(interfaceContent, isAbstract: true);
  }

  /// Extracts method signatures from the implementation
  List<MethodSignature> get implementationMethods {
    return _extractMethodSignatures(implementationContent, isAbstract: false);
  }

  /// Checks if implementation has all interface methods with matching signatures
  bool get hasMatchingSignatures {
    final interfaceSigs = interfaceMethods;
    final implSigs = implementationMethods;

    for (final interfaceMethod in interfaceSigs) {
      final matchingImpl = implSigs.firstWhere(
        (impl) => impl.name == interfaceMethod.name,
        orElse: () => MethodSignature(
          name: '',
          returnType: '',
          parameters: [],
          isAsync: false,
        ),
      );

      if (matchingImpl.name.isEmpty) {
        return false; // Method not found in implementation
      }

      // Compare signatures (normalize for comparison)
      if (!_signaturesMatch(interfaceMethod, matchingImpl)) {
        return false;
      }
    }

    return true;
  }

  /// Returns list of signature mismatches
  List<String> get signatureMismatches {
    final mismatches = <String>[];
    final interfaceSigs = interfaceMethods;
    final implSigs = implementationMethods;

    for (final interfaceMethod in interfaceSigs) {
      final matchingImpl = implSigs.firstWhere(
        (impl) => impl.name == interfaceMethod.name,
        orElse: () => MethodSignature(
          name: '',
          returnType: '',
          parameters: [],
          isAsync: false,
        ),
      );

      if (matchingImpl.name.isEmpty) {
        mismatches.add(
            'Method "${interfaceMethod.name}" not found in implementation');
      } else if (!_signaturesMatch(interfaceMethod, matchingImpl)) {
        mismatches.add(
            'Method "${interfaceMethod.name}" signature mismatch:\n'
            '  Interface: $interfaceMethod\n'
            '  Implementation: $matchingImpl');
      }
    }

    return mismatches;
  }

  /// Compares two method signatures for equivalence
  bool _signaturesMatch(MethodSignature a, MethodSignature b) {
    // Names must match
    if (a.name != b.name) return false;

    // Return types must match (normalize)
    final normalizedReturnA = _normalizeType(a.returnType);
    final normalizedReturnB = _normalizeType(b.returnType);
    if (normalizedReturnA != normalizedReturnB) return false;

    // Parameter count must match
    if (a.parameters.length != b.parameters.length) return false;

    // Parameter types must match (normalize)
    for (int i = 0; i < a.parameters.length; i++) {
      final normalizedParamA = _normalizeParameter(a.parameters[i]);
      final normalizedParamB = _normalizeParameter(b.parameters[i]);
      if (normalizedParamA != normalizedParamB) return false;
    }

    return true;
  }

  /// Normalizes a type string for comparison
  String _normalizeType(String type) {
    return type
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('Future < ', 'Future<')
        .replaceAll(' >', '>')
        .replaceAll('Either < ', 'Either<')
        .replaceAll('List < ', 'List<')
        .trim();
  }

  /// Normalizes a parameter string for comparison
  String _normalizeParameter(String param) {
    // Extract just the type, ignoring parameter name
    final parts = param.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      // Return just the type part
      return parts.sublist(0, parts.length - 1).join(' ');
    }
    return param.trim();
  }

  /// Extracts method signatures from Dart source code
  List<MethodSignature> _extractMethodSignatures(String content, {required bool isAbstract}) {
    final methods = <MethodSignature>[];

    if (isAbstract) {
      // For abstract methods, use regex on full content
      // Match: Future<Either<Failure, List<String>>> generateSearchTerms(String category);
      final abstractMethodPattern = RegExp(
        r'(Future\s*<[^;]+>)\s+([a-z][A-Za-z0-9_]*)\s*\(([^)]*)\)\s*;',
        multiLine: true,
      );

      for (final match in abstractMethodPattern.allMatches(content)) {
        final returnType = match.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim();
        final methodName = match.group(2)!;
        final params = match.group(3)!;

        methods.add(MethodSignature(
          name: methodName,
          returnType: returnType,
          parameters: _parseParameters(params),
          isAsync: true,
        ));
      }
    } else {
      // For implementations, find @override followed by method signature
      // Handle multi-line method signatures
      final lines = content.split('\n');
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        
        if (line == '@override') {
          // Collect lines until we find the opening brace or async keyword
          final methodLines = <String>[];
          for (int j = i + 1; j < lines.length; j++) {
            final nextLine = lines[j];
            methodLines.add(nextLine);
            
            // Check if we've reached the end of the signature
            if (nextLine.contains(') async {') || 
                nextLine.contains(') async{') ||
                nextLine.contains('){') ||
                nextLine.contains(') {') ||
                (nextLine.trim().endsWith('{') && nextLine.contains(')'))) {
              break;
            }
          }
          
          // Join and parse the method signature
          final methodSignature = methodLines.join(' ').trim();
          
          // Extract return type, method name, and parameters
          final implMethodMatch = RegExp(
            r'(Future\s*<[^>]+(?:<[^>]+(?:<[^>]+>)*>)*>)\s+([a-z][A-Za-z0-9_]*)\s*\(([^)]*)\)',
          ).firstMatch(methodSignature);

          if (implMethodMatch != null) {
            methods.add(MethodSignature(
              name: implMethodMatch.group(2)!,
              returnType: implMethodMatch.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim(),
              parameters: _parseParameters(implMethodMatch.group(3)!),
              isAsync: true,
            ));
          }
        }
      }
    }

    return methods;
  }

  /// Parses parameter string into list of parameter types
  List<String> _parseParameters(String paramString) {
    if (paramString.trim().isEmpty) return [];

    final params = <String>[];
    var current = '';
    var depth = 0;

    for (final char in paramString.split('')) {
      if (char == '<') depth++;
      if (char == '>') depth--;
      if (char == ',' && depth == 0) {
        if (current.trim().isNotEmpty) {
          params.add(current.trim());
        }
        current = '';
      } else {
        current += char;
      }
    }

    if (current.trim().isNotEmpty) {
      params.add(current.trim());
    }

    return params;
  }
}

/// Collects service pairs (interface + implementation) for testing
List<ServicePair> collectServicePairs() {
  final pairs = <ServicePair>[];

  // GeminiAIService
  final geminiInterfacePath = 'lib/features/quiz/domain/services/gemini_ai_service.dart';
  final geminiImplPath = 'lib/features/quiz/data/services/gemini_ai_service_impl.dart';

  if (File(geminiInterfacePath).existsSync() && File(geminiImplPath).existsSync()) {
    pairs.add(ServicePair(
      serviceName: 'GeminiAIService',
      interfacePath: geminiInterfacePath,
      implementationPath: geminiImplPath,
      interfaceContent: File(geminiInterfacePath).readAsStringSync(),
      implementationContent: File(geminiImplPath).readAsStringSync(),
    ));
  }

  // YoutubeSearchService
  final youtubeInterfacePath = 'lib/features/quiz/domain/services/youtube_search_service.dart';
  final youtubeImplPath = 'lib/features/quiz/data/services/youtube_search_service_impl.dart';

  if (File(youtubeInterfacePath).existsSync() && File(youtubeImplPath).existsSync()) {
    pairs.add(ServicePair(
      serviceName: 'YoutubeSearchService',
      interfacePath: youtubeInterfacePath,
      implementationPath: youtubeImplPath,
      interfaceContent: File(youtubeInterfacePath).readAsStringSync(),
      implementationContent: File(youtubeImplPath).readAsStringSync(),
    ));
  }

  return pairs;
}

/// Generator for service pair indices
extension ServicePairGenerators on Any {
  Generator<int> servicePairIndex(int maxIndex) {
    if (maxIndex <= 0) return always(0);
    return intInRange(0, maxIndex);
  }
}

// ============================================================================
// Property-Based Tests
// ============================================================================

void main() {
  final servicePairs = collectServicePairs();

  group('Property 3: Service API Preservation', () {
    // ========================================================================
    // Property 3.1: Implementation SHALL have all interface methods
    // Validates: Requirements 5.1
    // ========================================================================
    if (servicePairs.isNotEmpty) {
      Glados(any.servicePairIndex(servicePairs.length), ExploreConfig(numRuns: 100))
          .test(
        'For any service, implementation SHALL have all interface methods',
        (index) {
          final pair = servicePairs[index % servicePairs.length];
          final interfaceMethods = pair.interfaceMethods;
          final implMethods = pair.implementationMethods;

          for (final interfaceMethod in interfaceMethods) {
            final hasMethod = implMethods.any((m) => m.name == interfaceMethod.name);
            
            expect(
              hasMethod,
              isTrue,
              reason:
                  'Service ${pair.serviceName} implementation is missing method: ${interfaceMethod.name}',
            );
          }
        },
      );
    }

    // ========================================================================
    // Property 3.2: Method signatures SHALL match between interface and impl
    // Validates: Requirements 5.1
    // ========================================================================
    if (servicePairs.isNotEmpty) {
      Glados(any.servicePairIndex(servicePairs.length), ExploreConfig(numRuns: 100))
          .test(
        'For any service, method signatures SHALL match between interface and implementation',
        (index) {
          final pair = servicePairs[index % servicePairs.length];
          final mismatches = pair.signatureMismatches;

          expect(
            mismatches.isEmpty,
            isTrue,
            reason:
                'Service ${pair.serviceName} has signature mismatches:\n${mismatches.join('\n')}',
          );
        },
      );
    }

    // ========================================================================
    // Property 3.3: All services SHALL preserve their API
    // Validates: Requirements 5.1
    // ========================================================================
    if (servicePairs.isNotEmpty) {
      Glados(any.servicePairIndex(servicePairs.length), ExploreConfig(numRuns: 100))
          .test(
        'For any service, API SHALL be preserved after relocation',
        (index) {
          final pair = servicePairs[index % servicePairs.length];

          expect(
            pair.hasMatchingSignatures,
            isTrue,
            reason:
                'Service ${pair.serviceName} API not preserved:\n${pair.signatureMismatches.join('\n')}',
          );
        },
      );
    }
  });

  // ==========================================================================
  // Comprehensive API Preservation Scan (Unit Tests)
  // ==========================================================================
  group('Service API Preservation - Comprehensive Scan', () {
    test('All service pairs should be found', () {
      expect(
        servicePairs.length,
        equals(2),
        reason: 'Expected to find 2 service pairs (GeminiAIService, YoutubeSearchService)',
      );
    });

    test('GeminiAIService should preserve generateSearchTerms method', () {
      final geminiPair = servicePairs.firstWhere(
        (p) => p.serviceName == 'GeminiAIService',
        orElse: () => throw Exception('GeminiAIService pair not found'),
      );

      final interfaceMethods = geminiPair.interfaceMethods;
      final implMethods = geminiPair.implementationMethods;

      // Check generateSearchTerms exists in both
      expect(
        interfaceMethods.any((m) => m.name == 'generateSearchTerms'),
        isTrue,
        reason: 'GeminiAIService interface should have generateSearchTerms method',
      );

      expect(
        implMethods.any((m) => m.name == 'generateSearchTerms'),
        isTrue,
        reason: 'GeminiAIServiceImpl should have generateSearchTerms method',
      );

      // Check signatures match
      expect(
        geminiPair.hasMatchingSignatures,
        isTrue,
        reason: 'GeminiAIService signatures should match:\n${geminiPair.signatureMismatches.join('\n')}',
      );
    });

    test('YoutubeSearchService should preserve searchVideo method', () {
      final youtubePair = servicePairs.firstWhere(
        (p) => p.serviceName == 'YoutubeSearchService',
        orElse: () => throw Exception('YoutubeSearchService pair not found'),
      );

      final interfaceMethods = youtubePair.interfaceMethods;
      final implMethods = youtubePair.implementationMethods;

      // Check searchVideo exists in both
      expect(
        interfaceMethods.any((m) => m.name == 'searchVideo'),
        isTrue,
        reason: 'YoutubeSearchService interface should have searchVideo method',
      );

      expect(
        implMethods.any((m) => m.name == 'searchVideo'),
        isTrue,
        reason: 'YoutubeSearchServiceImpl should have searchVideo method',
      );

      // Check signatures match
      expect(
        youtubePair.hasMatchingSignatures,
        isTrue,
        reason: 'YoutubeSearchService signatures should match:\n${youtubePair.signatureMismatches.join('\n')}',
      );
    });

    test('All services should have matching signatures', () {
      final violations = <String>[];

      for (final pair in servicePairs) {
        if (!pair.hasMatchingSignatures) {
          violations.add(
              '${pair.serviceName}:\n  ${pair.signatureMismatches.join('\n  ')}');
        }
      }

      expect(
        violations.isEmpty,
        isTrue,
        reason:
            'Found ${violations.length} service(s) with API violations:\n\n${violations.join('\n\n')}',
      );
    });
  });

  // ==========================================================================
  // Edge Cases
  // ==========================================================================
  group('Service API Preservation - Edge Cases', () {
    test('Service pair collection should not throw', () {
      expect(() => collectServicePairs(), returnsNormally);
    });

    test('Service pairs should have non-empty content', () {
      for (final pair in servicePairs) {
        expect(
          pair.interfaceContent.isNotEmpty,
          isTrue,
          reason: '${pair.serviceName} interface content should not be empty',
        );
        expect(
          pair.implementationContent.isNotEmpty,
          isTrue,
          reason: '${pair.serviceName} implementation content should not be empty',
        );
      }
    });

    test('Interface files should contain abstract class', () {
      for (final pair in servicePairs) {
        expect(
          pair.interfaceContent.contains('abstract class'),
          isTrue,
          reason: '${pair.serviceName} interface should be an abstract class',
        );
      }
    });

    test('Implementation files should implement interface', () {
      for (final pair in servicePairs) {
        final interfaceName = pair.serviceName;
        expect(
          pair.implementationContent.contains('implements $interfaceName'),
          isTrue,
          reason: '${pair.serviceName}Impl should implement $interfaceName',
        );
      }
    });
  });
}
