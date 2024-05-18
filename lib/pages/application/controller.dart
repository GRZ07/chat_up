import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/styles/colors.dart';
import 'state.dart';

class ApplicationController extends GetxController {
  final state = ApplicationState();
  ApplicationController();

  late final List<String> tabTitles;
  late final PageController pageController;
  late final List<BottomNavigationBarItem> bottomTabs;

  void handlePageChanged(int index) {
    state.page = index;
  }

  void handleNavBarTaps(int index) {
    pageController.jumpToPage(index);
  }

  @override
  void onInit() {
    super.onInit();
    bottomTabs = [
      const BottomNavigationBarItem(
          icon: Icon(
        Icons.message,
        color: AppColors.hintTextColor,
      ),
      activeIcon: Icon(
        Icons.message,
        color: AppColors.bodyColor,
      ),
      label: 'Chat',
      backgroundColor: AppColors.navbarColor
      ),
      const BottomNavigationBarItem(
          icon: Icon(
        Icons.contact_page,
        color: AppColors.hintTextColor,
      ),

      activeIcon: Icon(
        Icons.contact_page,
        color: AppColors.bodyColor,
      ),
      label: 'Accounts',
      backgroundColor: AppColors.navbarColor
      ),
      const BottomNavigationBarItem(
          icon: Icon(
        Icons.person,
        color: AppColors.hintTextColor,
      ),
      activeIcon: Icon(
        Icons.person,
        color: AppColors.bodyColor,
      ),
      label: 'Profile',
      backgroundColor: AppColors.navbarColor
      ),
    ];
    pageController = PageController(initialPage: state.page);
  }


  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
