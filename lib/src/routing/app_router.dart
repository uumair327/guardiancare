import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/home/screens/homePage.dart';
import 'package:guardiancare/src/features/quiz/screens/quizPage.dart';
import 'package:guardiancare/src/screens/account.dart';
import 'package:guardiancare/src/screens/emergencyContactPage.dart';
import 'package:guardiancare/src/screens/searchPage.dart';
import 'package:guardiancare/src/screens/video_page.dart';

//not in use right now
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/account':
        return MaterialPageRoute(builder: (_) => Account());
      case '/emergency':
        return MaterialPageRoute(builder: (_) => EmergencyContactPage());
      case '/quiz':
        return MaterialPageRoute(builder: (_) => QuizPage());
      case '/search':
        return MaterialPageRoute(builder: (_) => SearchPage());
      case '/video':
        return MaterialPageRoute(builder: (_) => VideoPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
