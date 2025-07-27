import 'package:entity_extraction_app/widget/list_view_chats.dart';
import 'package:entity_extraction_app/widget/text_field_sender.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Entity Extraction App'),
      ),
      body: SafeArea(
        child: Padding(padding: padding, child: const _ChatBody()),
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        Expanded(child: ListViewChats()),
        TextFieldSender(),
      ],
    );
  }
}
