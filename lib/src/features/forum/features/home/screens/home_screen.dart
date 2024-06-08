import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardiancare/src/features/forum/core/constants/constants.dart';
import 'package:guardiancare/src/features/forum/features/auth/controlller/auth_controller.dart';
import 'package:guardiancare/src/features/forum/features/home/delegates/search_community_delegate.dart';
import 'package:guardiancare/src/features/forum/features/home/drawers/community_list_drawer.dart';
import 'package:guardiancare/src/features/forum/features/home/drawers/profile_drawer.dart';
import 'package:guardiancare/src/features/forum/theme/pallete.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;
  String _title = 'Home';

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
      if (page == 0) {
        _title = 'Home';
      } else if (page == 1) {
        _title = 'Add Drive';
      } else {
        _title = 'Donate';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: false,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => displayDrawer(context),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCommunityDelegate(ref));
            },
            icon: const Icon(Icons.search),
          ),
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
              onPressed: () => displayEndDrawer(context),
            );
          }),
        ],
      ),
      body: Constants.tabWidgets[_page],
      drawer: const CommunityListDrawer(),
      endDrawer: isGuest ? null : const ProfileDrawer(),
      bottomNavigationBar: isGuest || kIsWeb
          ? null
          : CupertinoTabBar(
              activeColor: Colors.blue,
              backgroundColor: currentTheme.colorScheme.background,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Drives',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Add Drive',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_location_alt),
                  label: 'Donate',
                ),
              ],
              onTap: onPageChanged,
              currentIndex: _page,
            ),
    );
  }
}
