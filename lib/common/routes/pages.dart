import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/accounts/index.dart';
import '../../pages/application/index.dart';
import '../../pages/chats/index.dart';
import '../../pages/chats/messages/index.dart';
import '../../pages/chats/photoview/index.dart';
import '../../pages/profile/index.dart';
import '../../pages/sign_in/index.dart';
import '../../pages/welcome/index.dart';
import '/common/middlewares/middlewares.dart';
import 'names.dart';

class AppPages {
  static const initial = AppRoutes.initial;
  static const application = AppRoutes.application;
  static final RouteObserver<Route> observer = RouteObserver();
  static List<String> history = [];

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.initial,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
      middlewares: [
        RouteWelcomeMiddleware(priority: 1)
      ]
    ),
    GetPage(
      name: AppRoutes.signin,
      page: () => const SignInPage(),
      binding: SignInBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
      name: AppRoutes.application,
      page: () => const ApplicationPage(),
      binding: ApplicationBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.accounts,
      page: () => const AccountsPage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatsPage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.messages,
      page: () => const MessagesPage(),
      binding: MessagesBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.photoImgView,
      page: () => const PhotoImageView(),
      binding: PhotoImageViewBinding(),
      transition: Transition.size,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
