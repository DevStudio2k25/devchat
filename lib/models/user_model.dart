class UserModel {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String status; // online, offline, away, busy
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.status = 'offline',
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON (Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      status: json['status'] as String? ?? 'offline',
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // To JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'status': status,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? status,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get display name
  String get displayName => fullName ?? username;

  // Check if online
  bool get isOnline => status == 'online';

  // Get initials for avatar
  String get initials {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
