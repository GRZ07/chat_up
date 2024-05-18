import 'package:flutter/material.dart';

import '../../common/widgets/appbar.dart';
import 'widgets/chat_list.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  AppBar _buildAppBar() {
    return mainAppBar(title: 'Chats');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: const ChatsList(),
    );
  }
}
