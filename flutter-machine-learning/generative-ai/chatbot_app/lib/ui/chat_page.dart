import 'package:chatbot_app/controller/gemini_controller.dart';
import 'package:chatbot_app/controller/photo_controller.dart';
import 'package:chatbot_app/ui/image_selected_page.dart';
import 'package:chatbot_app/widget/list_view_chats.dart';
import 'package:chatbot_app/widget/text_field_sender.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  static const path = "/";

  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Chatbot App'),
      ),
      body: SafeArea(child: const _ChatBody()),
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody();

  @override
  Widget build(BuildContext context) {
    final padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8);
    return Column(
      spacing: 4,
      children: [
        Expanded(
          child: Consumer<GeminiController>(
            builder: (_, gemini, _) {
              return ListViewChats(chats: gemini.historyChats);
            },
          ),
        ),
        Consumer<GeminiController>(
          builder: (_, gemini, _) {
            final isLoading = gemini.isLoading;
            return isLoading ? LinearProgressIndicator() : SizedBox();
          },
        ),
        Padding(
          padding: padding,
          child: TextFieldSender(
            galleryOnPressed: () async {
              final photo = context.read<PhotoController>();
              final navigator = Navigator.of(context);

              await photo.getPhoto();

              final paths = photo.paths;
              if (paths != null && paths.isNotEmpty) {
                navigator.pushNamed(ImageSelectedPage.path);
              }
            },
            sendOnPressed: (message) {
              context.read<GeminiController>().sendMessage(message);
            },
          ),
        ),
      ],
    );
  }
}
