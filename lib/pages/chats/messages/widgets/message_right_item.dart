import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_up/common/styles/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/routes/names.dart';
import '/common/entities/entities.dart';

Widget messageRightItem(Msgcontent item, bool isSending, String time) {
  return Container(
    padding: EdgeInsets.only(
      top: 4.w,
      right: 8.w,
      bottom: 4.w,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 230.w),
          child: Container(
            padding: item.type == 'text'
                ? EdgeInsets.only(
                    top: 10.w, left: 10.w, bottom: 10.w, right: 10.w)
                : EdgeInsets.all(5.w),
            decoration: const BoxDecoration(
              color: AppColors.elementColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: item.type == 'text'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Text widget for message content
                      Text(
                        '${item.content}',
                        maxLines: null,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      Text(
                        time,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: AppColors.secondaryTextColor,
                          fontSize: 7.sp,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.w),
                          color: Colors.black,
                        ),
                        width: 230.w,
                        height: 230.w,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: 230.w, maxHeight: 230.w),
                          child: GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.photoImgView,
                                  parameters: {'url': item.content ?? ''});
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.w),
                              child: CachedNetworkImage(
                                imageUrl: '${item.content}',
                                fit: BoxFit.fill,
                                placeholder: (context, url) => const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8.0.w, top: 2.h),
                        child: Text(
                          time,
                          style: TextStyle(
                            color: AppColors.secondaryTextColor,
                            fontSize: 7.sp,
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
