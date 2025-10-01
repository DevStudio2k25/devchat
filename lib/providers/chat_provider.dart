import 'package:flutter/material.dart';
import 'package:devchat/services/chat_service.dart';
import 'package:devchat/models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatModel> _chats = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load user chats
  Future<void> loadChats() async {
    _setLoading(true);
    _clearError();

    try {
      _chats = await _chatService.getUserChats();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load chats: $e');
      _setLoading(false);
    }
  }

  /// Create direct chat
  Future<ChatModel?> createDirectChat(String userId) async {
    _clearError();

    try {
      final chat = await _chatService.createDirectChat(userId);
      if (chat != null) {
        _chats.insert(0, chat);
        notifyListeners();
      }
      return chat;
    } catch (e) {
      _setError('Failed to create chat: $e');
      return null;
    }
  }

  /// Create group chat
  Future<ChatModel?> createGroupChat({
    required String name,
    String? description,
    List<String>? memberIds,
  }) async {
    _clearError();

    try {
      final chat = await _chatService.createGroupChat(
        name: name,
        description: description,
        memberIds: memberIds,
      );
      if (chat != null) {
        _chats.insert(0, chat);
        notifyListeners();
      }
      return chat;
    } catch (e) {
      _setError('Failed to create group: $e');
      return null;
    }
  }

  /// Delete chat
  Future<bool> deleteChat(String chatId) async {
    _clearError();

    try {
      final success = await _chatService.deleteChat(chatId);
      if (success) {
        _chats.removeWhere((chat) => chat.id == chatId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to delete chat: $e');
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
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
