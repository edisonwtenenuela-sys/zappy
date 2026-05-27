class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.sentByMe,
    required this.sentAt,
  });

  final String id;
  final String text;
  final bool sentByMe;
  final DateTime sentAt;
}

class ChatThread {
  ChatThread({
    required this.id,
    required this.userName,
    required this.lastMessage,
    required this.lastAt,
    required this.unreadCount,
    required this.messages,
  });

  final String id;
  final String userName;
  final String lastMessage;
  final DateTime lastAt;
  final int unreadCount;
  final List<ChatMessage> messages;
}
