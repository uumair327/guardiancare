import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:guardianscare/src/constants/colors.dart';
import 'package:guardianscare/src/features/explore/screens/explore.dart';
import 'package:guardianscare/src/features/forum/screens/forumPage.dart';
import 'package:guardianscare/src/features/home/screens/homePage.dart';

class Pages extends StatefulWidget {
  const Pages({Key? key}) : super(key: key);

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int index = 0; // Changed the default index value

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(
        Icons.home,
        size: 25,
        color: tNavBarColorButton,
      ),
      // const Icon(
      //   Icons.search,
      //   size: 25,
      //   color: Colors.amber,
      // ),
      const Icon(
        Icons.explore,
        size: 25,
        color: tNavBarColorButton,
      ),
      const Icon(
        Icons.forum,
        size: 25,
        color: tNavBarColorButton,
      ),
      // const Icon(
      //   Icons.account_circle,
      //   size: 25,
      //   color: Colors.amber,
      // ),
    ];

    final screens = <Widget>[
      const HomePage(),
      // SearchPage(),
      const Explore(),
      const ForumPage(),
      // Account(user: _user),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text("Children of India",
            style: TextStyle(
                color: tPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 25)),
        leading: const Padding(
          padding: EdgeInsets.all(13.0),
        ),
        centerTitle: true,
        // actions: [
        //   _user != null ? _signOut() : const Text("Hi"),
        // ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: screens[index],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        backgroundColor: Colors.transparent,
        color: tNavBarColor,
        height: 65,
        index: index,
        onTap: (index) => setState(() {
          this.index = index;
        }),
      ),
    );
  }

  // Widget _signOut() {
  //   return TextButton(
  //       onPressed: () => _auth.signOut(), child: const Text("Sign Out", style: TextStyle(color: tPrimaryColor)));
  // }
}
