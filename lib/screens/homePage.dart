import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/account.dart';
import 'package:myapp/screens/forumPage.dart';
import 'package:myapp/screens/reportPage.dart';
import 'package:myapp/screens/searchPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 2; // Changed the default index value

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(
        Icons.search,
        size: 20,
        color: Colors.amber,
      ),
      const Icon(
        Icons.report,
        size: 20,
        color: Colors.amber,
      ),
      const Icon(
        Icons.home,
        size: 20,
        color: Colors.amber,
      ),
      const Icon(
        Icons.forum,
        size: 20,
        color: Colors.amber,
      ),
      const Icon(
        Icons.account_circle,
        size: 20,
        color: Colors.amber,
      ),
    ];

    final screens = <Widget>[
      SearchPage(),
      ReportPage(),
      HomePage(),
      ForumPage(),
      Account(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text("ChildSafety"),
        // Leading commented out as it's causing an error
        // leading: const Padding(
        //   padding: EdgeInsets.all(13.0),
        //   // child: Image.asset("images/logo.png"),
        // ),
        backgroundColor: const Color.fromARGB(255, 132, 255, 228),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            "Home",
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        backgroundColor: Colors.transparent,
        color: Colors.blue,
        height: 60,
        index: index,
        onTap: (index) => setState(() {
          this.index = index;
        }),
      ),
    );
  }
}
