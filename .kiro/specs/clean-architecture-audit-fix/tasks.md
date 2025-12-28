# Implementation Plan: Clean Architecture Audit Fix

## Overview

This implementation plan addresses clean architecture violations in the GuardianCare Flutter application by relocating misplaced services to their correct layers and adding missing data layer components to the video_player feature.

## Tasks

- [x] 1. Create domain layer service interfaces for quiz feature
  - [x] 1.1 Create `lib/features/quiz/domain/services/` directory structure
    - Create the services directory in domain layer
    - Create barrel file `services.dart`
    - _Requirements: 1.3, 2.1_

  - [x] 1.2 Extract GeminiAIService abstract interface
    - Create `gemini_ai_service.dart` with abstract class
    - Define `generateSearchTerms` method signature
    - Include proper documentation
    - _Requirements: 1.3, 2.2_

  - [x] 1.3 Extract YoutubeSearchService abstract interface
    - Create `youtube_search_service.dart` with abstract class and VideoData entity
    - Define `searchVideo` method signature
    - Include proper documentation
    - _Requirements: 1.3, 2.2_

  - [x] 1.4 Update domain barrel file to export services
    - Update `lib/features/quiz/domain/domain.dart` to export services
    - _Requirements: 6.2_

- [x] 2. Relocate service implementations to data layer
  - [x] 2.1 Create `lib/features/quiz/data/services/` directory structure
    - Create the services directory in data layer
    - Create barrel file `services.dart`
    - _Requirements: 1.1, 1.2_

  - [x] 2.2 Move GeminiAIService implementation to data layer
    - Create `gemini_ai_service_impl.dart` in data/services
    - Update class to implement domain interface
    - Update imports to reference domain interface
    - _Requirements: 1.1, 5.1_

  - [x] 2.3 Move YoutubeSearchService implementation to data layer
    - Create `youtube_search_service_impl.dart` in data/services
    - Update class to implement domain interface
    - Update imports to reference domain interface
    - _Requirements: 1.2, 5.1_

  - [x] 2.4 Update data barrel file to export services
    - Update `lib/features/quiz/data/data.dart` to export services
    - _Requirements: 6.1_

- [x] 3. Update domain layer use case imports
  - [x] 3.1 Update RecommendationUseCase imports
    - Change imports from `services/` to `domain/services/`
    - Ensure use case depends only on abstract interfaces
    - _Requirements: 2.3, 2.4_

  - [x] 3.2 Write property test for domain layer purity

    - **Property 1: Domain Layer Purity**
    - Verify domain files don't import from data layer or old services folder
    - **Validates: Requirements 1.3, 2.1, 2.2, 2.4, 6.2**

- [x] 4. Update dependency injection container
  - [x] 4.1 Update service imports in injection_container.dart
    - Import abstract interfaces from domain layer
    - Import concrete implementations from data layer
    - _Requirements: 4.1, 4.2_

  - [x] 4.2 Update service registrations
    - Register `GeminiAIService` interface with `GeminiAIServiceImpl`
    - Register `YoutubeSearchService` interface with `YoutubeSearchServiceImpl`
    - _Requirements: 4.3_

  - [x] 4.3 Write property test for import path correctness

    - **Property 2: Import Path Correctness**
    - Verify no imports reference old services folder
    - **Validates: Requirements 1.5, 4.4**

- [x] 5. Add video_player data layer structure
  - [x] 5.1 Create data layer directory structure
    - Create `lib/features/video_player/data/` directory
    - Create `datasources/`, `models/`, `repositories/` subdirectories
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [x] 5.2 Create data layer barrel files
    - Create `data.dart` barrel file
    - Create `datasources/datasources.dart` barrel file
    - Create `models/models.dart` barrel file
    - Create `repositories/repositories.dart` barrel file
    - _Requirements: 3.1_

  - [x] 5.3 Update video_player feature barrel file
    - Update `lib/features/video_player/video_player.dart` to export data layer
    - _Requirements: 3.1_

- [x] 6. Cleanup and verification
  - [x] 6.1 Remove old services folder
    - Delete `lib/features/quiz/services/` directory and all contents
    - _Requirements: 1.4_

  - [x] 6.2 Update quiz feature barrel file
    - Update `lib/features/quiz/quiz.dart` to remove old services export
    - Ensure proper exports from domain and data layers
    - _Requirements: 6.1, 6.3_

  - [x] 6.3 Write property test for service API preservation

    - **Property 3: Service API Preservation**
    - Verify relocated services maintain identical method signatures
    - **Validates: Requirements 5.1**

- [x] 7. Final checkpoint - Ensure all tests pass
  - Run `flutter analyze` to verify no import errors
  - Run existing tests to verify functionality preserved
  - Ensure all tests pass, ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- The refactoring is purely structural - no business logic changes
