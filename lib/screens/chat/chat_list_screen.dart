import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:devchat/services/chat_service.dart';
import 'package:devchat/services/user_service.dart';
import 'package:devchat/services/message_service.dart';
import 'package:devchat/models/chat_model.dart';
import 'package:devchat/models/user_model.dart';
import 'package:devchat/constants/app_routes.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final MessageService _messageService = MessageService();
  List<ChatModel> _chats = [];
  Map<String, UserModel> _otherUsers = {}; // Store other users for direct chats
  Map<String, String> _lastMessages = {}; // Store last messages
  bool _isLoading = true;
  late AnimationController _animationController;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _loadChats();
  }

  Future<void> _loadChats() async {
    print('📋 Loading chats...');
    
    // Load current user profile
    _currentUser = await _userService.getCurrentUserProfile();
    print('👤 Current user loaded: ${_currentUser?.username}');
    
    final chats = await _chatService.getUserChats();
    print('✅ Loaded ${chats.length} chats');

    final currentUserId = _chatService.currentUserId;
    for (var chat in chats) {
      // Load other user for direct chats
      if (!chat.isGroup) {
        print('👥 Loading other user for chat: ${chat.id}');
        final members = await _chatService.getChatMembers(chat.id);
        print('   Found ${members.length} members');
        
        final otherMember = members.firstWhere(
          (m) => m.userId != currentUserId,
          orElse: () => members.first,
        );
        
        final otherUser = await _userService.getUserProfile(otherMember.userId);
        if (otherUser != null) {
          _otherUsers[chat.id] = otherUser;
          print('   ✅ Loaded: ${otherUser.displayName}');
        }
      }
      
      // Load last message
      print('📨 Loading last message for chat: ${chat.id}');
      final messages = await _messageService.getMessages(chatId: chat.id, limit: 1);
      if (messages.isNotEmpty) {
        final lastMsg = messages.first;
        final isMe = lastMsg.senderId == currentUserId;
        final prefix = isMe ? 'You: ' : '';
        
        // Check if it's a file/media message
        final content = lastMsg.content ?? '';
        String displayText;
        
        if (content.contains('supabase.co/storage')) {
          // It's a file - determine type
          if (content.contains('.jpg') || content.contains('.jpeg') || 
              content.contains('.png') || content.contains('.webp') || content.contains('.gif')) {
            displayText = '📷 Photo';
          } else if (content.contains('.mp4') || content.contains('.mov') || 
                     content.contains('.avi') || content.contains('.webm')) {
            displayText = '🎥 Video';
          } else if (content.contains('.pdf') || content.contains('.doc') || 
                     content.contains('.docx') || content.contains('.txt') || 
                     content.contains('.xls') || content.contains('.xlsx') || 
                     content.contains('.ppt') || content.contains('.pptx')) {
            displayText = '📄 Document';
          } else if (content.contains('.mp3') || content.contains('.wav') || 
                     content.contains('.m4a') || content.contains('.aac') || 
                     content.contains('.ogg')) {
            displayText = '🎵 Audio';
          } else {
            displayText = '📎 File';
          }
        } else {
          // Regular text message
          displayText = content;
        }
        
        _lastMessages[chat.id] = '$prefix$displayText';
        print('   ✅ Last message: ${_lastMessages[chat.id]}');
      } else {
        _lastMessages[chat.id] = 'No messages yet';
        print('   ℹ️ No messages');
      }
    }
    
    setState(() {
      _chats = chats;
      _isLoading = false;
    });
    print('✅ Chat list loaded with ${_otherUsers.length} other users');
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Profile Avatar
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.profile),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          backgroundImage: _currentUser?.avatarUrl != null
                              ? NetworkImage(_currentUser!.avatarUrl!)
                              : null,
                          child: _currentUser?.avatarUrl == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title
                    const Expanded(
                      child: Text(
                        'Chats',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Search Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Color(0xFF667eea)),
                        onPressed: () {
                          context.push(AppRoutes.search);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Chat List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _chats.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadChats,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: _chats.length,
                              itemBuilder: (context, index) {
                                return _buildChatItem(_chats[index], index);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildChatItem(ChatModel chat, int index) {
    final otherUser = _otherUsers[chat.id];
    final displayName = chat.isGroup 
        ? (chat.name ?? 'Group Chat')
        : (otherUser?.displayName ?? 'Unknown User');
    final avatarUrl = chat.isGroup 
        ? chat.avatarUrl
        : otherUser?.avatarUrl;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Hero(
            tag: 'chat_avatar_${chat.id}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.transparent,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Text(
                        displayName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          title: Text(
            displayName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _lastMessages[chat.id] ?? 'No messages yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (chat.lastMessageAt != null)
                Text(
                  _formatTime(chat.lastMessageAt!),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              // Unread badge removed (no messages yet)
            ],
          ),
          onTap: () {
            context.push(AppRoutes.getChatRoute(chat.id));
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
              size: 80,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No chats yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation by tapping the + button',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.newChat);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
