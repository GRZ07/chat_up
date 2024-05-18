import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/entities/msg.dart';
import '../../../common/routes/names.dart';
import '../../../common/styles/values.dart';
import '../controller.dart';

class ChatsList extends GetView<ChatsController> {
  const ChatsList({super.key});
  Widget chatListItem(QueryDocumentSnapshot<Msg> item) {
    var user = item.data();
    var chatKey = '${user.fromUid}_${user.toUid}';

    return SizedBox(
      child: InkWell(
        onTap: () async {
          if (user.toUid != null) {
            await Get.toNamed(AppRoutes.messages, parameters: {
              'to_uid': user.fromUid == controller.token
                  ? user.toUid ?? ''
                  : user.fromUid ?? '',
              'to_name': user.fromUid == controller.token
                  ? user.toName ?? ''
                  : user.fromName ?? '',
              'to_avatar': user.fromUid == controller.token
                  ? user.toAvatar ?? ''
                  : user.fromAvatar ?? '',
            });
          }
          controller.state.resetUnreadCount(chatKey);
        },
        child: Container(
          width: double.infinity,
          padding:
              EdgeInsets.only(top: 5.w, bottom: 5.w, left: 10.w, right: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 45.w,
                child: CircleAvatar(
                  radius: 27.w,
                  backgroundColor: Colors.transparent,
                  backgroundImage: CachedNetworkImageProvider(
                    '${user.fromUid == controller.token ? user.toAvatar : user.fromAvatar}',
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                        '${user.fromUid == controller.token ? user.toAvatar : user.fromAvatar}',
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
              // Main content container
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  margin: EdgeInsets.symmetric(vertical: 5.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fromUid == controller.token
                            ? user.toName ?? ''
                            : user.fromName ?? '',
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTextColor,
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 2.w),
                      Text(
                        user.lastMsg ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.bold,
                          color: AppColors.hintTextColor,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 5.w, top: 5.h),
                    child: Obx(
                      () => Text(
                        controller.duTimeLineFormat(
                          controller.state.currentTime.value,
                          (user.lastTime as Timestamp).toDate(),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.normal,
                          color: AppColors.hintTextColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 0.w),
                    child: Obx(
                      () => controller.state.unread[chatKey] == 0 || controller.state.unread[chatKey] == null
                          ? Container()
                          : CircleAvatar(
                              radius: 10.w,
                              backgroundColor: AppColors.elementColor,
                              child: Text(
                                '${controller.state.unread[chatKey]}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.bodyColor,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SmartRefresher(
        enablePullDown: true,
        controller: controller.refreshController,
        onRefresh: controller.onRefresh,
        header: const WaterDropHeader(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var item = controller.state.msgList[index];
                  return chatListItem(item);
                }, childCount: controller.state.msgList.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
