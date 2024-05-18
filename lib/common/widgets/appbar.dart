import 'package:chat_up/common/styles/text_styles.dart';
import 'package:flutter/material.dart';

import '/common/styles/colors.dart';

AppBar mainAppBar({
  String? title,
  Widget? leading,
  List<Widget>? actions,
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          border: Border(bottom: BorderSide(width: 0.2)),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.0),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          title: title != null ? Center(child: Text(title, style: TextStyles.appBar,)) : null,
          leading: leading,
          actions: actions,
        ),
      ),
    ),
  );
}
