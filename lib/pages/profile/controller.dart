// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../common/entities/entities.dart';
import '../../common/routes/names.dart';
import '../../common/store/user.dart';
import '../../common/utils/notification_helper.dart';
import 'state.dart';

class ProfileController extends GetxController {
  final state = ProfileState();
  ProfileController();
  late PageController profilePageController;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly']);

  @override
  void onInit() async {
    super.onInit();
    state.isLoading.value = true;

    await asyncLoadAllData();
    List myList = [
      {'name': 'Accounts', 'route': '/accounts'},
      {'name': 'Chat', 'route': '/chat'},
      {'name': 'Logout', 'route': '/logout'},
    ];

    for (int i = 0; i < myList.length; i++) {
      MeListItem result = MeListItem();
      result.icon = myList[i]['icon'];
      result.name = myList[i]['name'];
      result.route = myList[i]['route'];

      state.meListItem.add(result);

      state.isLoading.value = false;
    }
  }

  asyncLoadAllData() async {
    try {
      String profile = await UserStore.to.getProfile();
      if (profile.isNotEmpty) {
        UserLoginResponseEntity userdata =
            UserLoginResponseEntity.fromJson(jsonDecode(profile));
        state.headDetails.value = userdata;
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> onLogout() async {
    UserStore.to.onLogout();

    await FirebaseMessaging.instance.deleteToken();
    await NotificationHelper.reset();

    await _googleSignIn.signOut();
    Get.offAndToNamed(AppRoutes.signin);
  }
}
