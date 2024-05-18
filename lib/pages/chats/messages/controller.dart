// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_up/common/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:randomstring_dart/randomstring_dart.dart';

import '../../../common/store/store.dart';
import '/common/entities/entities.dart';
import 'state.dart';

class MessagesController extends GetxController {
  MessagesController();

  final token = UserStore.to.token;
  final userProfile = UserStore.to.profile;

  MessagesState state = MessagesState();
  final textController = TextEditingController();
  ScrollController msgScrolling = ScrollController();
  FocusNode contentNode = FocusNode();
  final rs = RandomString();

  final userId = UserStore.to.token;
  final db = FirebaseFirestore.instance;

  dynamic documentId;
  dynamic messageListener;

  File? _photo;

  @override
  void onInit() async {
    super.onInit();
    final item = Get.parameters;
    state.toName.value = item['to_name'] ?? '';
    state.toUid.value = item['to_uid'] ?? '';
    state.toLocation.value = '';
    state.toAvatar.value = item['to_avatar'] ?? '';
    Timer.periodic(const Duration(seconds: 1), (timer) {
      state.currentTime.value = Timestamp.now();
    });
    textController.addListener(() {
      state.isEmpty.value = textController.text.trim().isEmpty;
    });
    
  }

  @override
  void onReady() async {
    super.onReady();
    await startChat();
    await getMessages();
  }

  getMessages() async {
    var message = db
        .collection('message')
        .doc(documentId)
        .collection('msgList')
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msgcontent, options) =>
                msgcontent.toFirestore())
        .orderBy('addtime', descending: false);
    state.msgcontentList.clear();
    messageListener = message.snapshots().listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            if (change.doc.data() != null) {
              state.msgcontentList.insert(0, change.doc.data()!);
              if (change.doc.data()!.uid != userId) {
                change.doc.reference.update({'isRead': true});
              }
            }
            break;
          case DocumentChangeType.modified:
            break;
          case DocumentChangeType.removed:
            break;
        }
      }
    },
        onError: (error) => Get.snackbar(
              'Error',
              'An error occurred: $error',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            ));
    for (var element in state.msgcontentList) {
      if (element.uid != userId && element.isRead == false) {
        element.isRead = true;
      }
    }
    var msgListSnapshot = await db
        .collection('message')
        .doc(documentId)
        .collection('msgList')
        .get();
    for (var doc in msgListSnapshot.docs) {
      if (doc['uid'] != userId) {
        await doc.reference.update({'isRead': true});
      }
    }
  }

  @override
  void onClose() {
    msgScrolling.dispose();
    messageListener.cancel();
    super.onClose();
  }

  String duTimeLineFormat(DateTime now, DateTime dt) {
    return DateFormat.jm().format(dt);
  }

  Future<void> imgFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      uploadFile();
    } else {
      _photo = null;
    }
  }

  Future<void> imgFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      uploadFile();
    } else {
      _photo = null;
    }
  }

  Future getImgUrl(String name) async {
    final imageLink = FirebaseStorage.instance.ref('chat').child(name);
    var imageUrl = await imageLink.getDownloadURL();
    return imageUrl;
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName =
        rs.getRandomString(numbersCount: 15) + extension(_photo!.path);
    try {
      state.isImgSending.value = true;
      final ref = FirebaseStorage.instance.ref('chat').child(fileName);
      ref.putFile(_photo!).snapshotEvents.listen((event) async {
        switch (event.state) {
          case TaskState.running:
            break;
          case TaskState.paused:
            break;
          case TaskState.success:
            String imageUrl = await getImgUrl(fileName);
            sendImageMessage(imageUrl);
          default:
            break;
        }
      });
    } catch (error) {
      print(error);
    } finally {}
  }

  sendImageMessage(String url) async {
    try {
      final imageContent = Msgcontent(
          uid: userId, content: url, type: 'image', addtime: Timestamp.now());
      state.isImgSending.value = true;

      if (url.isNotEmpty) {
        await db
            .collection('message')
            .doc(documentId)
            .collection('msgList')
            .withConverter(
                fromFirestore: Msgcontent.fromFirestore,
                toFirestore: (Msgcontent msgcontent, options) =>
                    msgcontent.toFirestore())
            .add(imageContent);

        await db.collection('message').doc(documentId).update({
          'last_msg': 'image',
          'last_time': Timestamp.now(),
          'msg_num': FieldValue.increment(1),
        });

        var userbase = await db
            .collection("users")
            .withConverter(
                fromFirestore: UserData.fromFirestore,
                toFirestore: (UserData userData, options) =>
                    userData.toFirestore())
            .where("id", isEqualTo: state.toUid.value)
            .get();
        if (userbase.docs.isNotEmpty) {
          var title = "${userProfile.displayName}";
          var body = 'image';
          var token = userbase.docs.first.data().fcmtoken;
          if (token != null) {
            sendNotification(title, body, token);
          }
        }
      }
    } catch (error) {
      print(error);
    } finally {
      state.isImgSending.value = false;
    }
  }

  Future<void> startChat() async {
    try {
      state.isSending.value = true;
      const Duration timeoutDuration = Duration(seconds: 10);

      var fromMessages = await db
          .collection('message')
          .withConverter(
              fromFirestore: Msg.fromFirestore,
              toFirestore: (Msg msg, options) => msg.toFirestore())
          .where('from_uid', isEqualTo: token)
          .where('to_uid', isEqualTo: state.toUid.value)
          .get()
          .timeout(timeoutDuration);

      var toMessages = await db
          .collection('message')
          .withConverter(
              fromFirestore: Msg.fromFirestore,
              toFirestore: (Msg msg, options) => msg.toFirestore())
          .where('from_uid', isEqualTo: state.toUid.value)
          .where('to_uid', isEqualTo: token)
          .get()
;
      if (fromMessages.docs.isEmpty && toMessages.docs.isEmpty) {
        String profile = await UserStore.to.getProfile();
        UserLoginResponseEntity userdata =
            UserLoginResponseEntity.fromJson(jsonDecode(profile));

        var msgData = Msg(
          fromUid: userdata.accessToken,
          toUid: state.toUid.value,
          fromName: userdata.displayName,
          toName: state.toName.value,
          fromAvatar: userdata.photoUrl,
          toAvatar: state.toAvatar.value,
          lastMsg: '',
          lastTime: Timestamp.now(),
          msgNum: 0,
        );

        var docRef = await db
            .collection('message')
            .withConverter(
                fromFirestore: Msg.fromFirestore,
                toFirestore: (Msg msg, options) => msg.toFirestore())
            .add(msgData)
;
        documentId = docRef.id;
      } else {
        if (fromMessages.docs.isNotEmpty) {
          documentId = fromMessages.docs.first.id;
        }

        if (toMessages.docs.isNotEmpty) {
          documentId = toMessages.docs.first.id;
        }
      }
    } catch (error) {
      if (error is TimeoutException) {
        Get.snackbar(
          'Timeout Error',
          'The operation took too long. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        // Handle other errors
        Get.snackbar(
          'Error',
          'An error occurred: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      state.isSending.value = false;
    }
  }

  sendScheduledMessage() async {
    try {
      state.isSending.value = true;

      String sendContent = textController.text;
      final content = Msgcontent(
        uid: userId,
        content: sendContent.trim(),
        type: 'text',
        addtime: state.selectedTimestamp,
      );

      textController.clear();
      Get.focusScope?.unfocus();

      if (sendContent.isNotEmpty) {
        await db
            .collection('message')
            .doc(documentId)
            .collection('msgList')
            .withConverter(
                fromFirestore: Msgcontent.fromFirestore,
                toFirestore: (Msgcontent msgcontent, options) =>
                    msgcontent.toFirestore())
            .add(content)
            .then((value) {});

        Future.delayed(
          Duration(milliseconds: calculateDelay()),
          () async {
            await db.collection('message').doc(documentId).update({
              'last_msg': sendContent.trim(),
              'last_time': state.selectedTimestamp,
              'msg_num': FieldValue.increment(1),
            });
          },
        );

        var userbase = await db
            .collection("users")
            .withConverter(
                fromFirestore: UserData.fromFirestore,
                toFirestore: (UserData userData, options) =>
                    userData.toFirestore())
            .where("id", isEqualTo: state.toUid.value)
            .get();

        // Delay execution of the notification part
        Future.delayed(
          Duration(milliseconds: calculateDelay()),
          () {
            if (userbase.docs.isNotEmpty) {
              var title = "${userProfile.displayName}";
              var body = sendContent;
              var token = userbase.docs.first.data().fcmtoken;
              print(userbase.docs.first.data().name);

              if (token != null &&
                  userbase.docs.first.data().name == state.toName.value) {
                sendNotification(title, body, token);
              }
            }
          },
        );
        toastInfo(msg: 'Message sent!');
      }
    } catch (error) {
      if (error is TimeoutException) {
        Get.snackbar(
          'Timeout Error',
          'The message took too long. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        textController.clear();
        Get.focusScope?.unfocus();
      } else {
        Get.snackbar(
          'Error',
          'An error occurred: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        textController.clear();
        Get.focusScope?.unfocus();
      }
    } finally {
      state.isSending.value = false;
    }
  }

  int calculateDelay() {
    DateTime currentTime = DateTime.now();
    DateTime selectedTime = state.selectedTimestamp!
        .toDate(); // Assuming state.selectedTimestamp is a Firebase Timestamp

    int milliseconds = selectedTime.difference(currentTime).inMilliseconds;
    return milliseconds < 2 ? 0 : milliseconds; // Ensure delay is not negative
  }

  sendMessage() async {
    try {
      state.isSending.value = true;

      String sendContent = textController.text;
      final content = Msgcontent(
        uid: userId,
        content: sendContent.trim(),
        type: 'text',
        addtime: Timestamp.now(),
      );

      textController.clear();
      Get.focusScope?.unfocus();

      if (sendContent.isNotEmpty) {
        await db
            .collection('message')
            .doc(documentId)
            .collection('msgList')
            .withConverter(
                fromFirestore: Msgcontent.fromFirestore,
                toFirestore: (Msgcontent msgcontent, options) =>
                    msgcontent.toFirestore())
            .add(content)
            .then((value) {})
;
        await db.collection('message').doc(documentId).update({
          'last_msg': sendContent.trim(),
          'last_time': Timestamp.now(),
          'msg_num': FieldValue.increment(1),
        });

        var userbase = await db
            .collection("users")
            .withConverter(
                fromFirestore: UserData.fromFirestore,
                toFirestore: (UserData userData, options) =>
                    userData.toFirestore())
            .where("id", isEqualTo: state.toUid.value)
            .get();
        if (userbase.docs.isNotEmpty) {
          var title = "${userProfile.displayName}";
          var body = sendContent;
          var token = userbase.docs.first.data().fcmtoken;
          print(userbase.docs.first.data().name);

          if (token != null &&
              userbase.docs.first.data().name == state.toName.value) {
            sendNotification(title, body, token);
          }
        }
      }
    } catch (error) {
      if (error is TimeoutException) {
        Get.snackbar(
          'Timeout Error',
          'The message took too long. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        textController.clear();
        Get.focusScope?.unfocus();
      } else {
        Get.snackbar(
          'Error',
          'An error occurred: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        textController.clear();
        Get.focusScope?.unfocus();
      }
    } finally {
      state.isSending.value = false;
    }
  }

  Future<void> sendNotification(String title, String body, String token) async {
    const String url = 'https://fcm.googleapis.com/fcm/send';
    var notification = json.encode({
      'notification': {
        'body': body,
        'title': title,
        'content_available': true, // Should be boolean true
      },
      'priority': 'high',
      'to': token,
      'data': {
        'to_uid': userId,
        'to_name': userProfile.displayName,
        'to_avatar': userProfile.photoUrl,
      },
    });
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Keep-Alive": "timeout=5",
          "Authorization":
              "key=AAAAiSySLDw:APA91bECV-BQibhIlHtcRMyW99FPJIPKenTHADWKKD5ozBpGOwg5WeCtGWbAJOahEgYX40QeVr0ePWtgaKY1AWQWaIxL4u-XrEiQaQZ2d2I5k77G_cRUvn7wDauHzVeIgEJlOWWwTHKf",
        },
        body: notification);
    print(response.body);
  }
}
