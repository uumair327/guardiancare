import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/forum/features/donate/donate_map.dart';
import 'package:guardiancare/src/features/forum/features/feed/feed_screen.dart';
import 'package:guardiancare/src/features/forum/features/post/screens/add_post_screen.dart';

const String googleMapsApiKey = "___Secret ___";

class Constants {
  static const logoPath = 'assets/images/logo.png';
  static const loginEmotePath = 'assets/images/loginEmote.png';
  static const googlePath = 'assets/images/google.png';
  static const iconsPath = 'assets/icons';

  static const archiveAddIcon = '$iconsPath/archive-add.svg';
  static const arrowBottomIcon = '$iconsPath/arrow-bottom.svg';
  static const arrowUpIcon = '$iconsPath/arrow-up.svg';
  static const giftIcon = '$iconsPath/gift.svg';
  static const homeIcon = '$iconsPath/home.svg';
  static const imageIcon = '$iconsPath/image.svg';
  static const linkIcon = '$iconsPath/link.svg';
  static const logoutIcon = '$iconsPath/logout.svg';
  static const commentIcon = '$iconsPath/message-text.svg';
  static const moreIcon = '$iconsPath/more.svg';
  static const searchIcon = '$iconsPath/search-normal.svg';
  static const modIcon = '$iconsPath/security-user.svg';
  static const settingsIcon = '$iconsPath/setting.svg';
  static const textBlockIcon = '$iconsPath/text-block.svg';
  static const trashIcon = '$iconsPath/trash.svg';
  static const userOctagonIcon = '$iconsPath/user-octagon.svg';
  static const verifyIcon = '$iconsPath/verify.svg';

  static const bannerDefault =
      'https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg';
  static const avatarDefault =
      'https://firebasestorage.googleapis.com/v0/b/soln-no-poverty.appspot.com/o/Defaults%2FAvatar.png?alt=media&token=15219f88-1e6b-4b7c-8601-081c1930d061';

  static const tabWidgets = [
    FeedScreen(),
    AddPostScreen(),
    DonationScreen(),
  ];

  static const IconData up =
      IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
  static const IconData down =
      IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);

  static const awardsPath = 'assets/images/awards';

  static const awards = {
    'awesomeAns': '${Constants.awardsPath}/awesomeanswer.png',
    'gold': '${Constants.awardsPath}/gold.png',
    'platinum': '${Constants.awardsPath}/platinum.png',
    'helpful': '${Constants.awardsPath}/helpful.png',
    'plusone': '${Constants.awardsPath}/plusone.png',
    'rocket': '${Constants.awardsPath}/rocket.png',
    'thankyou': '${Constants.awardsPath}/thankyou.png',
    'til': '${Constants.awardsPath}/til.png',
  };
}
