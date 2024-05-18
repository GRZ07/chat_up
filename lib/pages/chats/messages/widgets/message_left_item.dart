import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/routes/names.dart';
import '../../../../common/styles/colors.dart';
import '/common/entities/entities.dart';

Widget messageLeftItem(Msgcontent item, String time) {
  return Container(
    padding: EdgeInsets.only(top: 4.w, left: 8.w, bottom: 4.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 230.w),
          child: Container(
            margin: EdgeInsets.only(right: 10.w, top: 0.w),
            padding: item.type == 'text'
                ? EdgeInsets.only(
                    top: 10.w, left: 10.w, bottom: 10.w, right: 10.w)
                : EdgeInsets.all(5.w),
            decoration: const BoxDecoration(
              color:
                  AppColors.chatbg, // Set the background color to a light grey
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: item.type == 'text'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.content}',
                        maxLines: null,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      Text(
                        time,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: AppColors.primaryTextColor,
                          fontSize: 7.sp,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        padding: EdgeInsets.only(left: 8.0.w, top: 2.h),
                        child: Text(
                          time,
                          style: TextStyle(
                            color: AppColors.primaryTextColor,
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
