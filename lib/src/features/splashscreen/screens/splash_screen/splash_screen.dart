import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardianscare/src/constants/images_strings.dart';
import 'package:guardianscare/src/constants/sizes.dart';
import 'package:guardianscare/src/constants/text_strings.dart';
import 'package:guardianscare/src/features/splashscreen/controllers/splash_screen_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  final splashController = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {
    splashController.startAnimation();
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => const AnimatedPositioned(
                top: 0,
                // top: splashController.animate.value? 0: -30,
                left: 0,
                duration: Duration(milliseconds: 1600),
                child: Image(
                  image: AssetImage(tSplashTopIcon),
                )),
          ),
          Obx(
            () => AnimatedPositioned(
              top: 80,
              left: tDefaultSize,
              duration: const Duration(milliseconds: 1600),
              child: AnimatedOpacity(
                opacity: 0,
                duration: const Duration(milliseconds: 1600),
                child: Column(
                  children: [
                    Text(AppName,
                        style: Theme.of(context).textTheme.displayLarge),
                    Text(tAppTagLine,
                        style: Theme.of(context).textTheme.displayMedium)
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => const AnimatedPositioned(
                duration: Duration(milliseconds: 1600),
                bottom: 100,
                child: Image(image: AssetImage(tSplashTopImage))),
          ),
          // Obx(
          //   () => AnimatedPositioned(
          //     duration: Duration(milliseconds: 1600),
          //     bottom: 40,
          //     right: tDefaultSize,
          //     child: Container(
          //       width: tSplashContainerSize,
          //       height: tSplashContainerSize,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(100),
          //         color: tPrimaryColor,
          //       ), // BoxDecoration
          //     ),
          //   ),
          // ) // Container)
        ],
      ),
    );
  }
}
