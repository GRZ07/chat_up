import 'package:get/get.dart';

import '/common/entities/entities.dart';

class AccountsState {
  var count = 0.obs;
  final isLoading = false.obs;
  RxList<UserData> accountsList = <UserData> [].obs;
}
