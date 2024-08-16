import 'package:flutter/material.dart';
import 'package:guardianscare/src/constants/colors.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

import '../../../../constants/images_strings.dart';
import '../../../../constants/text_strings.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        LiquidSwipe(pages: [
          Container(
            color: tOnBoardingPage1Color,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: const AssetImage(tOnBoardingImage1),
                  height: size.height * 0.5,
                ),
                Column(
                  children: [
                    Text(tOnBoardingTitle1,
                        style: Theme.of(context).textTheme.labelMedium),
                    Text(tOnBoardingSubTitle1,
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                const Text(tOnBoardingCounter1),
              ],
            ),
          ),
          Container(
            color: tOnBoardingPage2Color,
          ),
          Container(
            color: tOnBoardingPage3Color,
          ),
        ])
      ]),
    );
  }
}
