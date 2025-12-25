# Implementation Plan: SRP Clean Architecture Fix

## Overview

This implementation plan refactors the GuardianCare Flutter application to fix Single Responsibility Principle violations. Tasks are organized to build incrementally, with each task building on previous work. Property-based tests validate correctness properties from the design document.

## Tasks

- [x] 1. Set up core infrastructure for SRP refactoring
  - [x] 1.1 Create base Failure classes in `lib/core/error/failures.dart`
    - Add GeminiApiFailure, YoutubeApiFailure, StorageFailure, AuthenticationFailure
    - _Requirements: 4.5, Error Handling_
  - [x] 1.2 Create AuthStateEvent model in `lib/core/models/auth_state_event.dart`
    - Define AuthStateEventType enum and AuthStateEvent class
    - _Requirements: 1.4_

- [x] 2. Extract Main App State responsibilities
  - [x] 2.1 Create AuthStateManager in `lib/core/managers/auth_state_manager.dart`
    - Implement auth state stream management
    - Implement logout notification through events
    - _Requirements: 1.1, 1.4_
  - [x] 2.2 Create LocaleManager in `lib/core/managers/locale_manager.dart`
    - Implement locale change handling
    - Implement saved locale loading
    - _Requirements: 1.2_
  - [x] 2.3 Create AppLifecycleManager in `lib/core/managers/app_lifecycle_manager.dart`
    - Implement lifecycle event handling (pause, detach, resume)
    - Delegate to ParentalVerificationService for reset
    - _Requirements: 1.3_
  - [x] 2.4 Refactor GuardiancareState in `lib/main.dart` to use managers
    - Inject AuthStateManager, LocaleManager, AppLifecycleManager
    - Remove direct auth, locale, and lifecycle handling
    - _Requirements: 1.1, 1.2, 1.3_
  - [x] 2.5 Write property test for Main App State Delegation

    - **Property 1: Main App State Delegation**
    - **Validates: Requirements 1.1, 1.2, 1.3, 1.4**

- [x] 3. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Extract Quiz business logic from presentation
  - [x] 4.1 Add new events to QuizBloc in `lib/features/quiz/presentation/bloc/quiz_event.dart`
    - Add SubmitAnswerRequested, CompleteQuizRequested events
    - _Requirements: 2.1, 2.2_
  - [x] 4.2 Add new states to QuizBloc in `lib/features/quiz/presentation/bloc/quiz_state.dart`
    - Add QuizAnswerValidated, QuizCompleted, RecommendationsGenerating, RecommendationsGenerated states
    - _Requirements: 2.1, 2.2, 2.3_
  - [x] 4.3 Create GenerateRecommendations use case in `lib/features/quiz/domain/usecases/generate_recommendations.dart`
    - Implement use case that delegates to RecommendationRepository
    - _Requirements: 2.3_
  - [x] 4.4 Update QuizBloc in `lib/features/quiz/presentation/bloc/quiz_bloc.dart`
    - Handle SubmitAnswerRequested with validation logic
    - Handle CompleteQuizRequested with repository coordination
    - Delegate recommendation generation to use case
    - _Requirements: 2.1, 2.2, 2.3_
  - [x] 4.5 Refactor QuizQuestionsPage in `lib/features/quiz/presentation/pages/quiz_questions_page.dart`
    - Remove business logic (scoring, Firestore access, recommendation calls)
    - Dispatch events to QuizBloc instead
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  - [x] 4.6 Write property test for Quiz Business Logic Delegation

    - **Property 2: Quiz Business Logic Delegation**
    - **Validates: Requirements 2.1, 2.2, 2.3**

- [x] 5. Extract Video/Learn business logic from presentation
  - [x] 5.1 Add LoadCategories and LoadVideosByCategory events to LearnBloc
    - Update `lib/features/learn/presentation/bloc/learn_event.dart`
    - _Requirements: 3.1, 3.2_
  - [x] 5.2 Add CategoriesLoaded and VideosLoaded states to LearnBloc
    - Update `lib/features/learn/presentation/bloc/learn_state.dart`
    - _Requirements: 3.1, 3.2_
  - [x] 5.3 Update LearnBloc to handle category and video loading
    - Update `lib/features/learn/presentation/bloc/learn_bloc.dart`
    - _Requirements: 3.1, 3.2_
  - [x] 5.4 Refactor VideoPage to use LearnBloc
    - Remove direct Firestore queries from `lib/features/learn/presentation/pages/video_page.dart`
    - Use BlocProvider and dispatch events to LearnBloc
    - _Requirements: 3.1, 3.2, 3.3, 3.4_
  - [x] 5.5 Write property test for Learn Business Logic Delegation

    - **Property 3: Learn Business Logic Delegation**
    - **Validates: Requirements 3.1, 3.2**

- [x] 6. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Decompose RecommendationService
  - [x] 7.1 Create GeminiAIService in `lib/features/quiz/services/gemini_ai_service.dart`
    - Handle Gemini API interactions exclusively
    - Return Either<Failure, List<String>> for search terms
    - No fallback logic - return failure on error
    - _Requirements: 4.1, 4.5_
  - [x] 7.2 Create YoutubeSearchService in `lib/features/quiz/services/youtube_search_service.dart`
    - Handle YouTube API interactions exclusively
    - Return Either<Failure, VideoData>
    - _Requirements: 4.2_
  - [x] 7.3 Create RecommendationRepository in `lib/features/quiz/data/repositories/recommendation_repository.dart`
    - Handle Firestore operations exclusively
    - Implement saveRecommendation, clearUserRecommendations, getUserRecommendations
    - _Requirements: 4.3_
  - [x] 7.4 Create RecommendationUseCase in `lib/features/quiz/domain/usecases/recommendation_use_case.dart`
    - Orchestrate GeminiAIService, YoutubeSearchService, RecommendationRepository
    - No implementation details, only coordination
    - _Requirements: 4.4_
  - [x] 7.5 Update injection_container.dart to register new services
    - Register GeminiAIService, YoutubeSearchService, RecommendationRepository, RecommendationUseCase
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  - [x] 7.6 Remove old RecommendationService and update references
    - Delete `lib/features/quiz/services/recommendation_service.dart`
    - Update QuizBloc to use RecommendationUseCase
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  - [x] 7.7 Write property test for Recommendation Service Decomposition

    - **Property 4: Recommendation Service Decomposition**
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.5**

- [x] 8. Separate Consent Form business logic
  - [x] 8.1 Add ValidateParentalKey and SubmitParentalKey events to ConsentBloc
    - Update `lib/features/consent/presentation/bloc/consent_event.dart`
    - _Requirements: 5.1, 5.2_
  - [x] 8.2 Add ParentalKeyValidated and ParentalKeySubmitted states to ConsentBloc
    - Update `lib/features/consent/presentation/bloc/consent_state.dart`
    - _Requirements: 5.1, 5.2_
  - [x] 8.3 Update ConsentBloc to handle parental key validation and persistence
    - Update `lib/features/consent/presentation/bloc/consent_bloc.dart`
    - _Requirements: 5.1, 5.2_
  - [x] 8.4 Refactor ConsentFormPage to use ConsentBloc
    - Remove direct SharedPreferences access from `lib/features/consent/presentation/pages/consent_form_page.dart`
    - Dispatch events to ConsentBloc instead
    - _Requirements: 5.1, 5.2, 5.3, 5.4_
  - [ ]* 8.5 Write property test for Consent Business Logic Delegation
    - **Property 5: Consent Business Logic Delegation**
    - **Validates: Requirements 5.1, 5.2**

- [x] 9. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Separate Account Page responsibilities
  - [x] 10.1 Add ChangeLanguageRequested and LogoutRequested events to ProfileBloc
    - Update `lib/features/profile/presentation/bloc/profile_event.dart`
    - _Requirements: 6.1, 6.3_
  - [x] 10.2 Add LanguageChanged and LoggedOut states to ProfileBloc
    - Update `lib/features/profile/presentation/bloc/profile_state.dart`
    - _Requirements: 6.1, 6.3_
  - [x] 10.3 Update ProfileBloc to delegate to LocaleService and AuthRepository
    - Update `lib/features/profile/presentation/bloc/profile_bloc.dart`
    - _Requirements: 6.1, 6.2, 6.3_
  - [x] 10.4 Refactor AccountPage to dispatch events to ProfileBloc
    - Remove direct locale change and logout logic from `lib/features/profile/presentation/pages/account_page.dart`
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  - [ ]* 10.5 Write property test for Profile Business Logic Delegation
    - **Property 6: Profile Business Logic Delegation**
    - **Validates: Requirements 6.1, 6.2, 6.3**

- [x] 11. Extract Authentication Guard from Router
  - [x] 11.1 Create AuthGuard in `lib/core/routing/auth_guard.dart`
    - Implement redirect logic for authentication checks
    - Implement isAuthenticated and isPublicRoute methods
    - _Requirements: 7.1, 7.2_
  - [x] 11.2 Refactor AppRouter to use AuthGuard
    - Remove inline redirect logic from `lib/core/routing/app_router.dart`
    - Delegate to AuthGuard for authentication checks
    - _Requirements: 7.1, 7.2, 7.3_
  - [x] 11.3 Write property test for Auth Guard Encapsulation

    - **Property 7: Auth Guard Encapsulation**
    - **Validates: Requirements 7.1, 7.2**

- [x] 12. Decompose StorageManager
  - [x] 12.1 Create PreferencesStorageService in `lib/core/database/preferences_storage_service.dart`
    - Handle SharedPreferences operations exclusively
    - _Requirements: 8.1_
  - [x] 12.2 Create HiveStorageService in `lib/core/database/hive_storage_service.dart`
    - Handle Hive operations exclusively
    - _Requirements: 8.2_
  - [x] 12.3 Create SQLiteStorageService in `lib/core/database/sqlite_storage_service.dart`
    - Handle SQLite operations exclusively
    - _Requirements: 8.3_
  - [x] 12.4 Refactor StorageManager to coordinate services
    - Update `lib/core/database/storage_manager.dart` to delegate to services
    - Remove direct implementation details
    - _Requirements: 8.1, 8.2, 8.3, 8.4_
  - [ ]* 12.5 Write property test for Storage Service Separation
    - **Property 8: Storage Service Separation**
    - **Validates: Requirements 8.1, 8.2, 8.3**

- [x] 13. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 14. Decompose ParentalVerificationService
  - [x] 14.1 Create CryptoService in `lib/core/services/crypto_service.dart`
    - Handle cryptographic operations exclusively (hashString, compareHash)
    - _Requirements: 9.3_
  - [x] 14.2 Create ParentalSessionManager in `lib/core/services/parental_session_manager.dart`
    - Handle session state management exclusively
    - _Requirements: 9.1_
  - [x] 14.3 Create ParentalKeyVerifier in `lib/core/services/parental_key_verifier.dart`
    - Handle verification logic exclusively
    - Use CryptoService for hashing
    - _Requirements: 9.2_
  - [x] 14.4 Refactor ParentalVerificationService to orchestrate services
    - Update `lib/core/services/parental_verification_service.dart` to delegate
    - Remove direct implementation details
    - _Requirements: 9.1, 9.2, 9.3, 9.4_
  - [x] 14.5 Write property test for Parental Verification Decomposition

    - **Property 9: Parental Verification Decomposition**
    - **Validates: Requirements 9.1, 9.2, 9.3**

- [x] 15. Extract complex UI building to widgets
  - [x] 15.1 Create EmergencyContactCard widget in `lib/features/emergency/presentation/widgets/emergency_contact_card.dart`
    - Extract card rendering logic from EmergencyContactPage
    - _Requirements: 10.1_
  - [x] 15.2 Refactor EmergencyContactPage to use EmergencyContactCard
    - Update `lib/features/emergency/presentation/pages/emergency_contact_page.dart`
    - _Requirements: 10.1, 10.3_
  - [x] 15.3 Create TermsAndConditionsDialog widget in `lib/features/authentication/presentation/widgets/terms_and_conditions_dialog.dart`
    - Extract dialog rendering logic
    - _Requirements: 10.2_
  - [x] 15.4 Refactor LoginPage to use TermsAndConditionsDialog
    - Update `lib/features/authentication/presentation/pages/login_page.dart`
    - _Requirements: 10.2, 10.4_

- [x] 16. Update dependency injection
  - [x] 16.1 Register all new managers in injection_container.dart
    - Register AuthStateManager, LocaleManager, AppLifecycleManager
    - _Requirements: 1.1, 1.2, 1.3_
  - [x] 16.2 Register all new services in injection_container.dart
    - Register CryptoService, ParentalSessionManager, ParentalKeyVerifier
    - Register PreferencesStorageService, HiveStorageService, SQLiteStorageService
    - _Requirements: 8.1, 8.2, 8.3, 9.1, 9.2, 9.3_
  - [x] 16.3 Update existing registrations to use new dependencies
    - Update BLoC registrations to inject new use cases and services
    - _Requirements: All_

- [x] 17. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
  - Verify no direct Firestore/SharedPreferences access in presentation layer
  - Verify all business logic is in BLoCs/Use Cases

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- The implementation follows Clean Architecture layer boundaries
