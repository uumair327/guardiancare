import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/core/di/di.dart' as di;
import 'package:guardiancare/features/features.dart';
import 'package:guardiancare/features/video_player/presentation/pages/video_player_page.dart'
    as video_player;

/// Application router that defines route configurations.
///
/// Authentication redirect logic is delegated to [AuthGuard] following
/// the Single Responsibility Principle.
///
/// Following: DIP (Dependency Inversion Principle) - uses IAuthService abstraction
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  // Lazy initialization of AuthGuard using IAuthService
  static AuthGuard? _authGuard;

  /// Get the AuthGuard instance (lazy initialized)
  static AuthGuard get authGuard {
    _authGuard ??= AuthGuardImpl(authService: di.sl<IAuthService>());
    return _authGuard!;
  }

  /// Sets the AuthGuard instance. Useful for testing.
  // ignore: use_setters_to_change_properties
  static void setAuthGuard(AuthGuard guard) {
    _authGuard = guard;
  }

  /// Resets the AuthGuard to use IAuthService.
  static void resetAuthGuard() {
    _authGuard = AuthGuardImpl(authService: di.sl<IAuthService>());
  }

  /// Get auth state changes stream for router refresh
  static Stream<BackendUser?> get _authStateChanges =>
      di.sl<IAuthService>().authStateChanges;

  static GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(_authStateChanges),
    redirect: (context, state) => authGuard.redirect(context, state),
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      // Email/Password authentication routes
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/password-reset',
        name: 'password-reset',
        builder: (context, state) => const PasswordResetPage(),
      ),
      GoRoute(
        path: '/email-verification',
        name: 'email-verification',
        builder: (context, state) => const EmailVerificationPage(),
      ),

      // Main app route with bottom navigation
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const Pages(),
      ),

      // Quiz routes
      GoRoute(
        path: '/quiz',
        name: 'quiz',
        builder: (context, state) => const QuizPage(),
      ),
      GoRoute(
        path: '/quiz-questions',
        name: 'quiz-questions',
        builder: (context, state) {
          final questions = state.extra as List<QuestionEntity>;
          return BlocProvider(
            create: (_) => di.sl<QuizBloc>(),
            child: QuizQuestionsPage(questions: questions),
          );
        },
      ),

      // Learn/Video routes
      GoRoute(
        path: '/video',
        name: 'video',
        builder: (context, state) => const VideoPage(),
      ),

      // Emergency route
      GoRoute(
        path: '/emergency',
        name: 'emergency',
        builder: (context, state) => const EmergencyContactPage(),
      ),

      // Profile/Account route
      GoRoute(
        path: '/account',
        name: 'account',
        builder: (context, state) {
          // Use IAuthService to get current user
          final authService = di.sl<IAuthService>();
          final backendUser = authService.currentUser;
          return AccountPage(backendUser: backendUser);
        },
      ),

      // Forum detail route
      GoRoute(
        path: '/forum/:id',
        name: 'forum-detail',
        builder: (context, state) {
          final forumId = state.pathParameters['id']!;
          final forumData = state.extra as Map<String, dynamic>?;
          final forumTitle = forumData?['title'] ?? 'Forum';
          final forumDescription = forumData?['description'] as String?;
          final createdAtStr = forumData?['createdAt'] as String?;
          final userId = forumData?['userId'] as String?;

          DateTime? createdAt;
          if (createdAtStr != null) {
            try {
              createdAt = DateTime.parse(createdAtStr);
            } on Object catch (_) {}
          }

          return ForumDetailPage(
            forumId: forumId,
            forumTitle: forumTitle,
            forumDescription: forumDescription,
            createdAt: createdAt,
            userId: userId,
          );
        },
      ),

      // WebView route
      GoRoute(
        path: '/webview',
        name: 'webview',
        builder: (context, state) {
          final url = state.extra as String;
          return WebViewPage(url: url);
        },
      ),

      // PDF Viewer route
      GoRoute(
        path: '/pdf-viewer',
        name: 'pdf-viewer',
        builder: (context, state) {
          final params = state.extra as Map<String, String>;
          return PDFViewerPage(
            pdfUrl: params['url']!,
            title: params['title']!,
          );
        },
      ),

      // Video player route
      GoRoute(
        path: '/video-player',
        name: 'video-player',
        builder: (context, state) {
          final videoUrl = state.extra as String;
          return video_player.VideoPlayerPage(videoUrl: videoUrl);
        },
      ),
    ],
  );
}

// Helper class to convert Stream to ChangeNotifier for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
