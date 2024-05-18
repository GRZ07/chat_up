import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../common/entities/msgcontent.dart';

class MessagesState {
  var isEmpty = true.obs;
  var isSending = false.obs;
  final isImgSending = false.obs;
  var currentTime = Timestamp.now().obs;
  var isLate = false.obs;

  RxList<Msgcontent> msgcontentList = <Msgcontent>[].obs;
  var toUid = ''.obs;
  var toName = ''.obs;
  var toAvatar = ''.obs;
  var toLocation = 'unknown'.obs;

  Timestamp? _selectedTimestamp;

  Timestamp? get selectedTimestamp => _selectedTimestamp;

  void setTimestamp(Timestamp timestamp) {
    _selectedTimestamp = timestamp;
  }
}
