import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:devchat/models/message_model.dart';

class MessageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Send a text message
  Future<MessageModel?> sendMessage({
    required String chatId,
    required String content,
    String? replyToId,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'chat_id': chatId,
            'sender_id': currentUserId,
            'content': content,
            'message_type': 'text',
            'reply_to_id': replyToId,
          })
          .select()
          .single();

      print('✅ Message sent successfully');
      return MessageModel.fromJson(response);
    } catch (e) {
      print('❌ Error sending message: $e');
      return null;
    }
  }

  /// Send a media message (image, video, audio)
  Future<MessageModel?> sendMediaMessage({
    required String chatId,
    required String fileId,
    required String messageType,
    String? content,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'chat_id': chatId,
            'sender_id': currentUserId,
            'content': content,
            'message_type': messageType,
            'file_id': fileId,
          })
          .select()
          .single();

      print('✅ Media message sent successfully');
      return MessageModel.fromJson(response);
    } catch (e) {
      print('❌ Error sending media message: $e');
      return null;
    }
  }

  /// Fetch message history for a chat
  Future<List<MessageModel>> getMessages({
    required String chatId,
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      var query = _supabase
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(limit);

      if (before != null) {
        query = query.lt('created_at', before.toIso8601String());
      }

      final response = await query;

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      print('❌ Error fetching messages: $e');
      return [];
    }
  }

  /// Get a single message by ID
  Future<MessageModel?> getMessageById(String messageId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('id', messageId)
          .single();

      return MessageModel.fromJson(response);
    } catch (e) {
      print('❌ Error fetching message: $e');
      return null;
    }
  }

  /// Edit a message
  Future<bool> editMessage(String messageId, String newContent) async {
    try {
      await _supabase.from('messages').update({
        'content': newContent,
        'is_edited': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', messageId).eq('sender_id', currentUserId!);

      print('✅ Message edited successfully');
      return true;
    } catch (e) {
      print('❌ Error editing message: $e');
      return false;
    }
  }

  /// Delete a message (soft delete)
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _supabase.from('messages').update({
        'is_deleted': true,
        'content': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', messageId).eq('sender_id', currentUserId!);

      print('✅ Message deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting message: $e');
      return false;
    }
  }

  /// Mark messages as read
  Future<bool> markAsRead(String chatId) async {
    try {
      await _supabase
          .from('chat_members')
          .update({'last_read_at': DateTime.now().toIso8601String()})
          .eq('chat_id', chatId)
          .eq('user_id', currentUserId!);

      print('✅ Messages marked as read');
      return true;
    } catch (e) {
      print('❌ Error marking messages as read: $e');
      return false;
    }
  }

  /// Get unread message count for a chat
  Future<int> getUnreadCount(String chatId) async {
    try {
      // Get last read timestamp
      final memberResponse = await _supabase
          .from('chat_members')
          .select('last_read_at')
          .eq('chat_id', chatId)
          .eq('user_id', currentUserId!)
          .single();

      final lastReadAt = memberResponse['last_read_at'];

      // Count messages after last read
      final countResponse = await _supabase
          .from('messages')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('chat_id', chatId)
          .neq('sender_id', currentUserId!)
          .gt('created_at', lastReadAt ?? '1970-01-01T00:00:00Z');

      return countResponse.count ?? 0;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Search messages in a chat
  Future<List<MessageModel>> searchMessages({
    required String chatId,
    required String query,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .eq('is_deleted', false)
          .textSearch('content', query)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error searching messages: $e');
      return [];
    }
  }

  /// Stream messages for a chat (real-time)
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .eq('is_deleted', false)
        .order('created_at', ascending: true)
        .map((data) {
          return data.map((json) => MessageModel.fromJson(json)).toList();
        });
  }

  /// Stream new messages only (for notifications)
  Stream<MessageModel> streamNewMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .limit(1)
        .map((data) {
          if (data.isEmpty) throw Exception('No messages');
          return MessageModel.fromJson(data.first);
        });
  }

  /// Add reaction to message
  Future<bool> addReaction(String messageId, String emoji) async {
    try {
      await _supabase.from('reactions').insert({
        'message_id': messageId,
        'user_id': currentUserId,
        'emoji': emoji,
      });

      print('✅ Reaction added');
      return true;
    } catch (e) {
      print('❌ Error adding reaction: $e');
      return false;
    }
  }

  /// Remove reaction from message
  Future<bool> removeReaction(String messageId, String emoji) async {
    try {
      await _supabase
          .from('reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', currentUserId!)
          .eq('emoji', emoji);

      print('✅ Reaction removed');
      return true;
    } catch (e) {
      print('❌ Error removing reaction: $e');
      return false;
    }
  }

  /// Get reactions for a message
  Future<Map<String, List<String>>> getReactions(String messageId) async {
    try {
      final response = await _supabase
          .from('reactions')
          .select('emoji, user_id')
          .eq('message_id', messageId);

      final Map<String, List<String>> reactions = {};
      for (var reaction in response) {
        final emoji = reaction['emoji'] as String;
        final userId = reaction['user_id'] as String;
        reactions.putIfAbsent(emoji, () => []).add(userId);
      }

      return reactions;
    } catch (e) {
      print('❌ Error getting reactions: $e');
      return {};
    }
  }

  /// Send typing indicator
  Future<bool> sendTypingIndicator(String chatId, bool isTyping) async {
    try {
      await _supabase.from('presence').upsert({
        'user_id': currentUserId,
        'chat_id': chatId,
        'is_typing': isTyping,
        'last_activity': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('❌ Error sending typing indicator: $e');
      return false;
    }
  }

  /// Stream typing indicators for a chat
  Stream<List<String>> streamTypingUsers(String chatId) {
    return _supabase
        .from('presence')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .eq('is_typing', true)
        .neq('user_id', currentUserId!)
        .map((data) {
          return data.map((json) => json['user_id'] as String).toList();
        });
  }
}
