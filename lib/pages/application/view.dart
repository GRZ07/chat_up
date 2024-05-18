import 'package:chat_up/common/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../accounts/index.dart';
import '../chats/view.dart';
import '../profile/view.dart';
import 'index.dart';

class ApplicationPage extends GetView<ApplicationController> {
  const ApplicationPage({super.key});

  Widget _buildPageView() {
    return PageView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: controller.pageController,
      onPageChanged: controller.handlePageChanged,
      children:  const [
        ChatsPage(),
        AccountsPage(),
        ProfilePage(),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(
    () => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      child: BottomNavigationBar(
        items: controller.bottomTabs,
        currentIndex: controller.state.page,
        type: BottomNavigationBarType.fixed,
        onTap: controller.handleNavBarTaps,
        showSelectedLabels: true,
        backgroundColor: AppColors.primary,
        showUnselectedLabels: true,
        unselectedItemColor: AppColors.hintTextColor,
        selectedItemColor: AppColors.bodyColor,
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageView(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
