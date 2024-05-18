import 'package:get/get.dart';

import '../accounts/controller.dart';
import '../profile/controller.dart';
import '../chats/controller.dart';
import 'controller.dart';


class ApplicationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplicationController>(() => ApplicationController());
    Get.lazyPut<AccountsController>(() => AccountsController());
    Get.lazyPut<ChatsController>(() => ChatsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
