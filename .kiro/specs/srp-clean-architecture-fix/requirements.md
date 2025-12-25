# Requirements Document

## Introduction

This specification addresses Single Responsibility Principle (SRP) violations identified throughout the GuardianCare Flutter application. The violations span across presentation, business logic, and data layers, compromising the Clean Architecture principles. This refactoring will ensure each class has exactly one reason to change, improving maintainability, testability, and code organization.

## Glossary

- **SRP**: Single Responsibility Principle - a class should have only one reason to change
- **BLoC**: Business Logic Component - pattern for separating business logic from UI
- **Repository**: Data access abstraction layer
- **Use_Case**: Single business operation encapsulation
- **Data_Source**: Direct data access implementation (Firebase, SQLite, etc.)
- **Presentation_Layer**: UI components (Pages, Widgets)
- **Domain_Layer**: Business logic (BLoCs, Use Cases, Entities)
- **Data_Layer**: Data access (Repositories, Data Sources, Models)

## Requirements

### Requirement 1: Separate Main App State Responsibilities

**User Story:** As a developer, I want the main app state to have single responsibilities, so that authentication, localization, and lifecycle management can be modified independently.

#### Acceptance Criteria

1. WHEN the application initializes THEN the GuardiancareState SHALL delegate authentication state management to a dedicated AuthStateManager
2. WHEN locale changes are requested THEN the System SHALL delegate to a dedicated LocaleManager service
3. WHEN app lifecycle events occur THEN the System SHALL delegate to a dedicated AppLifecycleManager
4. WHEN user logs out THEN the AuthStateManager SHALL notify dependent services through events rather than direct coupling

### Requirement 2: Extract Quiz Business Logic from Presentation

**User Story:** As a developer, I want quiz business logic separated from UI, so that quiz functionality can be tested and modified without affecting the presentation layer.

#### Acceptance Criteria

1. WHEN a quiz answer is submitted THEN the QuizBloc SHALL handle validation and scoring logic
2. WHEN quiz completion occurs THEN the QuizBloc SHALL coordinate with the Repository to persist results
3. WHEN recommendations need generation THEN the QuizBloc SHALL delegate to a dedicated RecommendationUseCase
4. THE QuizQuestionsPage SHALL only render UI and dispatch events to the QuizBloc
5. THE QuizPage SHALL fetch data through QuizBloc instead of direct Firestore access

### Requirement 3: Extract Video/Learn Business Logic from Presentation

**User Story:** As a developer, I want video/learn business logic separated from UI, so that content fetching can be tested independently.

#### Acceptance Criteria

1. WHEN video categories are requested THEN the LearnBloc SHALL fetch data through LearnRepository
2. WHEN videos for a category are requested THEN the LearnBloc SHALL fetch data through LearnRepository
3. THE VideoPage SHALL only render UI and dispatch events to the LearnBloc
4. THE VideoPage SHALL NOT contain direct Firestore queries

### Requirement 4: Decompose RecommendationService

**User Story:** As a developer, I want recommendation generation split into focused services, so that AI, YouTube, and persistence concerns can evolve independently.

#### Acceptance Criteria

1. WHEN AI-generated search terms are needed THEN the GeminiAIService SHALL handle Gemini API interactions exclusively
2. WHEN YouTube videos are searched THEN the YoutubeSearchService SHALL handle YouTube API interactions exclusively
3. WHEN recommendations are persisted THEN the RecommendationRepository SHALL handle Firestore operations exclusively
4. THE RecommendationUseCase SHALL orchestrate the services without containing implementation details
5. IF Gemini API fails THEN the GeminiAIService SHALL return a failure result without fallback logic

### Requirement 5: Separate Consent Form Business Logic

**User Story:** As a developer, I want consent form logic separated from UI, so that parental key validation can be tested independently.

#### Acceptance Criteria

1. WHEN parental key is submitted THEN the ConsentBloc SHALL handle validation logic
2. WHEN parental key needs persistence THEN the ConsentBloc SHALL delegate to ConsentRepository
3. THE ConsentFormPage SHALL only render UI and dispatch events to the ConsentBloc
4. THE ConsentFormPage SHALL NOT contain direct SharedPreferences access

### Requirement 6: Separate Account Page Responsibilities

**User Story:** As a developer, I want account page functionality split into focused components, so that profile, language, and account operations can be modified independently.

#### Acceptance Criteria

1. WHEN language change is requested THEN the ProfileBloc SHALL delegate to LocaleService
2. WHEN account deletion is requested THEN the ProfileBloc SHALL delegate to AccountDeletionUseCase
3. WHEN logout is requested THEN the ProfileBloc SHALL delegate to AuthRepository
4. THE AccountPage SHALL only render UI and dispatch events to the ProfileBloc

### Requirement 7: Extract Authentication Guard from Router

**User Story:** As a developer, I want authentication redirect logic separated from route definitions, so that routing and auth can be modified independently.

#### Acceptance Criteria

1. WHEN route redirect is evaluated THEN the AppRouter SHALL delegate to AuthGuard for authentication checks
2. THE AuthGuard SHALL encapsulate all authentication redirect logic
3. THE AppRouter SHALL only define route configurations without business logic

### Requirement 8: Decompose StorageManager

**User Story:** As a developer, I want storage backends managed by dedicated services, so that each storage solution can be modified independently.

#### Acceptance Criteria

1. WHEN SharedPreferences operations are needed THEN the PreferencesStorageService SHALL handle them exclusively
2. WHEN Hive operations are needed THEN the HiveStorageService SHALL handle them exclusively
3. WHEN SQLite operations are needed THEN the SQLiteStorageService SHALL handle them exclusively
4. THE StorageManager SHALL only coordinate between storage services without containing implementation details

### Requirement 9: Separate ParentalVerificationService Concerns

**User Story:** As a developer, I want parental verification split into focused services, so that session state, verification, and cryptography can be modified independently.

#### Acceptance Criteria

1. WHEN session verification state is checked THEN the ParentalSessionManager SHALL manage session state exclusively
2. WHEN parental key verification is performed THEN the ParentalKeyVerifier SHALL handle verification logic exclusively
3. WHEN string hashing is needed THEN the CryptoService SHALL handle cryptographic operations exclusively
4. THE ParentalVerificationService SHALL orchestrate these services without containing implementation details

### Requirement 10: Extract Complex UI Building to Widgets

**User Story:** As a developer, I want complex UI building logic extracted to dedicated widgets, so that pages remain focused on composition.

#### Acceptance Criteria

1. WHEN emergency contact cards are displayed THEN the EmergencyContactCard widget SHALL handle card rendering
2. WHEN terms dialogs are shown THEN the TermsAndConditionsDialog widget SHALL handle dialog rendering
3. THE EmergencyContactPage SHALL compose widgets without containing complex build logic
4. THE LoginPage SHALL compose widgets without containing dialog logic
