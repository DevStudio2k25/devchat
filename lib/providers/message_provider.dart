import 'package:flutter/material.dart';
import 'package:devchat/services/message_service.dart';
import 'package:devchat/models/message_model.dart';

class MessageProvider extends ChangeNotifier {
  final MessageService _messageService = MessageService();

  final Map<String, List<MessageModel>> _messagesByChat = {};
  final Map<String, bool> _loadingStates = {};
  String? _errorMessage;

  List<MessageModel> getMessages(String chatId) {
    return _messagesByChat[chatId] ?? [];
  }

  bool isLoading(String chatId) {
    return _loadingStates[chatId] ?? false;
  }

  String? get errorMessage => _errorMessage;

  /// Load messages for a chat
  Future<void> loadMessages(String chatId) async {
    _setLoading(chatId, true);
    _clearError();

    try {
      final messages = await _messageService.getMessages(chatId: chatId);
      _messagesByChat[chatId] = messages;
      _setLoading(chatId, false);
    } catch (e) {
      _setError('Failed to load messages: $e');
      _setLoading(chatId, false);
    }
  }

  /// Send message
  Future<MessageModel?> sendMessage({
    required String chatId,
    required String content,
    String? replyToId,
  }) async {
    _clearError();

    try {
      final message = await _messageService.sendMessage(
        chatId: chatId,
        content: content,
        replyToId: replyToId,
      );

      if (message != null) {
        _addMessage(chatId, message);
      }

      return message;
    } catch (e) {
      _setError('Failed to send message: $e');
      return null;
    }
  }

  /// Delete message
  Future<bool> deleteMessage(String chatId, String messageId) async {
    _clearError();

    try {
      final success = await _messageService.deleteMessage(messageId);
      if (success) {
        _removeMessage(chatId, messageId);
      }
      return success;
    } catch (e) {
      _setError('Failed to delete message: $e');
      return false;
    }
  }

  /// Add message to local cache
  void _addMessage(String chatId, MessageModel message) {
    if (!_messagesByChat.containsKey(chatId)) {
      _messagesByChat[chatId] = [];
    }
    _messagesByChat[chatId]!.add(message);
    notifyListeners();
  }

  /// Remove message from local cache
  void _removeMessage(String chatId, String messageId) {
    _messagesByChat[chatId]?.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
  }

  void _setLoading(String chatId, bool value) {
    _loadingStates[chatId] = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
