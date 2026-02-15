import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/core/util/logger.dart';
import 'package:guardiancare/features/features.dart';
import 'package:guardiancare/features/quiz/domain/usecases/get_all_quizzes.dart';
import 'package:guardiancare/features/quiz/domain/usecases/save_quiz_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // ============================================================================
  // Backend Abstraction Layer (Hexagonal Architecture - Ports & Adapters)
  // These are the ONLY Firebase dependencies that should exist in the app.
  // All other code should depend on the abstract interfaces (IAuthService, etc.)
  // To switch to a different backend (Supabase, Appwrite), change the provider here.
  // ============================================================================
  _initBackendServices();

  // ============================================================================
  // Core
  // ============================================================================
  sl.registerLazySingleton<NetworkInfo>(NetworkInfoImpl.new);

  // ============================================================================
  // External (Legacy - kept for gradual migration, will be removed)
  // TODO: Remove these once all features are migrated to use abstraction layer
  // ============================================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Legacy Firebase registrations - kept temporarily for backward compatibility
  // These will be removed as features migrate to IAuthService and IDataStore
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '480855529488-809q7ih0n0vhoqrj47pgk986u4kobt1h.apps.googleusercontent.com',
      ));

  // Initialize Storage Manager (SQLite + Hive)
  final storageManager = StorageManager.instance;
  await storageManager.init();
  sl.registerLazySingleton(() => storageManager);

  // Register storage services for dependency injection
  // Legacy HiveService for backward compatibility
  sl.registerLazySingleton(() => HiveService.instance);

  // New SRP-compliant storage services (Requirements: 8.1, 8.2, 8.3, 8.4)
  sl.registerLazySingleton<PreferencesStorageService>(
    () => storageManager.preferencesService,
  );
  sl.registerLazySingleton<HiveStorageService>(
    () => storageManager.hiveService,
  );
  sl.registerLazySingleton<SQLiteStorageService>(
    () => storageManager.sqliteService,
  );

  // DatabaseService is only available on non-web platforms
  if (!kIsWeb) {
    sl.registerLazySingleton(() => DatabaseService.instance);
  }

  // Register LocaleService
  sl.registerLazySingleton(() => LocaleService(sharedPreferences));

  // Register ThemeService
  sl.registerLazySingleton(() => ThemeService(sharedPreferences));

  // ============================================================================
  // Managers (SRP - Single Responsibility Principle)
  // ============================================================================
  _initManagers();

  // ============================================================================
  // Features
  // ============================================================================
  _initAuthFeature();
  _initForumFeature();
  _initHomeFeature();
  _initProfileFeature();
  _initLearnFeature();
  _initQuizFeature();
  _initEmergencyFeature();
  _initReportFeature();
  _initExploreFeature();
  _initConsentFeature();
}

/// Initialize backend abstraction layer services.
///
/// This is the **SINGLE LOCATION** where backend adapters are resolved.
/// Uses "Backend Polymorphism via Flag-Driven Adapter Resolution" pattern.
///
/// ## How Backend Selection Works
///
/// 1. **Global Switch** (recommended):
///    ```bash
///    flutter run --dart-define=BACKEND=supabase
///    ```
///
/// 2. **Granular Overrides** (mix providers):
///    ```bash
///    flutter run --dart-define=USE_SUPABASE_AUTH=true
///    ```
///
/// ## Architecture Compliance
/// - **DIP**: App depends on interfaces (IAuthService, IDataStore, etc.)
/// - **OCP**: Add new backends without modifying existing code
/// - **SRP**: Each adapter handles one backend's implementation
///
/// ## Critical Rule (NON-NEGOTIABLE)
/// **Domain layer MUST NOT know which backend is active.**
void _initBackendServices() {
  // Validate backend secrets before initializing services
  // This will throw if required secrets are missing for the active backend
  if (BackendConfig.hasSupabaseFeatures) {
    BackendSecrets.validate();
  }

  // Create factory - automatically reads from BackendConfig
  // No explicit provider needed! The factory uses feature flags internally.
  const factory = BackendFactory();

  // Register abstract interfaces with concrete implementations
  // The rest of the app should ONLY depend on these interfaces
  sl.registerLazySingleton<IAuthService>(() => factory.createAuthService());
  sl.registerLazySingleton<IDataStore>(() => factory.createDataStore());
  sl.registerLazySingleton<IStorageService>(
      () => factory.createStorageService());
  sl.registerLazySingleton<IAnalyticsService>(
      () => factory.createAnalyticsService());
  sl.registerLazySingleton<IRealtimeService>(
      () => factory.createRealtimeService());

  // Log active backend configuration for debugging
  Log.i('Backend initialized: ${BackendConfig.debugInfo}');
}

/// Initialize manager dependencies for SRP compliance
void _initManagers() {
  // ============================================================================
  // Parental Verification Services (SRP - Requirements: 9.1, 9.2, 9.3, 9.4)
  // Must be initialized first as other managers depend on them
  // ============================================================================

  // CryptoService - handles cryptographic operations exclusively
  sl.registerLazySingleton<CryptoService>(
    () => const CryptoServiceImpl(),
  );

  // ParentalSessionManager - handles session state management exclusively
  sl.registerLazySingleton<ParentalSessionManager>(
    ParentalSessionManagerImpl.new,
  );

  // ParentalKeyVerifier - handles verification logic exclusively
  sl.registerLazySingleton<ParentalKeyVerifier>(
    () => ParentalKeyVerifierImpl(
      cryptoService: sl(),
      firestore: sl(),
    ),
  );

  // Initialize ParentalVerificationService with dependencies
  ParentalVerificationService.initialize(
    sessionManager: sl(),
    keyVerifier: sl(),
    auth: sl(),
  );

  // Register ParentalVerificationService for DI access
  // Note: The service uses singleton pattern internally, but we register it
  // for consistency and to allow injection via GetIt
  sl.registerLazySingleton<ParentalVerificationService>(
    ParentalVerificationService.new,
  );

  // ============================================================================
  // App Managers (SRP - Single Responsibility Principle)
  // Requirements: 1.1, 1.2, 1.3
  // ============================================================================

  // AuthStateManager - manages authentication state using IAuthService abstraction
  // Following: DIP (Dependency Inversion Principle)
  sl.registerLazySingleton<AuthStateManager>(
    () => AuthStateManagerImpl(authService: sl<IAuthService>()),
  );

  // LocaleManager - manages application locale
  sl.registerLazySingleton<LocaleManager>(
    () => LocaleManagerImpl(localeService: sl()),
  );

  // ThemeManager - manages application theme
  sl.registerLazySingleton<ThemeManager>(
    () => ThemeManagerImpl(themeService: sl()),
  );

  // AppLifecycleManager - manages app lifecycle events
  // Inject ParentalVerificationService for proper DI
  sl.registerLazySingleton<AppLifecycleManager>(
    () => AppLifecycleManagerImpl(
      verificationService: sl<ParentalVerificationService>(),
    ),
  );
}

/// Initialize Authentication feature dependencies
void _initAuthFeature() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      authService: sl<IAuthService>(),
      dataStore: sl<IDataStore>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmail(sl()));
  sl.registerLazySingleton(() => SendEmailVerification(sl()));
  sl.registerLazySingleton(() => ReloadUser(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithGoogle: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      sendPasswordResetEmail: sl(),
      sendEmailVerification: sl(),
      reloadUser: sl(),
    ),
  );
}

/// Initialize Forum feature dependencies
void _initForumFeature() {
  // Data sources
  sl.registerLazySingleton<ForumRemoteDataSource>(
    () => ForumRemoteDataSourceImpl(dataStore: sl<IDataStore>()),
  );

  // Repositories
  sl.registerLazySingleton<ForumRepository>(
    () => ForumRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetForums(sl()));
  sl.registerLazySingleton(() => GetComments(sl()));
  sl.registerLazySingleton(() => AddComment(sl()));
  sl.registerLazySingleton(() => GetUserDetails(sl()));

  // BLoC
  sl.registerFactory(
    () => ForumBloc(
      getForums: sl(),
      getComments: sl(),
      addComment: sl(),
      firebaseAuth: sl(),
    ),
  );
}

/// Initialize Home feature dependencies
void _initHomeFeature() {
  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dataStore: sl<IDataStore>()),
  );

  // Repositories
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCarouselItems(sl()));

  // BLoC
  sl.registerFactory(
    () => HomeBloc(getCarouselItems: sl()),
  );
}

/// Initialize Profile feature dependencies
void _initProfileFeature() {
  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      dataStore: sl<IDataStore>(),
      authService: sl<IAuthService>(),
      sharedPreferences: sl(),
    ),
  );

  // User stats local data source - uses DAOs from StorageManager
  // Only available on non-web platforms where SQLite is supported
  if (!kIsWeb) {
    sl.registerLazySingleton<UserStatsLocalDataSource>(
      () => UserStatsLocalDataSourceImpl(
        quizDao: sl<StorageManager>().quizDao!,
        videoDao: sl<StorageManager>().videoDao!,
      ),
    );

    sl.registerLazySingleton<UserStatsRepository>(
      () => UserStatsRepositoryImpl(localDataSource: sl()),
    );

    sl.registerLazySingleton(() => GetUserStats(sl()));
  }

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  sl.registerLazySingleton(() => ClearUserPreferences(sl()));

  // BLoC - delegates to LocaleService and AuthRepository per SRP
  // Requirements: 6.1, 6.2, 6.3
  sl.registerFactory(
    () => ProfileBloc(
      getProfile: sl(),
      updateProfile: sl(),
      deleteAccount: sl(),
      clearUserPreferences: sl(),
      localeService: sl(),
      authRepository: sl(),
    ),
  );

  // UserStatsCubit - handles user statistics separately (SRP)
  sl.registerFactory(
    () => UserStatsCubit(
      getUserStats: kIsWeb ? null : sl(),
    ),
  );
}

/// Initialize Learn feature dependencies
void _initLearnFeature() {
  // Data sources
  sl.registerLazySingleton<LearnRemoteDataSource>(
    () => LearnRemoteDataSourceImpl(dataStore: sl<IDataStore>()),
  );

  // Repositories
  sl.registerLazySingleton<LearnRepository>(
    () => LearnRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetVideosByCategory(sl()));
  sl.registerLazySingleton(() => GetVideosStream(sl()));

  // BLoC
  sl.registerFactory(
    () => LearnBloc(
      getCategories: sl(),
      getVideosByCategory: sl(),
      getVideosStream: sl(),
    ),
  );
}

/// Initialize Quiz feature dependencies
void _initQuizFeature() {
  // Data sources
  sl.registerLazySingleton<QuizLocalDataSource>(
    QuizLocalDataSourceImpl.new,
  );

  // Services - Abstract interfaces bound to concrete implementations
  // Clean Architecture: Domain interfaces registered with Data layer implementations
  // Requirements: 4.3
  sl.registerLazySingleton<GeminiAIService>(
    GeminiAIServiceImpl.new,
  );

  sl.registerLazySingleton<YoutubeSearchService>(
    YoutubeSearchServiceImpl.new,
  );

  // Repositories
  sl.registerLazySingleton<QuizRepository>(
    () =>
        QuizRepositoryImpl(localDataSource: sl(), dataStore: sl<IDataStore>()),
  );

  sl.registerLazySingleton<RecommendationRepository>(
    () => RecommendationRepositoryImpl(dataStore: sl<IDataStore>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetQuiz(sl()));
  sl.registerLazySingleton(() => GetQuestions(sl()));
  sl.registerLazySingleton(() => SubmitQuiz(sl()));
  sl.registerLazySingleton(() => ValidateQuiz(sl()));
  sl.registerLazySingleton(() => SaveQuizHistory(sl()));
  sl.registerLazySingleton(() => GetAllQuizzes(sl())); // Added
  sl.registerLazySingleton(() => RecommendationUseCase(
        geminiService: sl(),
        youtubeService: sl(),
        repository: sl<RecommendationRepository>(),
      ));
  sl.registerLazySingleton(
      () => GenerateRecommendations(sl<RecommendationUseCase>()));

  // BLoC
  sl.registerFactory(
    () => QuizBloc(
      submitQuiz: sl(),
      validateQuiz: sl(),
      generateRecommendations: sl(),
      saveQuizHistory: sl(),
      authService: sl<IAuthService>(),
    ),
  );
}

/// Initialize Emergency feature dependencies
void _initEmergencyFeature() {
  // Data sources
  sl.registerLazySingleton<EmergencyLocalDataSource>(
    EmergencyLocalDataSourceImpl.new,
  );

  // Repositories
  sl.registerLazySingleton<EmergencyRepository>(
    () => EmergencyRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetEmergencyContacts(sl()));
  sl.registerLazySingleton(() => GetContactsByCategory(sl()));
  sl.registerLazySingleton(() => MakeEmergencyCall(sl()));

  // BLoC
  sl.registerFactory(
    () => EmergencyBloc(
      getEmergencyContacts: sl(),
      getContactsByCategory: sl(),
      makeEmergencyCall: sl(),
    ),
  );
}

/// Initialize Report feature dependencies
void _initReportFeature() {
  // Data sources
  sl.registerLazySingleton<ReportLocalDataSource>(
    () => ReportLocalDataSourceImpl(hiveService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateReport(sl()));
  sl.registerLazySingleton(() => LoadReport(sl()));
  sl.registerLazySingleton(() => SaveReport(sl()));
  sl.registerLazySingleton(() => DeleteReport(sl()));
  sl.registerLazySingleton(() => GetSavedReports(sl()));

  // BLoC
  sl.registerFactory(
    () => ReportBloc(
      createReport: sl(),
      loadReport: sl(),
      saveReport: sl(),
      deleteReport: sl(),
      getSavedReports: sl(),
    ),
  );
}

/// Initialize Explore feature dependencies
void _initExploreFeature() {
  // Data sources
  sl.registerLazySingleton<ExploreRemoteDataSource>(
    () => ExploreRemoteDataSourceImpl(dataStore: sl<IDataStore>()),
  );

  // Repositories
  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRecommendations(sl()));
  sl.registerLazySingleton(() => GetResources(sl()));

  // Cubit
  sl.registerFactory(
    () => ExploreCubit(
      getRecommendations: sl(),
      getResources: sl(),
    ),
  );
}

/// Initialize Consent feature dependencies
void _initConsentFeature() {
  // Data sources
  sl.registerLazySingleton<ConsentRemoteDataSource>(
    () => ConsentRemoteDataSourceImpl(dataStore: sl<IDataStore>()),
  );

  sl.registerLazySingleton<ConsentLocalDataSource>(
    () => ConsentLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ConsentRepository>(
    () => ConsentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SubmitConsent(sl()));
  sl.registerLazySingleton(() => VerifyParentalKey(sl()));
  sl.registerLazySingleton(() => SaveParentalKey(sl()));

  // BLoC
  sl.registerFactory(
    () => ConsentBloc(
      submitConsent: sl(),
      verifyParentalKey: sl(),
      saveParentalKey: sl(),
    ),
  );
}
