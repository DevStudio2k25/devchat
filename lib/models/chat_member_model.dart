class ChatMemberModel {
  final String id;
  final String chatId;
  final String userId;
  final String role; // admin, member
  final DateTime joinedAt;
  final DateTime? lastReadAt;
  final bool isMuted;

  ChatMemberModel({
    required this.id,
    required this.chatId,
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
    this.lastReadAt,
    this.isMuted = false,
  });

  // From JSON (Supabase)
  factory ChatMemberModel.fromJson(Map<String, dynamic> json) {
    return ChatMemberModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'] as String)
          : null,
      isMuted: json['is_muted'] as bool? ?? false,
    );
  }

  // To JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'last_read_at': lastReadAt?.toIso8601String(),
      'is_muted': isMuted,
    };
  }

  // Copy with
  ChatMemberModel copyWith({
    String? id,
    String? chatId,
    String? userId,
    String? role,
    DateTime? joinedAt,
    DateTime? lastReadAt,
    bool? isMuted,
  }) {
    return ChatMemberModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  // Check if admin
  bool get isAdmin => role == 'admin';

  @override
  String toString() {
    return 'ChatMemberModel(id: $id, userId: $userId, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMemberModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
