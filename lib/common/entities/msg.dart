import 'package:cloud_firestore/cloud_firestore.dart';

class Msg {
  final String? fromUid;
  final String? toUid;
  final String? fromName;
  final String? toName;
  final String? fromAvatar;
  final String? toAvatar;
  String? lastMsg;
  Timestamp? lastTime;
  final int? msgNum;

  Msg({
    this.fromUid,
    this.toUid,
    this.fromName,
    this.toName,
    this.fromAvatar,
    this.toAvatar,
    this.lastMsg,
    this.lastTime,
    this.msgNum,
  });

  factory Msg.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Msg(
      fromUid: data?['from_uid'],
      toUid: data?['to_uid'],
      fromName: data?['from_name'],
      toName: data?['to_name'],
      fromAvatar: data?['from_avatar'],
      toAvatar: data?['to_avatar'],
      lastMsg: data?['last_msg'],
      lastTime: data?['last_time'],
      msgNum: data?['msg_num'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (fromUid != null) "from_uid": fromUid,
      if (toUid != null) "to_uid": toUid,
      if (fromName != null) "from_name": fromName,
      if (toName != null) "to_name": toName,
      if (fromAvatar != null) "from_avatar": fromAvatar,
      if (toAvatar != null) "to_avatar": toAvatar,
      if (lastMsg != null) "last_msg": lastMsg,
      if (lastTime != null) "last_time": lastTime,
      if (msgNum != null) "msg_num": msgNum,
    };
  }
}
