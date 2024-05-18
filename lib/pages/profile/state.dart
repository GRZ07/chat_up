import 'package:get/get.dart';

import '../../common/entities/user.dart';

class ProfileState {
  var isLoading = false.obs;
  var headDetails = Rx<UserLoginResponseEntity?>(null);
  RxList<MeListItem> meListItem = <MeListItem>[].obs;
}
