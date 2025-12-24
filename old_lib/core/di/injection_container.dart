import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardiancare/core/network/network_info.dart';
import 'package:guardiancare/core/database/storage_manager.dart';
import 'package:guardiancare/core/database/hive_service.dart';
import 'package:guardiancare/core/database/database_service.dart';
import 'package:guardiancare/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:guardiancare/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:guardiancare/features/authentication/domain/usecases/get_current_user.dart';
import 'package:guardiancare/features/authentication/domain/usecases/send_password_reset_email.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_out.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_up_with_email.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:guardiancare/features/forum/data/datasources/forum_remote_datasource.dart';
import 'package:guardiancare/features/forum/data/repositories/forum_repository_impl.dart';
import 'package:guardiancare/features/forum/domain/repositories/forum_repository.dart';
import 'package:guardiancare/features/forum/domain/usecases/add_comment.dart';
import 'package:guardiancare/features/forum/domain/usecases/get_comments.dart';
import 'package:guardiancare/features/forum/domain/usecases/get_forums.dart';
import 'package:guardiancare/features/forum/domain/usecases/get_user_details.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_bloc.dart';
import 'package:guardiancare/features/home/data/datasources/home_remote_datasource.dart';
import 'package:guardiancare/features/home/data/repositories/home_repository_impl.dart';
import 'package:guardiancare/features/home/domain/repositories/home_repository.dart';
import 'package:guardiancare/features/home/domain/usecases/get_carousel_items.dart';
import 'package:guardiancare/features/home/presentation/bloc/home_bloc.dart';
import 'package:guardiancare/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:guardiancare/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:guardiancare/features/profile/domain/repositories/profile_repository.dart';
import 'package:guardiancare/features/profile/domain/usecases/clear_user_preferences.dart';
import 'package:guardiancare/features/profile/domain/usecases/delete_account.dart';
import 'package:guardiancare/features/profile/domain/usecases/get_profile.dart';
import 'package:guardiancare/features/profile/domain/usecases/update_profile.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:guardiancare/features/learn/data/datasources/learn_remote_datasource.dart';
import 'package:guardiancare/features/learn/data/repositories/learn_repository_impl.dart';
import 'package:guardiancare/features/learn/domain/repositories/learn_repository.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_categories.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_videos_by_category.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_videos_stream.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_bloc.dart';
import 'package:guardiancare/features/quiz/data/datasources/quiz_local_datasource.dart';
import 'package:guardiancare/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:guardiancare/features/quiz/domain/usecases/get_questions.dart';
import 'package:guardiancare/features/quiz/domain/usecases/get_quiz.dart';
import 'package:guardiancare/features/quiz/domain/usecases/submit_quiz.dart';
import 'package:guardiancare/features/quiz/domain/usecases/validate_quiz.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:guardiancare/features/emergency/data/datasources/emergency_local_datasource.dart';
import 'package:guardiancare/features/emergency/data/repositories/emergency_repository_impl.dart';
import 'package:guardiancare/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:guardiancare/features/emergency/domain/usecases/get_contacts_by_category.dart';
import 'package:guardiancare/features/emergency/domain/usecases/get_emergency_contacts.dart';
import 'package:guardiancare/features/emergency/domain/usecases/make_emergency_call.dart';
import 'package:guardiancare/features/emergency/presentation/bloc/emergency_bloc.dart';
import 'package:guardiancare/features/report/data/datasources/report_local_datasource.dart';
import 'package:guardiancare/features/report/data/repositories/report_repository_impl.dart';
import 'package:guardiancare/features/report/domain/repositories/report_repository.dart';
import 'package:guardiancare/features/report/domain/usecases/create_report.dart';
import 'package:guardiancare/features/report/domain/usecases/delete_report.dart';
import 'package:guardiancare/features/report/domain/usecases/get_saved_reports.dart';
import 'package:guardiancare/features/report/domain/usecases/load_report.dart';
import 'package:guardiancare/features/report/domain/usecases/save_report.dart';
import 'package:guardiancare/features/report/presentation/bloc/report_bloc.dart';
import 'package:guardiancare/features/explore/data/datasources/explore_remote_datasource.dart';
import 'package:guardiancare/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:guardiancare/features/explore/domain/repositories/explore_repository.dart';
import 'package:guardiancare/features/explore/domain/usecases/get_recommended_resources.dart';
import 'package:guardiancare/features/explore/domain/usecases/get_recommended_videos.dart';
import 'package:guardiancare/features/explore/domain/usecases/search_resources.dart';
import 'package:guardiancare/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:guardiancare/features/consent/data/datasources/consent_remote_datasource.dart';
import 'package:guardiancare/features/consent/data/repositories/consent_repository_impl.dart';
import 'package:guardiancare/features/consent/domain/repositories/consent_repository.dart';
import 'package:guardiancare/features/consent/domain/usecases/submit_consent.dart';
import 'package:guardiancare/features/consent/domain/usecases/verify_parental_key.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_bloc.dart';

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
  sl.registerLazySingleton(() => DatabaseService.instance);

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

// Feature-specific initialization functions will be added here
// Example:
// void _initAuthFeature() {
//   // Data sources
//   sl.registerLazySingleton<AuthRemoteDataSource>(
//     () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
//   );
//   
//   // Repositories
//   sl.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(
//       remoteDataSource: sl(),
//       networkInfo: sl(),
//     ),
//   );
//   
//   // Use cases
//   sl.registerLazySingleton(() => SignIn(sl()));
//   sl.registerLazySingleton(() => SignUp(sl()));
//   
//   // BLoC
//   sl.registerFactory(
//     () => AuthBloc(
//       signIn: sl(),
//       signUp: sl(),
//     ),
//   );
// }


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
  sl.registerLazySingleton(() => GetRecommendedVideos(sl()));
  sl.registerLazySingleton(() => GetRecommendedResources(sl()));
  sl.registerLazySingleton(() => SearchResources(sl()));

  // BLoC
  sl.registerFactory(
    () => ExploreBloc(
      getRecommendedVideos: sl(),
      getRecommendedResources: sl(),
      searchResources: sl(),
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
