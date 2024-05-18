import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../../../common/styles/colors.dart';
import 'controller.dart';

class PhotoImageView extends GetView<PhotoImageViewController> {
  const PhotoImageView({super.key});

  AppBar _buildAppbar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          height: 2.0,
        ),
      ),
      title: Text(
        'Photoview',
        style: TextStyle(
            color: AppColors.bodyColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.normal),
      ),
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: PhotoView(imageProvider: NetworkImage(controller.state.url.value)),
    );
  }
}
