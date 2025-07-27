import 'package:chatbot_app/model/chat.dart';
import 'package:chatbot_app/widget/message_bubble_widget.dart';
import 'package:flutter/material.dart';

class ListViewChats extends StatelessWidget {
  final List<Chat> chats;

  const ListViewChats({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final item = chats[index];
        return MessageBubble(
          content: item.text,
          isMyChat: item.isMyChat,
          imagePath: item.paths,
        );
      },
    );
  }
}
