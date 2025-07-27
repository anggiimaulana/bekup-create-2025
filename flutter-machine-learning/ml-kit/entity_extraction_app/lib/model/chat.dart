class Chat {
  final String text;
  final String emailSender;
  final bool isMyChat;

  Chat({required this.text, required this.emailSender, required this.isMyChat});

  factory Chat.fromJson(Map<String, dynamic> map) {
    return Chat(
      text: map['text'] as String,
      emailSender: map['sender'] as String,
      isMyChat: map['isMyChat'] as bool,
    );
  }
}

final listOfChat = [
  Chat(isMyChat: true, emailSender: "User", text: "Thank you!"),
  Chat(
    isMyChat: false,
    emailSender: "Dicoding",
    text:
        "For more information about our coding courses and events, visit dicoding.com, email us at info@dicoding.com, or call us at +62 12-3456-7890.",
  ),
  Chat(
    isMyChat: true,
    emailSender: "User",
    text:
        "Where can I find more information about coding courses and events, or how can I contact Dicoding?",
  ),
];
