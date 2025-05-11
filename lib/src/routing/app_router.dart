import 'package:get/get.dart';
import 'package:guardiancare/src/features/authentication/guards/auth_guard.dart';
import 'package:guardiancare/src/features/authentication/screens/login_page.dart';
import 'package:guardiancare/src/features/home/screens/home_page.dart';
import 'package:guardiancare/src/features/profile/screens/account.dart';

class AppRouter {
  static const String initialRoute = '/login';
  static const String home = '/home';
  static const String forum = '/forum';
  static const String parentalControls = '/parental-controls';
  static const String account = '/account';
  static const String login = '/login';

  static final List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: account,
      page: () => const Account(),
      middlewares: [AuthGuard()],
    ),
  ];

  static void configureRoutes() {
    Get.addPages(routes);
  }
}
