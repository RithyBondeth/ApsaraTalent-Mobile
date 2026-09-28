Map<String, dynamic> chatMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};

String chatId(dynamic value) =>
    value is Map ? '${value['id'] ?? ''}' : '${value ?? ''}';

class Conversation {
  const Conversation(
      {required this.id,
      required this.name,
      this.avatar,
      this.preview = '',
      this.time = '',
      this.isRead = true});
  factory Conversation.fromJson(dynamic value) {
    final j = chatMap(value);
    return Conversation(
        id: chatId(j['id']),
        name: '${j['name'] ?? 'Conversation'}',
        avatar: j['avatar'] as String?,
        preview: '${j['preview'] ?? ''}',
        time: '${j['time'] ?? ''}',
        isRead: j['isRead'] != false);
  }
  final String id, name, preview, time;
  final String? avatar;
  final bool isRead;
}

class ChatMessage {
  const ChatMessage(
      {required this.id,
      required this.senderId,
      required this.receiverId,
      required this.content,
      required this.sentAt,
      this.type = 'text',
      this.isRead = false,
      this.isDeleted = false,
      this.isEdited = false,
      this.attachment,
      this.filename,
      this.replyToId,
      this.reactions = const {}});
  factory ChatMessage.fromJson(dynamic value) {
    final j = chatMap(value);
    return ChatMessage(
        id: chatId(j['id']),
        senderId: chatId(j['senderId'] ?? j['sender']),
        receiverId: chatId(j['receiverId'] ?? j['receiver']),
        content: '${j['content'] ?? ''}',
        sentAt: DateTime.tryParse(
                '${j['sentAt'] ?? j['timestamp'] ?? j['createdAt']}') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        type: '${j['messageType'] ?? j['type'] ?? 'text'}',
        isRead: j['isRead'] == true,
        isDeleted: j['isDeleted'] == true,
        isEdited: j['isEdited'] == true,
        attachment: j['attachment'] as String?,
        filename: j['attachmentFilename'] as String?,
        replyToId: j['replyToId'] as String?,
        reactions: chatMap(j['reactions']).map((k, v) => MapEntry(k, '$v')));
  }
  final String id, senderId, receiverId, content, type;
  final DateTime sentAt;
  final bool isRead, isDeleted, isEdited;
  final String? attachment, filename, replyToId;
  final Map<String, String> reactions;
  ChatMessage copyWith(
          {String? content,
          bool? isRead,
          bool? isDeleted,
          bool? isEdited,
          Map<String, String>? reactions}) =>
      ChatMessage(
          id: id,
          senderId: senderId,
          receiverId: receiverId,
          sentAt: sentAt,
          type: type,
          content: content ?? this.content,
          isRead: isRead ?? this.isRead,
          isDeleted: isDeleted ?? this.isDeleted,
          isEdited: isEdited ?? this.isEdited,
          attachment: attachment,
          filename: filename,
          replyToId: replyToId,
          reactions: reactions ?? this.reactions);
}

class ChatAttachment {
  const ChatAttachment(
      {required this.url, required this.type, required this.filename});
  factory ChatAttachment.fromJson(dynamic value) {
    final j = chatMap(value);
    if (j['url'] is! String ||
        j['type'] is! String ||
        j['filename'] is! String) {
      throw const FormatException('Invalid attachment response');
    }
    return ChatAttachment(
        url: j['url'], type: j['type'], filename: j['filename']);
  }
  final String url, type, filename;
}

class ChatEvent {
  const ChatEvent(this.name, [this.data]);
  final String name;
  final dynamic data;
}
