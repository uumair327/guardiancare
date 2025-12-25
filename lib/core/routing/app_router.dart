import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/core/routing/auth_guard.dart';
import 'package:guardiancare/features/features.dart';

/// Application router that defines route configurations.
/// 
/// Authentication redirect logic is delegated to [AuthGuard] following
/// the Single Responsibility Principle.
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  /// The AuthGuard instance used for authentication checks.
  /// Can be overridden for testing purposes.
  static AuthGuard _authGuard = FirebaseAuthGuard();
  
  /// Sets the AuthGuard instance. Useful for testing.
  static void setAuthGuard(AuthGuard guard) {
    _authGuard = guard;
  }
  
  /// Resets the AuthGuard to the default FirebaseAuthGuard.
  static void resetAuthGuard() {
    _authGuard = FirebaseAuthGuard();
  }
  
  static GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) => _authGuard.redirect(context, state),
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      // Email/Password authentication routes - COMMENTED OUT
      // Only Google Sign-In is enabled
      /*
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
      */

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
          final questions = state.extra as List<Map<String, dynamic>>;
          return QuizQuestionsPage(questions: questions);
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
          final user = FirebaseAuth.instance.currentUser;
          return AccountPage(user: user);
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
          return ForumDetailPage(
            forumId: forumId,
            forumTitle: forumTitle,
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
          return VideoPlayerPage(videoUrl: videoUrl);
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
