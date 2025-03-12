import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:listenary/view/pages/home.dart';
import 'package:listenary/view/pages/BookListScreen.dart';
import 'package:listenary/view/pages/UploadPage.dart';

import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    // final screenWidth = mediaQuery.size.width;
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardAppears: true,
        padding: const EdgeInsets.only(top: 0),
        backgroundColor: Colors.white,
        isVisible: true,
        animationSettings: const NavBarAnimationSettings(
          navBarItemAnimation: ItemAnimationSettings(
            duration: Duration(milliseconds: 400),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            animateTabTransition: true,
            duration: Duration(milliseconds: 200),
            screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
          ),
        ),
        confineToSafeArea: true,
        navBarHeight: screenHeight * 0.052,
        navBarStyle: NavBarStyle.style6,
        onItemSelected: (index) {
          setState(() {
            _controller.index = index; // Update the controller index
          });
        },
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      const Home(),
      const UploadPage(),
      BookListScreen(),

    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      _buildNavBarItem("assets/Icons/home.svg", 0),
      _buildNavBarItem("assets/Icons/upload.svg", 1),
      _buildNavBarItem("assets/Icons/library.svg", 2),
    ];
  }

  PersistentBottomNavBarItem _buildNavBarItem(String iconPath,  int index) {
    return PersistentBottomNavBarItem(
      icon: SvgPicture.asset(
              iconPath,
              color: _controller.index == index
                  ? const Color(0XFF212E54) // Color for the selected item
                  : const Color(0XFF949494), // Color for the unselected item
              height: 26, // Optional: Set height to match icon size
              width: 26, // Optional: Set width to match icon size
            ),
      iconSize: 26,
    );
  }
}
