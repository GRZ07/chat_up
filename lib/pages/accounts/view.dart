import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/appbar.dart';
import 'index.dart';
import 'widgets/accounts_list.dart';

class AccountsPage extends GetView<AccountsController> {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppBar buildAppBar() {
      return mainAppBar(
        title: 'Accounts',
      );
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: const AccountsList(),
    );
  }
}
