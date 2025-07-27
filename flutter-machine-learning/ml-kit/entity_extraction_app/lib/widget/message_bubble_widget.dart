import 'package:entity_extraction_app/controller/message_provider.dart';
import 'package:entity_extraction_app/service/entity_extraction_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final String sender;
  final bool isMyChat;

  const MessageBubble({
    super.key,
    required this.content,
    required this.sender,
    this.isMyChat = false,
  });

  final textStyle = const TextStyle(color: Colors.black54, fontSize: 12.0);

  final senderBorderRadius = const BorderRadius.only(
    topLeft: Radius.circular(20),
    bottomLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );

  final otherBorderRadius = const BorderRadius.only(
    topRight: Radius.circular(20),
    topLeft: Radius.circular(20),
    bottomRight: Radius.circular(20),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMyChat
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(sender, style: textStyle),
          Card(
            color: isMyChat ? Colors.green.shade100 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: isMyChat ? senderBorderRadius : otherBorderRadius,
            ),
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: ChangeNotifierProvider(
                create: (context) =>
                    MessageProvider(context.read<EntityExtractionService>())
                      ..extractText(content),
                child: MessageBubbleText(text: content),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubbleText extends StatelessWidget {
  final String text;
  const MessageBubbleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, value, child) {
        final isExtracting = value.isExtracting;
        if (isExtracting) {
          return Center(child: LinearProgressIndicator());
        }

        final listOfEntityAnnotation = value.listOfEntityAnnotation;
        return RichText(
          text: TextSpan(
            children: _getTextSpans(listOfEntityAnnotation),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
    );
  }

  List<TextSpan> _getTextSpans(List<EntityAnnotation> entities) {
    List<TextSpan> textSpans = <TextSpan>[];
    int i = 0;
    int pos = 0;

    while (i < text.length) {
      textSpans.add(
        _text(
          text.substring(
            i,
            pos < entities.length && i <= entities[pos].start
                ? entities[pos].start
                : text.length,
          ),
        ),
      );
      if (pos < entities.length && i <= entities[pos].start) {
        textSpans.add(
          _text(
            text.substring(entities[pos].start, entities[pos].end),
            entities[pos].entities.first.type.name,
          ),
        );
        i = entities[pos].end;
        pos++;
      } else {
        i = text.length;
      }
    }
    return textSpans;
  }

  TextSpan _text(String text, [String? type]) {
    final withoutType = type == null;
    return TextSpan(
      text: text,
      style: TextStyle(color: withoutType ? Colors.black : Colors.blue),
      recognizer: withoutType ? null : TapGestureRecognizer()
        ?..onTap = () {
          _entityAction(text, type!);
        },
    );
  }

  Future<void> _launchUrl(Uri uri) async {
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  void _entityAction(String text, String type) async {
    final uri = switch (type) {
      "url" => text.substring(0, 4) == 'http' ? text : 'https://$text',
      "email" => text.substring(0, 7) == 'mailto:' ? text : 'mailto:$text',
      "phone" => text.substring(0, 4) == 'tel:' ? text : 'tel:$text',
      _ => text,
    };
    await _launchUrl(Uri.parse(uri));
  }
}
