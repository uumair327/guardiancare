import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/di/injection_container.dart';
import 'package:guardiancare/core/routing/pages.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:guardiancare/features/authentication/presentation/pages/login_page.dart';
import 'package:guardiancare/features/authentication/presentation/pages/password_reset_page.dart';
import 'package:guardiancare/features/authentication/presentation/pages/signup_page.dart';
import 'package:guardiancare/features/quiz/presentation/pages/quiz_page.dart';
import 'package:guardiancare/features/quiz/presentation/pages/quiz_questions_page.dart';
import 'package:guardiancare/features/learn/presentation/pages/video_page.dart';
import 'package:guardiancare/features/emergency/presentation/pages/emergency_contact_page.dart';
import 'package:guardiancare/features/profile/presentation/pages/account_page.dart';
import 'package:guardiancare/features/forum/presentation/pages/forum_detail_page.dart';
import 'package:guardiancare/core/widgets/web_view_page.dart';
import 'package:guardiancare/core/widgets/video_player_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/password-reset';

      // If user is not logged in and trying to access protected route
      if (user == null && !isLoginRoute) {
        return '/login';
      }

      // If user is logged in and trying to access login routes
      if (user != null && isLoginRoute) {
        return '/';
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
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
        builder: (context, state) => const AccountPage(),
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
