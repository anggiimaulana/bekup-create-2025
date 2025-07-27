import 'package:flutter/material.dart';

class TextFieldSender extends StatefulWidget {
  const TextFieldSender({super.key});

  @override
  State<TextFieldSender> createState() => _TextFieldSenderState();
}

class _TextFieldSenderState extends State<TextFieldSender> {
  final contentController = TextEditingController();

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: contentController,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 4),
        DecoratedBox(
          decoration: ShapeDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
          child: IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
