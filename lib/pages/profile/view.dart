import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/entities/user.dart';
import '../../common/styles/colors.dart';
import '../../common/widgets/appbar.dart';
import '../application/controller.dart';
import 'index.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    AppBar buildAppBar() {
      return mainAppBar(
        title: 'Profile',
      );
    }

    Widget myInfo(UserLoginResponseEntity? user) {
      if (user == null) {
        // Handle the null case, e.g., display a placeholder or return an empty widget
        return Container(
          padding: const EdgeInsets.all(8.0),
          height: 120.h,
          child: Card(
            color: AppColors.bodyColor,
            child: Center(
              child: Text(
                'No user data available',
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(8.0),
        height: 120.h,
        child: Card(
          color: AppColors.primary,
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.0.w),
                child: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      CachedNetworkImageProvider(user.photoUrl ?? ''),
                  child: CachedNetworkImage(
                    imageUrl: user.photoUrl ?? '',
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: AppColors.primary,
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 230.w,
                    child: Text(
                      user.displayName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                  Text(
                    user.email ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w300,
                      color: AppColors.hintTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget meItem(MeListItem item) {
      final itemName = item.name;

      return Container(
        height: 56.w,
        color: AppColors.transparent,
        margin: EdgeInsets.only(bottom: 1.w),
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: InkWell(
          onTap: () {
            if (item.route == '/logout') {
              showDialog(
                context: Get.context!,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Confirm Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.onLogout();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Logout',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            }

            if (item.route == '/accounts') {
              ApplicationController appController =
                  Get.find<ApplicationController>();

              appController.pageController.jumpToPage(1);
            }

            if (item.route == '/chat') {
              ApplicationController appController =
                  Get.find<ApplicationController>();

              appController.pageController.jumpToPage(0);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    (item.route == '/accounts'
                        ? Icons.account_circle_outlined
                        : (item.route == '/chat'
                            ? Icons.message_outlined
                            : Icons.logout)),
                    color: item.route == '/logout' ? Colors.red : AppColors.primary,
                    size:  30,
                  ),
                  SizedBox(width: 14.w),
                  // Display the item name
                  Text(
                    itemName ?? '',
                    style: TextStyle(
                      color: item.route == '/logout' ?Colors.red :AppColors.primaryTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/icons/ang.png',
                    width: 15.w,
                    height: 15.w,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, size: 15.w);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: Obx(
        () => controller.state.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  myInfo(controller.state.headDetails.value!),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (ctx, item) =>
                          meItem(controller.state.meListItem[item]),
                      itemCount: controller.state.meListItem.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
