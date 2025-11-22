# Clean Architecture Migration Tasks

## Phase 1: Core Setup ✅

- [x] 1.1 Add required dependencies (dartz, get_it, equatable)
  - _Requirements: Core infrastructure for Clean Architecture_
- [x] 1.2 Create core error handling (failures, exceptions)
  - _Requirements: Proper error handling across layers_
- [x] 1.3 Create base UseCase class
  - _Requirements: Standardized business logic execution_
- [x] 1.4 Create dependency injection container
  - _Requirements: Centralized dependency management_
- [x] 1.5 Create network info interface
  - _Requirements: Network connectivity checking_
- [x] 1.6 Create documentation
  - _Requirements: Team enablement and knowledge sharing_

## Phase 2: Feature Migration - Authentication (Priority 1) ✅

- [x] 2.1 Create Authentication Domain Layer
  - [x] 2.1.1 Create UserEntity
  - [x] 2.1.2 Create AuthRepository interface
  - [x] 2.1.3 Create SignInWithEmail use case
  - [x] 2.1.4 Create SignUpWithEmail use case
  - [x] 2.1.5 Create SignInWithGoogle use case
  - [x] 2.1.6 Create SignOut use case
  - [x] 2.1.7 Create GetCurrentUser use case
  - [x] 2.1.8 Create SendPasswordResetEmail use case
  - _Requirements: Business logic for user authentication_

- [x] 2.2 Create Authentication Data Layer
  - [x] 2.2.1 Create UserModel extending UserEntity
  - [x] 2.2.2 Create AuthRemoteDataSource interface and implementation
  - [x] 2.2.3 Implement AuthRepositoryImpl with Firebase integration
  - _Requirements: Data persistence and Firebase integration_

- [x] 2.3 Create Authentication Presentation Layer
  - [x] 2.3.1 Create AuthBloc with state management
  - [x] 2.3.2 Create AuthEvent classes
  - [x] 2.3.3 Create AuthState classes
  - _Requirements: UI state management_

- [x] 2.4 Migrate Authentication UI to use Clean Architecture
  - [x] 2.4.1 Update login_page.dart to use AuthBloc instead of direct Firebase calls
    - Replace FirebaseAuth calls with AuthBloc events
    - Add BlocProvider and BlocConsumer
    - Handle AuthLoading, AuthAuthenticated, AuthError states
    - _Requirements: Decouple UI from Firebase, use BLoC pattern_
  - [x] 2.4.2 Create or update signup page to use AuthBloc
    - Implement role selection UI
    - Add form validation
    - Use SignUpWithEmailRequested event
    - _Requirements: User registration with role selection_
  - [x] 2.4.3 Update password reset functionality to use AuthBloc
    - Use PasswordResetRequested event
    - Handle PasswordResetEmailSent state
    - _Requirements: Password recovery functionality_

- [x] 2.5 Register Authentication dependencies in DI container
  - _Requirements: Enable dependency injection for authentication_

- [x] 2.6 Initialize DI in main.dart
  - _Requirements: Bootstrap dependency injection_

- [ ]* 2.7 Write Authentication tests
  - [ ]* 2.7.1 Complete sign_in_with_email_test.dart
  - [ ]* 2.7.2 Write tests for remaining use cases (sign_up, sign_out, etc.)
  - [ ]* 2.7.3 Write auth_repository_impl_test.dart
  - [ ]* 2.7.4 Write auth_bloc_test.dart
  - [ ]* 2.7.5 Write user_model_test.dart
  - _Requirements: Ensure authentication logic is tested_

## Phase 3: Feature Migration - Forum (Priority 2) ✅

- [x] 3.1 Create Forum Domain Layer
  - [x] 3.1.1 Create ForumEntity
  - [x] 3.1.2 Create CommentEntity
  - [x] 3.1.3 Create UserDetailsEntity
  - [x] 3.1.4 Create ForumRepository interface
  - [x] 3.1.5 Create GetForums use case
  - [x] 3.1.6 Create GetComments use case
  - [x] 3.1.7 Create AddComment use case
  - [x] 3.1.8 Create GetUserDetails use case
  - _Requirements: Business logic for forum functionality_

- [x] 3.2 Create Forum Data Layer
  - [x] 3.2.1 Create ForumModel extending ForumEntity
  - [x] 3.2.2 Create CommentModel extending CommentEntity
  - [x] 3.2.3 Create UserDetailsModel extending UserDetailsEntity
  - [x] 3.2.4 Create ForumRemoteDataSource interface and implementation
  - [x] 3.2.5 Implement ForumRepositoryImpl with Firebase Firestore
  - _Requirements: Real-time forum data from Firestore_

- [x] 3.3 Create Forum Presentation Layer
  - [x] 3.3.1 Create ForumBloc with state management
  - [x] 3.3.2 Create ForumEvent classes
  - [x] 3.3.3 Create ForumState classes
  - [x] 3.3.4 Create forum_page_example.dart as reference
  - _Requirements: UI state management for forums_

- [x] 3.4 Migrate Forum UI to use Clean Architecture
  - [x] 3.4.1 Update forum_page.dart to use ForumBloc
    - Replace ForumService with ForumBloc
    - Add BlocProvider and BlocBuilder
    - Handle ForumLoading, ForumsLoaded, ForumError states
    - Implement category switching with LoadForums event
    - _Requirements: Display forums by category with real-time updates_
  - [x] 3.4.2 Update forum_detail_page.dart to use ForumBloc
    - Replace ForumService with ForumBloc
    - Use LoadComments event
    - Handle CommentsLoaded state
    - Use SubmitComment event for new comments
    - _Requirements: Display and submit forum comments_
  - [x] 3.4.3 Update comment_input_bloc.dart widget to use ForumBloc
    - Replace direct service calls with ForumBloc events
    - Handle CommentSubmitting and CommentSubmitted states
    - _Requirements: Comment submission with validation_
  - [x] 3.4.4 Update forum widgets to use new entities
    - Update forum_widget.dart to use ForumEntity
    - Update user_details.dart to use UserDetailsEntity
    - _Requirements: Consistent data models across UI_

- [x] 3.5 Register Forum dependencies in DI container
  - _Requirements: Enable dependency injection for forum_

- [ ]* 3.6 Write Forum tests
  - [ ]* 3.6.1 Write get_forums_test.dart
  - [ ]* 3.6.2 Write get_comments_test.dart
  - [ ]* 3.6.3 Write add_comment_test.dart
  - [ ]* 3.6.4 Write forum_repository_impl_test.dart
  - [ ]* 3.6.5 Write forum_bloc_test.dart
  - [ ]* 3.6.6 Write model tests (forum_model, comment_model, user_details_model)
  - _Requirements: Ensure forum logic is tested_

## Phase 4: Feature Migration - Home (Priority 3)

- [x] 4.1 Analyze Home feature implementation
  - [x] 4.1.1 Review lib/src/features/home/ directory structure
  - [x] 4.1.2 Identify data sources (Firebase collections, local storage)
  - [x] 4.1.3 Document current HomeController functionality
  - [x] 4.1.4 List required entities (e.g., DashboardData, QuickAction)
  - [x] 4.1.5 List required use cases (e.g., GetDashboardData, GetQuickActions)
  - _Requirements: Understand current implementation before migration_

- [x] 4.2 Create Home Domain Layer
  - [x] 4.2.1 Create entities based on analysis
  - [x] 4.2.2 Create HomeRepository interface
  - [x] 4.2.3 Create use cases for home functionality
  - _Requirements: Business logic for home dashboard_

- [x] 4.3 Create Home Data Layer
  - [x] 4.3.1 Create models extending entities
  - [x] 4.3.2 Create HomeRemoteDataSource
  - [x] 4.3.3 Implement HomeRepositoryImpl
  - _Requirements: Data access for home dashboard_

- [x] 4.4 Create Home Presentation Layer
  - [x] 4.4.1 Create HomeBloc
  - [x] 4.4.2 Create HomeEvent classes
  - [x] 4.4.3 Create HomeState classes
  - [x] 4.4.4 Migrate home_page.dart to use HomeBloc
  - [x] 4.4.5 Update home widgets (circular_button.dart, home_carousel.dart)
  - _Requirements: Home dashboard UI with BLoC_

- [x] 4.5 Register Home dependencies in DI container
  - _Requirements: Enable dependency injection for home_

- [ ]* 4.6 Write Home tests
  - [ ]* 4.6.1 Write use case tests
  - [ ]* 4.6.2 Write repository tests
  - [ ]* 4.6.3 Write bloc tests
  - _Requirements: Ensure home logic is tested_

## Phase 5: Feature Migration - Profile (Priority 4) ✅

- [x] 5.1 Analyze Profile feature implementation
  - [x] 5.1.1 Review lib/src/features/profile/ directory
  - [x] 5.1.2 Identify data sources and current functionality
  - [x] 5.1.3 List required entities and use cases
  - _Requirements: Understand profile management needs_

- [x] 5.2 Create Profile Domain Layer
  - [x] 5.2.1 Create ProfileEntity
  - [x] 5.2.2 Create ProfileRepository interface
  - [x] 5.2.3 Create use cases (GetProfile, UpdateProfile, DeleteAccount, ClearUserPreferences)
  - _Requirements: Business logic for user profile_

- [x] 5.3 Create Profile Data Layer
  - [x] 5.3.1 Create ProfileModel
  - [x] 5.3.2 Create ProfileRemoteDataSource
  - [x] 5.3.3 Implement ProfileRepositoryImpl
  - _Requirements: Profile data persistence_

- [x] 5.4 Create Profile Presentation Layer
  - [x] 5.4.1 Create ProfileBloc
  - [x] 5.4.2 Create ProfileEvent and ProfileState classes
  - [x] 5.4.3 Migrate account.dart to use ProfileBloc (created account_page.dart)
  - _Requirements: Profile UI with BLoC_

- [x] 5.5 Register Profile dependencies in DI container
  - _Requirements: Enable dependency injection for profile_

- [ ]* 5.6 Write Profile tests
  - _Requirements: Ensure profile logic is tested_

## Phase 6: Feature Migration - Learn (Priority 5) ✅

- [x] 6.1 Analyze Learn feature implementation
  - [x] 6.1.1 Review lib/src/features/learn/ directory (already has BLoC)
  - [x] 6.1.2 Review existing LearnBloc, LearnRepository
  - [x] 6.1.3 Identify gaps in Clean Architecture compliance
  - [x] 6.1.4 List entities needed (CategoryEntity, VideoEntity)
  - _Requirements: Understand existing BLoC implementation_

- [x] 6.2 Refactor Learn to Clean Architecture
  - [x] 6.2.1 Create proper domain entities (CategoryEntity, VideoEntity)
  - [x] 6.2.2 Create LearnRepository interface in domain layer
  - [x] 6.2.3 Create use cases (GetCategories, GetVideosByCategory, GetVideosStream)
  - [x] 6.2.4 Create data layer with models and datasource
  - [x] 6.2.5 Update LearnBloc to use use cases
  - _Requirements: Align existing BLoC with Clean Architecture_

- [x] 6.3 Register Learn dependencies in DI container
  - _Requirements: Enable dependency injection for learn_

- [ ]* 6.4 Write Learn tests
  - _Requirements: Ensure learn logic is tested_

## Phase 7: Feature Migration - Quiz (Priority 6) ✅

- [x] 7.1 Analyze Quiz feature implementation
  - [x] 7.1.1 Review lib/src/features/quiz/ directory (already has BLoC)
  - [x] 7.1.2 Review existing QuizBloc and services
  - [x] 7.1.3 Identify entities (QuizEntity, QuestionEntity, QuizResultEntity)
  - _Requirements: Understand quiz state management_

- [x] 7.2 Refactor Quiz to Clean Architecture
  - [x] 7.2.1 Create domain entities (QuizEntity, QuestionEntity, QuizResultEntity)
  - [x] 7.2.2 Create QuizRepository interface
  - [x] 7.2.3 Create use cases (GetQuiz, GetQuestions, SubmitQuiz, ValidateQuiz)
  - [x] 7.2.4 Create data layer with models and datasource
  - [x] 7.2.5 Update QuizBloc to use use cases
  - _Requirements: Quiz functionality with Clean Architecture_

- [x] 7.3 Register Quiz dependencies in DI container
  - _Requirements: Enable dependency injection for quiz_

- [ ]* 7.4 Write Quiz tests
  - _Requirements: Ensure quiz logic is tested_

## Phase 8: Feature Migration - Emergency (Priority 7) ✅

- [x] 8.1 Analyze Emergency feature implementation
  - [x] 8.1.1 Review lib/src/features/emergency/ directory
  - [x] 8.1.2 Identify emergency contact functionality
  - [x] 8.1.3 List entities (EmergencyContactEntity)
  - _Requirements: Emergency contact management_

- [x] 8.2 Create Emergency Domain Layer
  - [x] 8.2.1 Create entities (EmergencyContactEntity)
  - [x] 8.2.2 Create EmergencyRepository interface
  - [x] 8.2.3 Create use cases (GetEmergencyContacts, GetContactsByCategory, MakeEmergencyCall)
  - _Requirements: Business logic for emergency contacts_

- [x] 8.3 Create Emergency Data Layer
  - [x] 8.3.1 Create models (EmergencyContactModel)
  - [x] 8.3.2 Create EmergencyLocalDataSource with predefined contacts
  - [x] 8.3.3 Implement EmergencyRepositoryImpl
  - _Requirements: Emergency contact data management_

- [x] 8.4 Create Emergency Presentation Layer
  - [x] 8.4.1 Create EmergencyBloc
  - [x] 8.4.2 Migrate emergency_contact_page.dart to use EmergencyBloc
  - _Requirements: Emergency contact UI with BLoC_

- [x] 8.5 Register Emergency dependencies in DI container
  - _Requirements: Enable dependency injection for emergency_

- [ ]* 8.6 Write Emergency tests
  - _Requirements: Ensure emergency logic is tested_

## Phase 9: Feature Migration - Report (Priority 8) ✅

- [x] 9.1 Analyze Report feature implementation
  - [x] 9.1.1 Review lib/src/features/report/ directory (already has BLoC)
  - [x] 9.1.2 Review existing ReportBloc and ReportFormState
  - [x] 9.1.3 Identify entities (ReportEntity)
  - _Requirements: Incident reporting functionality_

- [x] 9.2 Refactor Report to Clean Architecture
  - [x] 9.2.1 Create domain entities (ReportEntity)
  - [x] 9.2.2 Create ReportRepository interface
  - [x] 9.2.3 Create use cases (CreateReport, LoadReport, SaveReport, DeleteReport, GetSavedReports)
  - [x] 9.2.4 Create data layer with models and datasource
  - [x] 9.2.5 Update ReportBloc to use use cases
  - _Requirements: Report submission with Clean Architecture_

- [x] 9.3 Register Report dependencies in DI container
  - _Requirements: Enable dependency injection for report_

- [ ]* 9.4 Write Report tests
  - _Requirements: Ensure report logic is tested_

## Phase 10: Feature Migration - Explore (Priority 9) ✅

- [x] 10.1 Analyze Explore feature implementation
  - [x] 10.1.1 Review lib/src/features/explore/ directory
  - [x] 10.1.2 Review ExploreController and resource models
  - [x] 10.1.3 Identify entities (ResourceEntity, VideoEntity)
  - _Requirements: Educational resource exploration_

- [x] 10.2 Create Explore Domain Layer
  - [x] 10.2.1 Create entities (ResourceEntity, VideoEntity)
  - [x] 10.2.2 Create ExploreRepository interface
  - [x] 10.2.3 Create use cases (GetRecommendedVideos, GetRecommendedResources, SearchResources)
  - _Requirements: Business logic for content exploration_

- [x] 10.3 Create Explore Data Layer
  - [x] 10.3.1 Create models (ResourceModel, VideoModel)
  - [x] 10.3.2 Create ExploreRemoteDataSource with Firestore
  - [x] 10.3.3 Implement ExploreRepositoryImpl
  - _Requirements: Content data access_

- [x] 10.4 Create Explore Presentation Layer
  - [x] 10.4.1 Create ExploreBloc
  - [x] 10.4.2 Create ExploreEvent and ExploreState
  - _Requirements: Explore UI with BLoC_

- [x] 10.5 Register Explore dependencies in DI container
  - _Requirements: Enable dependency injection for explore_

- [ ]* 10.6 Write Explore tests
  - _Requirements: Ensure explore logic is tested_

## Phase 11: Feature Migration - Consent (Priority 10) ✅

- [x] 11.1 Analyze Consent feature implementation
  - [x] 11.1.1 Review lib/src/features/consent/ directory (already has BLoC)
  - [x] 11.1.2 Review existing ConsentBloc and services
  - [x] 11.1.3 Identify entities (ConsentEntity)
  - _Requirements: Parental consent and control_

- [x] 11.2 Refactor Consent to Clean Architecture
  - [x] 11.2.1 Create domain entities (ConsentEntity)
  - [x] 11.2.2 Create ConsentRepository interface
  - [x] 11.2.3 Create use cases (SubmitConsent, VerifyParentalKey)
  - [x] 11.2.4 Create data layer with models and datasource
  - [x] 11.2.5 Update ConsentBloc to use use cases
  - _Requirements: Consent management with Clean Architecture_

- [x] 11.3 Register Consent dependencies in DI container
  - _Requirements: Enable dependency injection for consent_

- [ ]* 11.4 Write Consent tests
  - _Requirements: Ensure consent logic is tested_

## Phase 12: Code Cleanup & Optimization

- [ ] 12.1 Remove deprecated code
  - [ ] 12.1.1 Remove old controller files after migration
  - [ ] 12.1.2 Remove old service files replaced by repositories
  - [ ] 12.1.3 Clean up unused imports
  - [ ] 12.1.4 Remove duplicate code
  - _Requirements: Clean codebase without legacy code_

- [ ] 12.2 Code quality improvements
  - [ ] 12.2.1 Run flutter analyze and fix all warnings
  - [ ] 12.2.2 Run dart format on entire codebase
  - [ ] 12.2.3 Add dartdoc comments to public APIs
  - [ ] 12.2.4 Review and optimize Firebase queries
  - _Requirements: High code quality standards_

- [ ] 12.3 Performance optimization
  - [ ] 12.3.1 Profile app performance
  - [ ] 12.3.2 Implement caching where appropriate
  - [ ] 12.3.3 Optimize image loading
  - [ ] 12.3.4 Reduce app size
  - _Requirements: Optimal app performance_

- [ ] 12.4 Security review
  - [ ] 12.4.1 Review Firebase security rules
  - [ ] 12.4.2 Check data validation across all features
  - [ ] 12.4.3 Ensure no sensitive data in error messages
  - [ ] 12.4.4 Review authentication flows
  - _Requirements: Secure application_

## Phase 13: Final Documentation

- [ ] 13.1 Update project documentation
  - [ ] 13.1.1 Update main README with architecture overview
  - [ ] 13.1.2 Document each feature's architecture
  - [ ] 13.1.3 Create migration completion report
  - [ ] 13.1.4 Update architecture diagrams
  - _Requirements: Comprehensive project documentation_

- [ ] 13.2 Create developer guides
  - [ ] 13.2.1 Write guide for adding new features
  - [ ] 13.2.2 Document testing best practices
  - [ ] 13.2.3 Create troubleshooting guide
  - _Requirements: Enable future development_

## Notes

- **Migration Strategy**: One feature at a time, complete each fully before moving to next
- **Testing**: Write tests incrementally as features are migrated (marked with * for optional)
- **Code Quality**: Maintain zero compilation errors and warnings throughout
- **Documentation**: Update docs as features are completed
- **Backward Compatibility**: Keep existing code working during migration
- **DI Container**: Register dependencies immediately after creating each feature
