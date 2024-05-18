// ignore_for_file: avoid_print

import 'dart:async';

import 'package:chat_up/common/styles/colors.dart';
import 'package:chat_up/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'common/routes/pages.dart';
import 'common/services/storage.dart';
import 'common/store/store.dart';
import 'common/utils/notification_helper.dart';

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  print(
      '...onBackground: ${message.notification?.title}/${message.notification?.body}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync<StorageService>(() => StorageService().init());
  Get.put<ConfigStore>(ConfigStore());
  Get.put<UserStore>(UserStore());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();
  try {
    await NotificationHelper.initialize();
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  } catch (e) {
    print(e);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, Widget? child) => GetMaterialApp(
        title: 'Chatup',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, background: AppColors.bodyColor),

          useMaterial3: true,
          fontFamily: 'Avenir',
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.white, // Customize the back arrow color globally
            ),
          ),
        ),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
