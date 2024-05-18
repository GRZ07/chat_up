// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '/common/entities/entities.dart';
import '/common/store/user.dart';
import 'index.dart';

class AccountsController extends GetxController {
  AccountsController();

  final state = AccountsState();
  final db = FirebaseFirestore.instance;
  final token = UserStore.to.token;

  

  final RefreshController refreshController = RefreshController(
    initialRefresh: true,
  );

  void onRefresh() {
    asyncLoadAllData().then((_) {
      refreshController.refreshCompleted(resetFooterState: true);
    }).catchError((_) {
      refreshController.refreshFailed();
    });
  }

  asyncLoadAllData() async {
    try {
      state.accountsList.value = [];

      var usersbase = await db
          .collection('users')
          .where('id', isNotEqualTo: token)
          .withConverter(
              fromFirestore: UserData.fromFirestore,
              toFirestore: (UserData userdata, options) =>
                  userdata.toFirestore())
          .orderBy('name', descending: false)
          .orderBy('id', descending: false)
          .get();
      for (var doc in usersbase.docs) {
        var data = doc.data();
        if (!state.accountsList.contains(data)) {
          state.accountsList.add(data);
        }
      }
    } catch (error) {
      if (error is TimeoutException) {
        Get.snackbar(
          'Timeout Error',
          'The operation took too long. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        print(error);
      }
    }
  }
}
