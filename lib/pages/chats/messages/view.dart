import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/styles/colors.dart';
import 'controller.dart';
import 'widgets/message_list.dart';

class MessagesPage extends GetView<MessagesController> {
  const MessagesPage({super.key});

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      flexibleSpace: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
          child: AppBar(
            backgroundColor: AppColors.primary,
            title: Container(
              padding: EdgeInsets.only(top: 0.w, bottom: 5.w, right: 0.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 0.w, bottom: 0.w, right: 0.w),
                    child: InkWell(
                      onTap: () {},
                      child: SizedBox(
                        width: 40.w,
                        height: 40.w,
                        child: CircleAvatar(
                          radius: 27.r,
                          backgroundColor: Colors.transparent,
                          backgroundImage: CachedNetworkImageProvider(
                            '${controller.state.toAvatar}',
                          ),
                          child: CachedNetworkImage(
                            imageUrl: '${controller.state.toAvatar}',
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: AppColors.primary,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Container(
                    width: 200.w,
                    padding: EdgeInsets.only(top: 0.w, bottom: 0.w, right: 0.w),
                    child: SizedBox(
                      width: 180.w,
                      height: 40.w,
                      child: GestureDetector(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.state.toName.value,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryTextColor,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        context: context,
        builder: (BuildContext buildContext) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    controller.imgFromGallery();
                    Get.back();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    controller.imgFromCamera();
                    Get.back();
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    pickDate(BuildContext context) async {
      Get.focusScope?.unfocus();
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );

      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          final DateTime selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (selectedDateTime.isBefore(DateTime.now())) {
            // Show snackbar if the selected time is in the past
            Get.snackbar(
              'Invalid Time',
              'Selected date and time cannot be in the past.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return; // Exit the function if the time is in the past
          }

          final Timestamp selectedTimestamp =
              Timestamp.fromDate(selectedDateTime);
          controller.state.setTimestamp(selectedTimestamp);

          controller.sendScheduledMessage();
        }
      }
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          controller.state.isSending.value
              ? Container()
              : const Expanded(child: ChatList()),
          Container(
            margin: EdgeInsets.only(top: 5.h, bottom: 5.h, left: 10.w),
            color: AppColors.transparent,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.chatbg,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      constraints: BoxConstraints(
                        minHeight: 50.h,
                        maxHeight: 120.h,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                controller: controller.textController,
                                autofocus: false,
                                focusNode: controller.contentNode,
                                decoration: const InputDecoration(
                                  hintText: 'Send a message',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.w),
                            child: IconButton(
                              icon: Icon(
                                Icons.photo,
                                size: 30.w,
                                color: AppColors.elementColor,
                              ),
                              onPressed: () {
                                _showPicker(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: GestureDetector(
                      onTap: () {
                        if (!controller.state.isEmpty.value &&
                            !controller.state.isSending.value) {
                          controller.sendMessage();
                        }
                      },
                      onLongPress: () {
                        if (!controller.state.isEmpty.value &&
                            !controller.state.isSending.value) {
                          pickDate(context);
                        }
                      },
                      child: Obx(
                        () => Container(
                          decoration: const BoxDecoration(
                            color: AppColors.transparent,
                          ),
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.send,
                            color: controller.state.isEmpty.value ||
                                    controller.state.isSending.value
                                ? AppColors.hintTextColor
                                : AppColors.elementColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
