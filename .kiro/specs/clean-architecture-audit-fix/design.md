# Design Document: Clean Architecture Audit Fix

## Overview

This design document outlines the architectural changes required to fix clean architecture violations in the GuardianCare Flutter application. The primary focus is on relocating misplaced services to their correct layers, adding missing data layer components, and ensuring proper dependency flow throughout the codebase.

## Architecture

The refactoring follows the standard Clean Architecture pattern with three main layers:

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (Pages, Widgets, BLoC/Cubit - Depends on Domain only)  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│                     Domain Layer                         │
│  (Entities, Use Cases, Repository/Service Interfaces)   │
│  (No dependencies - Pure business logic)                │
└────────────────────┬────────────────────────────────────┘
                     ↑
                     │ implements
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  (Models, Repository Impl, Data Sources, Services)      │
│  (Depends on Domain + Core)                             │
└─────────────────────────────────────────────────────────┘
```

### Key Architectural Principles

1. **Dependency Rule**: Dependencies point inward only. Domain layer has no external dependencies.
2. **Interface Segregation**: Domain defines abstract interfaces; Data provides implementations.
3. **Single Responsibility**: Each service handles one specific external integration.

## Components and Interfaces

### Quiz Feature Service Relocation

#### Current Structure (Violation)
```
lib/features/quiz/
├── data/
├── domain/
│   └── usecases/
│       └── recommendation_use_case.dart  # Imports concrete services!
├── presentation/
└── services/                              # VIOLATION: Outside layers
    ├── gemini_ai_service.dart
    ├── youtube_search_service.dart
    └── services.dart
```

#### Target Structure (Compliant)
```
lib/features/quiz/
├── data/
│   ├── datasources/
│   ├── models/
│   ├── repositories/
│   └── services/                          # Concrete implementations
│       ├── gemini_ai_service_impl.dart
│       ├── youtube_search_service_impl.dart
│       └── services.dart
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── services/                          # Abstract interfaces
│   │   ├── gemini_ai_service.dart
│   │   ├── youtube_search_service.dart
│   │   └── services.dart
│   └── usecases/
└── presentation/
```

### Service Interface Definitions

#### GeminiAIService Interface (Domain Layer)

```dart
// lib/features/quiz/domain/services/gemini_ai_service.dart
import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';

/// Abstract interface for Gemini AI service operations
/// 
/// This interface defines the contract for generating search terms
/// using AI. The domain layer depends only on this abstraction.
abstract class GeminiAIService {
  /// Generates YouTube search terms for a given category
  /// 
  /// Returns [Either<Failure, List<String>>] containing:
  /// - [Right] with list of search terms on success
  /// - [Left] with [Failure] on error
  Future<Either<Failure, List<String>>> generateSearchTerms(String category);
}
```

#### YoutubeSearchService Interface (Domain Layer)

```dart
// lib/features/quiz/domain/services/youtube_search_service.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';

/// Data class representing video information
class VideoData extends Equatable {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;

  const VideoData({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  @override
  List<Object> get props => [videoId, title, thumbnailUrl, videoUrl];
}

/// Abstract interface for YouTube search operations
abstract class YoutubeSearchService {
  /// Searches for a video on YouTube using the given search term
  Future<Either<Failure, VideoData>> searchVideo(String term);
}
```

### Video Player Data Layer Structure

#### Target Structure
```
lib/features/video_player/
├── data/
│   ├── datasources/
│   │   ├── video_player_local_datasource.dart
│   │   └── datasources.dart
│   ├── models/
│   │   ├── video_model.dart
│   │   └── models.dart
│   ├── repositories/
│   │   ├── video_player_repository_impl.dart
│   │   └── repositories.dart
│   └── data.dart
├── domain/
│   ├── entities/
│   ├── repositories/
│   │   ├── video_player_repository.dart
│   │   └── repositories.dart
│   └── usecases/
└── presentation/
```

### Dependency Injection Updates

```dart
// Updated injection for quiz services
void _initQuizFeature() {
  // Services - Abstract interfaces bound to concrete implementations
  sl.registerLazySingleton<GeminiAIService>(
    () => GeminiAIServiceImpl(),  // Import from data layer
  );
  
  sl.registerLazySingleton<YoutubeSearchService>(
    () => YoutubeSearchServiceImpl(),  // Import from data layer
  );

  // Use cases - Depend on abstract interfaces
  sl.registerLazySingleton(() => RecommendationUseCase(
    geminiService: sl<GeminiAIService>(),
    youtubeService: sl<YoutubeSearchService>(),
    repository: sl<RecommendationRepository>(),
  ));
}
```

## Data Models

### VideoData Model (Domain Entity)

The `VideoData` class represents video information and is used across layers. It should remain in the domain layer as it's a pure data class with no external dependencies.

```dart
class VideoData extends Equatable {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;

  const VideoData({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  @override
  List<Object> get props => [videoId, title, thumbnailUrl, videoUrl];
}
```

### Video Player Model (Data Layer)

```dart
// lib/features/video_player/data/models/video_model.dart
import 'package:guardiancare/features/video_player/domain/entities/video_entity.dart';

class VideoModel {
  final String id;
  final String url;
  final String title;
  final Duration? lastPosition;
  final double playbackSpeed;

  const VideoModel({
    required this.id,
    required this.url,
    required this.title,
    this.lastPosition,
    this.playbackSpeed = 1.0,
  });

  VideoEntity toEntity() => VideoEntity(
    id: id,
    url: url,
    title: title,
  );

  factory VideoModel.fromEntity(VideoEntity entity) => VideoModel(
    id: entity.id ?? '',
    url: entity.url,
    title: entity.title,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'title': title,
    'lastPosition': lastPosition?.inMilliseconds,
    'playbackSpeed': playbackSpeed,
  };

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
    id: json['id'] as String,
    url: json['url'] as String,
    title: json['title'] as String,
    lastPosition: json['lastPosition'] != null 
        ? Duration(milliseconds: json['lastPosition'] as int)
        : null,
    playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
  );
}
```



## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, the following correctness properties have been identified:

### Property 1: Domain Layer Purity

*For any* Dart file in the domain layer (`lib/features/*/domain/**/*.dart`), the file SHALL NOT contain imports from the data layer (`lib/features/*/data/`) or the old services folder (`lib/features/*/services/`), AND if the file defines a service interface, it SHALL be an abstract class.

**Validates: Requirements 1.3, 2.1, 2.2, 2.4, 6.2**

### Property 2: Import Path Correctness

*For any* Dart file in the codebase that imports quiz services, the import path SHALL reference either the domain layer abstract interface (`lib/features/quiz/domain/services/`) or the data layer implementation (`lib/features/quiz/data/services/`), and SHALL NOT reference the old services folder (`lib/features/quiz/services/`).

**Validates: Requirements 1.5, 4.4**

### Property 3: Service API Preservation

*For any* public method defined in the original service implementations (`GeminiAIService`, `YoutubeSearchService`), the relocated service implementations SHALL maintain the identical method signature (name, parameters, return type).

**Validates: Requirements 5.1**

## Error Handling

### Migration Errors

1. **Import Resolution Failures**
   - If imports cannot be resolved after migration, the analyzer will report errors
   - Resolution: Verify all import paths are updated correctly

2. **Type Mismatch Errors**
   - If concrete types are used where abstract types are expected
   - Resolution: Ensure dependency injection registers abstract interfaces

3. **Missing Implementation Errors**
   - If abstract interfaces are not fully implemented
   - Resolution: Verify all abstract methods are implemented in concrete classes

### Runtime Errors

The refactoring should not introduce new runtime errors as it's purely structural. All existing error handling in services remains unchanged.

## Testing Strategy

### Dual Testing Approach

This refactoring requires both unit tests and property-based tests to ensure correctness:

#### Unit Tests
- Verify specific file locations after migration
- Test that barrel files export correct modules
- Verify dependency injection resolves correctly

#### Property-Based Tests
- Verify domain layer purity across all domain files
- Verify import path correctness across all Dart files
- Verify service API preservation

### Property-Based Testing Configuration

- **Library**: `glados` (Dart property-based testing library)
- **Minimum iterations**: 100 per property test
- **Tag format**: `Feature: clean-architecture-audit-fix, Property {number}: {property_text}`

### Test File Structure

```
test/
├── features/
│   └── quiz/
│       └── architecture/
│           ├── domain_layer_purity_test.dart
│           ├── import_path_correctness_test.dart
│           └── service_api_preservation_test.dart
└── integration/
    └── clean_architecture_compliance_test.dart
```

### Example Property Test

```dart
// test/features/quiz/architecture/domain_layer_purity_test.dart
import 'dart:io';
import 'package:glados/glados.dart';
import 'package:test/test.dart';

/// **Feature: clean-architecture-audit-fix, Property 1: Domain Layer Purity**
/// **Validates: Requirements 1.3, 2.1, 2.2, 2.4, 6.2**
void main() {
  group('Domain Layer Purity', () {
    test('domain layer files should not import from data layer', () {
      final domainDir = Directory('lib/features/quiz/domain');
      final dartFiles = domainDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');
        
        for (final line in lines) {
          if (line.startsWith('import')) {
            expect(
              line.contains('/data/') || line.contains('/services/'),
              isFalse,
              reason: 'File ${file.path} imports from data layer: $line',
            );
          }
        }
      }
    });
  });
}
```

## Migration Steps

### Phase 1: Create Domain Layer Interfaces

1. Create `lib/features/quiz/domain/services/` directory
2. Extract abstract interfaces from existing services
3. Move `VideoData` class to domain services (it's a pure data class)

### Phase 2: Relocate Service Implementations

1. Create `lib/features/quiz/data/services/` directory
2. Move concrete implementations to data layer
3. Rename files to `*_impl.dart` convention
4. Update implementations to import interfaces from domain

### Phase 3: Update Imports and Dependencies

1. Update `RecommendationUseCase` to import from domain layer
2. Update `injection_container.dart` to import from correct locations
3. Update barrel files (`quiz.dart`, `domain.dart`, `data.dart`)

### Phase 4: Add Video Player Data Layer

1. Create directory structure under `lib/features/video_player/data/`
2. Add placeholder files for future data layer needs
3. Update barrel files

### Phase 5: Cleanup

1. Remove old `lib/features/quiz/services/` directory
2. Run analyzer to verify no import errors
3. Run existing tests to verify functionality preserved

## File Changes Summary

### New Files
- `lib/features/quiz/domain/services/gemini_ai_service.dart` (interface)
- `lib/features/quiz/domain/services/youtube_search_service.dart` (interface)
- `lib/features/quiz/domain/services/services.dart` (barrel)
- `lib/features/quiz/data/services/gemini_ai_service_impl.dart`
- `lib/features/quiz/data/services/youtube_search_service_impl.dart`
- `lib/features/quiz/data/services/services.dart` (barrel)
- `lib/features/video_player/data/data.dart`
- `lib/features/video_player/data/datasources/datasources.dart`
- `lib/features/video_player/data/models/models.dart`
- `lib/features/video_player/data/repositories/repositories.dart`

### Modified Files
- `lib/features/quiz/domain/usecases/recommendation_use_case.dart`
- `lib/features/quiz/domain/domain.dart`
- `lib/features/quiz/data/data.dart`
- `lib/features/quiz/quiz.dart`
- `lib/core/di/injection_container.dart`
- `lib/features/video_player/video_player.dart`

### Deleted Files
- `lib/features/quiz/services/gemini_ai_service.dart`
- `lib/features/quiz/services/youtube_search_service.dart`
- `lib/features/quiz/services/services.dart`
