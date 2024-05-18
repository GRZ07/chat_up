import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../common/styles/colors.dart';
import '../controller.dart';
import 'message_left_item.dart';
import 'message_right_item.dart';

class ChatList extends GetView<MessagesController> {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        List<dynamic> msgcontentList = controller.state.msgcontentList;

        Map<DateTime, List<dynamic>> groupedMessages = {};

        for (var item in msgcontentList) {
          DateTime messageDate = (item.addtime as Timestamp).toDate();

          DateTime formattedDate = DateTime(
            messageDate.year,
            messageDate.month,
            messageDate.day,
          );

          if (groupedMessages.containsKey(formattedDate)) {
            groupedMessages[formattedDate]?.add(item);
          } else {
            groupedMessages[formattedDate] = [item];
          }
        }

        List<MapEntry<DateTime, List<dynamic>>> dateGroups =
            groupedMessages.entries.toList();

        dateGroups.sort((a, b) => b.key.compareTo(a.key));

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Container(
            color: AppColors.bodyColor,
            child: CustomScrollView(
              reverse: true,
              controller: controller.msgScrolling,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 0.w, horizontal: 0.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        MapEntry<DateTime, List<dynamic>> dateGroup =
                            dateGroups[index];

                        String formattedDate =
                            DateFormat('dd MMM yyyy').format(dateGroup.key);

                        Widget dateHeader = Container(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          margin: EdgeInsets.only(top: 5.0.h),
                          child: Center(
                            child: Text(
                              formattedDate,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );

                        List<Widget> messageItems = dateGroup.value.map((item) {
                          if (controller.state.currentTime.value
                                  .toDate()
                                  .difference(
                                    (item.addtime as Timestamp).toDate(),
                                  )
                                  .inSeconds <=
                              -2) {
                            return Container();
                          } else {
                            if (controller.userId == item.uid) {
                              return Obx(() => messageRightItem(
                                    item,
                                    controller.state.isSending.value,
                                    controller.duTimeLineFormat(
                                      controller.state.currentTime.value
                                          .toDate(),
                                      (item.addtime as Timestamp).toDate(),
                                    ),
                                  ));
                            } else {
                              return messageLeftItem(
                                item,
                                controller.duTimeLineFormat(
                                  controller.state.currentTime.value.toDate(),
                                  (item.addtime as Timestamp).toDate(),
                                ),
                              );
                            }
                          }
                        }).toList();

                        List<Widget> combinedItems = [
                          ...messageItems,
                          dateHeader
                        ];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: combinedItems.reversed.toList(),
                        );
                      },
                      childCount: dateGroups.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
