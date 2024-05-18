import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../common/styles/values.dart';
import '/pages/sign_in/index.dart';

class SignInPage extends GetView<SignInController> {
  const SignInPage({super.key});

  Widget _buildLogo() {
    return Container(
      width: 110.w,
      margin: EdgeInsets.only(top: 84.h),
      child: Column(
        children: [
          Container(
            width: 76.w,
            height: 76.w,
            margin: EdgeInsets.symmetric(horizontal: 15.w),
            child: Stack(
              children: [
                Positioned(
                  child: Container(
                    height: 76.w,
                    decoration: const BoxDecoration(
                      color: AppColors.bodyColor,
                      boxShadow: [Shadows.primaryShadow],
                      borderRadius: BorderRadius.all(Radius.circular(35)),
                    ),
                  ),
                ),
                Positioned(
                  child: Image.asset(
                    'assets/images/ic_launcher.png',
                    width: 76.w,
                    height: 76.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 15.h, bottom: 15.h),
            child: Text(
              'Chatup',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                height: 1,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildThirdPartyLogin() {
    return Container(
      margin: EdgeInsets.only(top: 10.h, bottom: 280.h),
      width: 295.w,
      child: Column(
        children: [
          Text(
            'Continue with your account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 16.sp,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.h, left: 50.w, right: 50.w),
            child: ElevatedButton.icon(
              onPressed: () => controller.handleSignIn(),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(AppColors.elementColor),
                  fixedSize: MaterialStateProperty.all(const Size(300, 50))),
              icon: const FaIcon(
                FontAwesomeIcons.google,
                color: AppColors.bodyColor,
              ),
              label: const Text(
                '   Google account',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(
      () => controller.state.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  _buildLogo(),
                  const Divider(
                    indent: 50,
                    endIndent: 50,
                  ),
                  _buildThirdPartyLogin()
                ],
              ),
            ),
    ));
  }
}
