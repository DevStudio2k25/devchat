class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String? content;
  final String messageType; // text, image, file, audio, video, system
  final String? fileId;
  final String? replyToId;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    this.messageType = 'text',
    this.fileId,
    this.replyToId,
    this.isEdited = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON (Supabase)
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      fileId: json['file_id'] as String?,
      replyToId: json['reply_to_id'] as String?,
      isEdited: json['is_edited'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // To JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'file_id': fileId,
      'reply_to_id': replyToId,
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with
  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    String? messageType,
    String? fileId,
    String? replyToId,
    bool? isEdited,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      fileId: fileId ?? this.fileId,
      replyToId: replyToId ?? this.replyToId,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if message is text
  bool get isText => messageType == 'text';

  // Check if message is media
  bool get isMedia => ['image', 'audio', 'video'].contains(messageType);

  // Check if message is file
  bool get isFile => messageType == 'file';

  // Check if message is system message
  bool get isSystem => messageType == 'system';

  @override
  String toString() {
    return 'MessageModel(id: $id, chatId: $chatId, type: $messageType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
