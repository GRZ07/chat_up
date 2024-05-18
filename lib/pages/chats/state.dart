import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '/common/entities/entities.dart';

class ChatsState {
  RxList<QueryDocumentSnapshot<Msg>> msgList =
      <QueryDocumentSnapshot<Msg>>[].obs;
  var currentTime = DateTime.now().obs;
  var unread = <String, int>{}.obs;

  void resetUnreadCount(String chatKey) {
    unread[chatKey] = 0;
  }
}
