class ChatModel {
  final String id;
  final String? name;
  final String? description;
  final bool isGroup;
  final String? avatarUrl;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;

  ChatModel({
    required this.id,
    this.name,
    this.description,
    this.isGroup = false,
    this.avatarUrl,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
  });

  // From JSON (Supabase)
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      isGroup: json['is_group'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
    );
  }

  // To JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_group': isGroup,
      'avatar_url': avatarUrl,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
    };
  }

  // Copy with
  ChatModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isGroup,
    String? avatarUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isGroup: isGroup ?? this.isGroup,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  @override
  String toString() {
    return 'ChatModel(id: $id, name: $name, isGroup: $isGroup)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
