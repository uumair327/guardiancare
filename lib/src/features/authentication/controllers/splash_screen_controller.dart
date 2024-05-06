import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  static SplashScreenController get find => Get.find();
  RxBool animate = false.obs;

  Future startAnimation() async {
    await Future.delayed(Duration(milliseconds: 500));
    animate.value = true;
    await Future.delayed(Duration(milliseconds: 5000));
    // Get.to(WelcomeScreen());
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
  }
}
