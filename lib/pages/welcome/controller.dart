import 'package:get/get.dart';

import '../../common/routes/names.dart';
import '/common/store/config.dart';


class WelcomeController extends GetxController {
  WelcomeController();
  handleSignIn() async {
    await ConfigStore.to.saveAlreadyOpen();
    Get.offAndToNamed(AppRoutes.signin);
  }
}