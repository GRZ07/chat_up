import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/common/routes/names.dart';
import '/common/store/store.dart';

class RouteWelcomeMiddleware extends GetMiddleware {
  @override
  // ignore: overridden_fields
  int? priority = 0;

  RouteWelcomeMiddleware({required this.priority});

  @override
  RouteSettings? redirect(String? route) {
    if (ConfigStore.to.isFirstOpen == false) {
      return null;
    } else if (UserStore.to.isLogin == true) {
      return const RouteSettings(name: AppRoutes.application);
    } else {
      return const RouteSettings(name: AppRoutes.signin);
    }
  }
}
