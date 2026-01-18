enum MessageType { user, assistant }

class ChatMessage {
  final int id;
  final MessageType type;
  final String content;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.content,
  });
}
