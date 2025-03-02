

import 'package:flutter/material.dart';
import 'package:leaf_aid/constants.dart';
import 'package:leaf_aid/ui/login_page.dart';
import 'package:leaf_aid/ui/screens/home_page.dart';
import 'package:leaf_aid/ui/screens/profile_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _bottomNavIndex = 0;

  //List of the pages
  List<Widget> pages = const [
    HomePage(),
    ProfilePage(),
  ];

//List of the pages icons
List<IconData> iconList = [
  Icons.home,
  Icons.person,
];

//List of the pages titles
  List<String> titleList = [
    'Home',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titleList[_bottomNavIndex], style: TextStyle(
              color: Constants.blackColor,
              fontWeight: FontWeight.w500,
              fontSize: 24,
            ),),
            Icon(Icons.notifications, color: Constants.blackColor, size: 30.0,)
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children:pages,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        splashColor:Constants.primaryColor,
        activeColor: Constants.primaryColor,
        inactiveColor:Colors.black.withOpacity(.5),
        icons: iconList,
        activeIndex:_bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index){
          setState(() {
            _bottomNavIndex = index;

          });
        }
      ),
    );
  }
}
