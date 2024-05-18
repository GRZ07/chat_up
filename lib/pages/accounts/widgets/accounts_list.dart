import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/routes/names.dart';
import '../../../common/styles/colors.dart';
import '../controller.dart';
import '/common/entities/user.dart';

class AccountsList extends GetView<AccountsController> {
  const AccountsList({super.key});

  Widget _buildListItem(UserData item) {
    return InkWell(
      onTap: () {
        if (item.id != null) {
          Get.toNamed(AppRoutes.messages, parameters: {
            'to_uid': item.id ?? '',
            'to_name': item.name ?? '',
            'to_avatar': item.photourl ?? '',
          });
        }
      },
      child: Container(
        padding: EdgeInsets.only(top: 10.w, left: 15.w, right: 40.w, bottom: 10.w),
        
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 0.w),
              width: 44.w,
              height: 44.w,
              child: CircleAvatar(
                radius: 27.r,
                backgroundColor: AppColors.transparent,
                backgroundImage: CachedNetworkImageProvider(
                  '${item.photourl}',
                ),
                child: CachedNetworkImage(
                  imageUrl: '${item.photourl}',
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
                    color: Colors.blue,
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            Container(
              width: 250.w,
              padding: EdgeInsets.only(
                left: 0.w,
                right: 0.w,
                bottom: 0.w,
              ),
              child:
                  SizedBox(
                    child: Text(
                      item.name ?? '',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTextColor,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  
                
              
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => SmartRefresher(
          enablePullDown: true,
          controller: controller.refreshController,
          onRefresh: controller.onRefresh,
          header: const WaterDropHeader(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 0.w, horizontal: 0.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var item = controller.state.accountsList[index];
                      return _buildListItem(item);
                    },
                    childCount: controller.state.accountsList.length,
                    addAutomaticKeepAlives: true,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
