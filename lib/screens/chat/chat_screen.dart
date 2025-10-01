import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:devchat/services/message_service.dart';
import 'package:devchat/services/chat_service.dart';
import 'package:devchat/services/user_service.dart';
import 'package:devchat/models/message_model.dart';
import 'package:devchat/models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  List<types.Message> _messages = [];
  ChatModel? _chat;
  types.User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeToMessages();
  }

  Future<void> _loadData() async {
    // Load current user
    final currentUserId = _messageService.currentUserId;
    if (currentUserId != null) {
      final userProfile = await _userService.getUserProfile(currentUserId);
      if (userProfile != null) {
        _currentUser = types.User(
          id: userProfile.id,
          firstName: userProfile.displayName,
          imageUrl: userProfile.avatarUrl,
        );
      }
    }

    // Load chat details
    _chat = await _chatService.getChatById(widget.chatId);

    // Load messages
    await _loadMessages();

    // Mark as read
    await _messageService.markAsRead(widget.chatId);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMessages() async {
    final messages = await _messageService.getMessages(chatId: widget.chatId);
    setState(() {
      _messages = messages.map(_convertToFlutterChatMessage).toList();
    });
  }

  void _subscribeToMessages() {
    _messageService.streamMessages(widget.chatId).listen((messages) {
      setState(() {
        _messages = messages.map(_convertToFlutterChatMessage).toList();
      });
      _messageService.markAsRead(widget.chatId);
    });
  }

  types.Message _convertToFlutterChatMessage(MessageModel message) {
    return types.TextMessage(
      id: message.id,
      author: types.User(id: message.senderId),
      text: message.content ?? '[Deleted]',
      createdAt: message.createdAt.millisecondsSinceEpoch,
      status: types.Status.seen,
      showStatus: message.senderId == _messageService.currentUserId,
    );
  }

  void _handleSendPressed(types.PartialText message) async {
    final sentMessage = await _messageService.sendMessage(
      chatId: widget.chatId,
      content: message.text,
    );

    if (sentMessage != null) {
      // Message will be added via stream
      print('✅ Message sent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'chat_avatar_${widget.chatId}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  backgroundImage: _chat?.avatarUrl != null
                      ? NetworkImage(_chat!.avatarUrl!)
                      : null,
                  child: _chat?.avatarUrl == null
                      ? Text(
                          _chat?.name?.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _chat?.name ?? 'Chat',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              // TODO: Implement video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {
              // TODO: Implement voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show chat options
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              user: _currentUser ?? types.User(id: 'unknown'),
              theme: DefaultChatTheme(
                primaryColor: const Color(0xFF667eea),
                secondaryColor: const Color(0xFFF1F5F9),
                backgroundColor: Colors.white,
                inputBackgroundColor: const Color(0xFFF8FAFC),
                inputTextColor: Colors.black87,
                inputBorderRadius: BorderRadius.circular(24),
                messageBorderRadius: 16,
                sentMessageBodyTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                receivedMessageBodyTextStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
              showUserAvatars: true,
              showUserNames: false,
              onAttachmentPressed: _handleAttachmentPressed,
              emptyState: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF667eea).withOpacity(0.2),
                            const Color(0xFF764ba2).withOpacity(0.2),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Color(0xFF667eea),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No messages yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Send a message to start the conversation',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: const Color(0xFF667eea),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement gallery picker
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: const Color(0xFF764ba2),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement camera
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.insert_drive_file,
                    label: 'File',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement file picker
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
