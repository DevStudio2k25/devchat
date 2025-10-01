import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:devchat/models/chat_model.dart';
import 'package:devchat/models/message_model.dart';
import 'package:devchat/models/chat_member_model.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Get all chats for current user
  Future<List<ChatModel>> getUserChats() async {
    try {
      final response = await _supabase
          .from('chat_members')
          .select('chat_id, chats(*)')
          .eq('user_id', currentUserId!)
          .order('chats(last_message_at)', ascending: false);

      return (response as List)
          .map((item) => ChatModel.fromJson(item['chats']))
          .toList();
    } catch (e) {
      print('❌ Error fetching user chats: $e');
      return [];
    }
  }

  /// Create a new 1-to-1 chat
  Future<ChatModel?> createDirectChat(String otherUserId) async {
    try {
      // Check if chat already exists
      final existingChat = await _findDirectChat(otherUserId);
      if (existingChat != null) return existingChat;

      // Create new chat
      final chatResponse = await _supabase
          .from('chats')
          .insert({
            'is_group': false,
            'created_by': currentUserId,
          })
          .select()
          .single();

      final chat = ChatModel.fromJson(chatResponse);

      // Add both users as members
      await _supabase.from('chat_members').insert([
        {
          'chat_id': chat.id,
          'user_id': currentUserId,
          'role': 'admin',
        },
        {
          'chat_id': chat.id,
          'user_id': otherUserId,
          'role': 'member',
        },
      ]);

      print('✅ Direct chat created: ${chat.id}');
      return chat;
    } catch (e) {
      print('❌ Error creating direct chat: $e');
      return null;
    }
  }

  /// Find existing direct chat between two users
  Future<ChatModel?> _findDirectChat(String otherUserId) async {
    try {
      final response = await _supabase.rpc('find_direct_chat', params: {
        'user1_id': currentUserId,
        'user2_id': otherUserId,
      });

      if (response != null && response.isNotEmpty) {
        return ChatModel.fromJson(response[0]);
      }
      return null;
    } catch (e) {
      print('❌ Error finding direct chat: $e');
      return null;
    }
  }

  /// Create a group chat
  Future<ChatModel?> createGroupChat({
    required String name,
    String? description,
    List<String>? memberIds,
  }) async {
    try {
      // Create chat
      final chatResponse = await _supabase
          .from('chats')
          .insert({
            'name': name,
            'description': description,
            'is_group': true,
            'created_by': currentUserId,
          })
          .select()
          .single();

      final chat = ChatModel.fromJson(chatResponse);

      // Add creator as admin
      final members = [
        {
          'chat_id': chat.id,
          'user_id': currentUserId,
          'role': 'admin',
        }
      ];

      // Add other members
      if (memberIds != null) {
        members.addAll(
          memberIds.map((userId) => {
                'chat_id': chat.id,
                'user_id': userId,
                'role': 'member',
              }),
        );
      }

      await _supabase.from('chat_members').insert(members);

      print('✅ Group chat created: ${chat.id}');
      return chat;
    } catch (e) {
      print('❌ Error creating group chat: $e');
      return null;
    }
  }

  /// Get chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    try {
      final response = await _supabase
          .from('chats')
          .select()
          .eq('id', chatId)
          .single();

      return ChatModel.fromJson(response);
    } catch (e) {
      print('❌ Error fetching chat: $e');
      return null;
    }
  }

  /// Update chat details
  Future<bool> updateChat({
    required String chatId,
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase.from('chats').update(updates).eq('id', chatId);

      print('✅ Chat updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating chat: $e');
      return false;
    }
  }

  /// Delete chat
  Future<bool> deleteChat(String chatId) async {
    try {
      await _supabase.from('chats').delete().eq('id', chatId);
      print('✅ Chat deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting chat: $e');
      return false;
    }
  }

  /// Get chat members
  Future<List<ChatMemberModel>> getChatMembers(String chatId) async {
    try {
      final response = await _supabase
          .from('chat_members')
          .select()
          .eq('chat_id', chatId);

      return (response as List)
          .map((json) => ChatMemberModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching chat members: $e');
      return [];
    }
  }

  /// Add member to chat
  Future<bool> addMember(String chatId, String userId) async {
    try {
      await _supabase.from('chat_members').insert({
        'chat_id': chatId,
        'user_id': userId,
        'role': 'member',
      });

      print('✅ Member added to chat');
      return true;
    } catch (e) {
      print('❌ Error adding member: $e');
      return false;
    }
  }

  /// Remove member from chat
  Future<bool> removeMember(String chatId, String userId) async {
    try {
      await _supabase
          .from('chat_members')
          .delete()
          .eq('chat_id', chatId)
          .eq('user_id', userId);

      print('✅ Member removed from chat');
      return true;
    } catch (e) {
      print('❌ Error removing member: $e');
      return false;
    }
  }

  /// Leave chat
  Future<bool> leaveChat(String chatId) async {
    return removeMember(chatId, currentUserId!);
  }

  /// Update member role
  Future<bool> updateMemberRole(String chatId, String userId, String role) async {
    try {
      await _supabase
          .from('chat_members')
          .update({'role': role})
          .eq('chat_id', chatId)
          .eq('user_id', userId);

      print('✅ Member role updated');
      return true;
    } catch (e) {
      print('❌ Error updating member role: $e');
      return false;
    }
  }

  /// Mute/unmute chat
  Future<bool> toggleMute(String chatId, bool isMuted) async {
    try {
      await _supabase
          .from('chat_members')
          .update({'is_muted': isMuted})
          .eq('chat_id', chatId)
          .eq('user_id', currentUserId!);

      print('✅ Chat ${isMuted ? 'muted' : 'unmuted'}');
      return true;
    } catch (e) {
      print('❌ Error toggling mute: $e');
      return false;
    }
  }

  /// Update last read timestamp
  Future<bool> updateLastRead(String chatId) async {
    try {
      await _supabase
          .from('chat_members')
          .update({'last_read_at': DateTime.now().toIso8601String()})
          .eq('chat_id', chatId)
          .eq('user_id', currentUserId!);

      return true;
    } catch (e) {
      print('❌ Error updating last read: $e');
      return false;
    }
  }

  /// Stream chat updates
  Stream<ChatModel?> streamChat(String chatId) {
    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('id', chatId)
        .map((data) {
          if (data.isEmpty) return null;
          return ChatModel.fromJson(data.first);
        });
  }

  /// Stream user chats
  Stream<List<ChatModel>> streamUserChats() {
    return _supabase
        .from('chat_members')
        .stream(primaryKey: ['id'])
        .eq('user_id', currentUserId!)
        .asyncMap((members) async {
          final chatIds = members.map((m) => m['chat_id'] as String).toList();
          if (chatIds.isEmpty) return <ChatModel>[];

          final chats = await _supabase
              .from('chats')
              .select()
              .in_('id', chatIds)
              .order('last_message_at', ascending: false);

          return (chats as List)
              .map((json) => ChatModel.fromJson(json))
              .toList();
        });
  }
}
