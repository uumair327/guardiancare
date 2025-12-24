import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/features.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // ============================================================================
  // Core
  // ============================================================================
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // ============================================================================
  // External
  // ============================================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  
  // Initialize Storage Manager (SQLite + Hive)
  final storageManager = StorageManager.instance;
  await storageManager.init();
  sl.registerLazySingleton(() => storageManager);
  
  // Register storage services for dependency injection
  sl.registerLazySingleton(() => HiveService.instance);
  
  // DatabaseService is only available on non-web platforms
  if (!kIsWeb) {
    sl.registerLazySingleton(() => DatabaseService.instance);
  }
  
  // Register LocaleService
  sl.registerLazySingleton(() => LocaleService(sharedPreferences));

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

/// Initialize Authentication feature dependencies
void _initAuthFeature() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
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

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithGoogle: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      sendPasswordResetEmail: sl(),
    ),
  );
}

/// Initialize Forum feature dependencies
void _initForumFeature() {
  // Data sources
  sl.registerLazySingleton<ForumRemoteDataSource>(
    () => ForumRemoteDataSourceImpl(firestore: sl()),
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
    () => HomeRemoteDataSourceImpl(firestore: sl()),
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
      firestore: sl(),
      auth: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  sl.registerLazySingleton(() => ClearUserPreferences(sl()));

  // BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getProfile: sl(),
      updateProfile: sl(),
      deleteAccount: sl(),
      clearUserPreferences: sl(),
    ),
  );
}

/// Initialize Learn feature dependencies
void _initLearnFeature() {
  // Data sources
  sl.registerLazySingleton<LearnRemoteDataSource>(
    () => LearnRemoteDataSourceImpl(firestore: sl()),
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
    () => QuizLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetQuiz(sl()));
  sl.registerLazySingleton(() => GetQuestions(sl()));
  sl.registerLazySingleton(() => SubmitQuiz(sl()));
  sl.registerLazySingleton(() => ValidateQuiz(sl()));

  // BLoC
  sl.registerFactory(
    () => QuizBloc(
      submitQuiz: sl(),
      validateQuiz: sl(),
    ),
  );
}

/// Initialize Emergency feature dependencies
void _initEmergencyFeature() {
  // Data sources
  sl.registerLazySingleton<EmergencyLocalDataSource>(
    () => EmergencyLocalDataSourceImpl(),
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
    () => ExploreRemoteDataSourceImpl(firestore: sl()),
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
    () => ConsentRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ConsentRepository>(
    () => ConsentRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SubmitConsent(sl()));
  sl.registerLazySingleton(() => VerifyParentalKey(sl()));

  // BLoC
  sl.registerFactory(
    () => ConsentBloc(
      submitConsent: sl(),
      verifyParentalKey: sl(),
    ),
  );
}
