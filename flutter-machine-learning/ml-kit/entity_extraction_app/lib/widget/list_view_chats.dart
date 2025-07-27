import 'package:entity_extraction_app/model/chat.dart';
import 'package:entity_extraction_app/widget/message_bubble_widget.dart';
import 'package:flutter/material.dart';

class ListViewChats extends StatelessWidget {
  final List<Chat> _chats;

  ListViewChats({super.key, List<Chat>? chats}) : _chats = chats ?? listOfChat;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final item = _chats[index];
        return MessageBubble(
          content: item.text,
          sender: item.emailSender,
          isMyChat: item.isMyChat,
        );
      },
    );
  }
}
