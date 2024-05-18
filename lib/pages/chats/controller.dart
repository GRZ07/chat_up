import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../common/entities/entities.dart';
import '../../common/store/user.dart';
import '/common/routes/names.dart';
import 'index.dart';

class ChatsController extends GetxController {
  ChatsController();

  ChatsState state = ChatsState();

  final token = UserStore.to.token;
  final db = FirebaseFirestore.instance;

  dynamic fromMessageSubscriptionListner;
  dynamic toMessageSubscriptionListner;

  @override
  void onInit() {
    super.onInit();
    Timer.periodic(const Duration(minutes: 1), (timer) {
      state.currentTime.value = DateTime.now();
    });
  }

  @override
  void onReady() async {
    super.onReady();
    getFcmToken();

    var fromMessageSubscription = db
        .collection('message')
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where('from_uid', isEqualTo: token)
        .where('msg_num', isNotEqualTo: 0);

    fromMessageSubscriptionListner = fromMessageSubscription
        .snapshots()
        .listen((QuerySnapshot<Msg> snapshot) async {
      for (final doc in snapshot.docs) {
        final existingIndex =
            state.msgList.indexWhere((msg) => msg.id == doc.id);
        if (existingIndex != -1) {
          state.msgList[existingIndex] = doc;
        } else {
          state.msgList.add(doc);
        }
        var msgListSnapshot = await db
            .collection('message')
            .doc(doc.id)
            .collection('msgList')
            .get();
        int unreadCount = 0;
        for (var msgDoc in msgListSnapshot.docs) {
          if (msgDoc['uid'] != token && msgDoc['isRead'] == false) {
            unreadCount++;
          }
        }
        state.unread['${doc.data().fromUid}_${doc.data().toUid}'] = unreadCount;
      }
      state.msgList.sort((a, b) {
        Msg msgA = a.data();
        Msg msgB = b.data();

        int lastTimeA = msgA.lastTime?.millisecondsSinceEpoch ?? 0;
        int lastTimeB = msgB.lastTime?.millisecondsSinceEpoch ?? 0;

        return lastTimeB.compareTo(lastTimeA);
      });
    });

    var toMessageSubscription = db
        .collection('message')
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where('to_uid', isEqualTo: token)
        .where('msg_num', isNotEqualTo: 0);

    toMessageSubscriptionListner = toMessageSubscription
        .snapshots()
        .listen((QuerySnapshot<Msg> snapshot) async {
      for (final doc in snapshot.docs) {
        final existingIndex =
            state.msgList.indexWhere((msg) => msg.id == doc.id);
        if (existingIndex != -1) {
          state.msgList[existingIndex] = doc;
        } else {
          state.msgList.add(doc);
        }
        var msgListSnapshot = await db
            .collection('message')
            .doc(doc.id)
            .collection('msgList')
            .get();
        int unreadCount = 0;
        for (var msgDoc in msgListSnapshot.docs) {
          if (msgDoc['uid'] != token && msgDoc['isRead'] == false) {
            unreadCount++;
          }
        }
        state.unread['${doc.data().fromUid}_${doc.data().toUid}'] = unreadCount;
      }
      state.msgList.sort((a, b) {
        Msg msgA = a.data();
        Msg msgB = b.data();

        int lastTimeA = msgA.lastTime?.millisecondsSinceEpoch ?? 0;
        int lastTimeB = msgB.lastTime?.millisecondsSinceEpoch ?? 0;

        return lastTimeB.compareTo(lastTimeA);
      });
    });
  }

  @override
  void onClose() {
    fromMessageSubscriptionListner.cancel();
    toMessageSubscriptionListner.cancel();
    super.onClose();
  }

  final RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  void onRefresh() {
    asyncLoadAllData().then((_) {
      refreshController.refreshCompleted(resetFooterState: true);
    }).catchError((_) {
      refreshController.refreshFailed();
    });
  }

  String duTimeLineFormat(DateTime now, DateTime dt) {
    var difference = now.difference(dt);

    if (difference.inMinutes < 1) {
      return "now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return DateFormat.jm().format(dt); // Format to display time only
    } else if (difference.inDays < 2) {
      return "Yesterday";
    } else if (difference.inDays < 365) {
      return DateFormat('M/d/yy')
          .format(dt); // Format to display date like 5/11/24
    } else {
      return DateFormat('yyyy-MM-dd').format(dt);
    }
  }

  asyncLoadAllData() async {
    var fromMessageQuery = db
        .collection('message')
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where('from_uid', isEqualTo: token)
        .where('msg_num', isNotEqualTo: 0);

    var toMessageQuery = db
        .collection('message')
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where('to_uid', isEqualTo: token)
        .where('msg_num', isNotEqualTo: 0);

    Set<String> uniqueIds = {};
    state.msgList.clear();

    var fromMessage = await fromMessageQuery.get();
    for (var doc in fromMessage.docs) {
      if (uniqueIds.add(doc.id)) {
        state.msgList.add(doc);
      }
    }

    var toMessage = await toMessageQuery.get();
    for (var doc in toMessage.docs) {
      if (uniqueIds.add(doc.id)) {
        state.msgList.add(doc);
      }
    }
    state.msgList.sort((a, b) {
      Msg msgA = a.data();
      Msg msgB = b.data();

      // Get the lastTime as milliseconds since epoch
      int lastTimeA = msgA.lastTime?.millisecondsSinceEpoch ?? 0;
      int lastTimeB = msgB.lastTime?.millisecondsSinceEpoch ?? 0;

      // Compare the two times
      return lastTimeB.compareTo(lastTimeA);
    });
  }

  getFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      var user =
          await db.collection("users").where('id', isEqualTo: token).get();
      if (user.docs.isNotEmpty) {
        var docId = user.docs.first.id;
        await db.collection('users').doc(docId).update({'fcmtoken': fcmToken});
      }
    }

    await FirebaseMessaging.instance.requestPermission(
        sound: true,
        badge: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      bool hasNavigated = false;

      if (message.data.isNotEmpty) {
        if (!hasNavigated) {
          var toUid = message.data['to_uid'];
          var toName = message.data['to_name'];
          var toAvatar = message.data['to_avatar'];
          Get.toNamed(AppRoutes.messages, parameters: {
            'to_uid': toUid,
            'to_name': toName,
            'to_avatar': toAvatar,
          });
        }
      }
    });
  }
}
