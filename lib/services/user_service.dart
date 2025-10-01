import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:devchat/models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Fetch user profile by ID
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return null;
    }
  }

  /// Fetch current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    if (currentUserId == null) return null;
    return getUserProfile(currentUserId!);
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updates['username'] = username;
      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase.from('users').update(updates).eq('id', userId);

      print('✅ User profile updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating user profile: $e');
      return false;
    }
  }

  /// Update user status (online, offline, away, busy)
  Future<bool> updateUserStatus(String userId, String status) async {
    try {
      await _supabase.from('users').update({
        'status': status,
        'last_seen': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      print('✅ User status updated to: $status');
      return true;
    } catch (e) {
      print('❌ Error updating user status: $e');
      return false;
    }
  }

  /// Search users by username or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .or('username.ilike.%$query%,email.ilike.%$query%,full_name.ilike.%$query%')
          .limit(20);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  /// Get multiple users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .inFilter('id', userIds);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching users by IDs: $e');
      return [];
    }
  }

  /// Upload profile avatar
  /// Note: This method needs to be called with actual File object from image_picker
  /// For now, it's a placeholder that returns null
  Future<String?> uploadAvatar(String userId, dynamic fileData) async {
    try {
      // TODO: Implement actual file upload with image_picker
      // This is a placeholder for future implementation
      print('⚠️ Avatar upload not yet implemented');
      return null;
    } catch (e) {
      print('❌ Error uploading avatar: $e');
      return null;
    }
  }

  /// Delete avatar
  Future<bool> deleteAvatar(String userId, String avatarUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(avatarUrl);
      final path = uri.pathSegments.last;

      await _supabase.storage.from('avatars').remove(['avatars/$path']);

      // Update user profile to remove avatar URL
      await updateUserProfile(userId: userId, avatarUrl: null);

      print('✅ Avatar deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting avatar: $e');
      return false;
    }
  }

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (e) {
      print('❌ Error checking username availability: $e');
      return false;
    }
  }

  /// Get online users
  Future<List<UserModel>> getOnlineUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('status', 'online')
          .order('last_seen', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching online users: $e');
      return [];
    }
  }

  /// Stream user profile changes
  Stream<UserModel?> streamUserProfile(String userId) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return UserModel.fromJson(data.first);
        });
  }
}
