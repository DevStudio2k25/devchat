import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:devchat/services/message_service.dart';
import 'package:devchat/services/chat_service.dart';
import 'package:devchat/services/user_service.dart';
import 'package:devchat/services/file_service.dart';
import 'package:devchat/models/message_model.dart';
import 'package:devchat/models/chat_model.dart';
import 'package:devchat/utils/file_picker_helper.dart';
import 'package:devchat/widgets/chat/image_message_widget.dart';
import 'package:devchat/widgets/chat/uploading_preview_widget.dart';
import 'package:devchat/widgets/chat/empty_chat_widget.dart';
import 'package:devchat/widgets/chat/image_grid_widget.dart';
import 'package:devchat/widgets/chat/full_screen_image_viewer.dart';
import 'package:devchat/widgets/chat/video_message_widget.dart';
import 'package:devchat/widgets/chat/video_player_screen.dart';
import 'package:devchat/widgets/chat/attachment_bottom_sheet.dart';
import 'package:devchat/widgets/chat/document_message_widget.dart';
import 'package:devchat/widgets/chat/audio_player_widget.dart';
import 'package:devchat/widgets/chat/document_viewer_screen.dart';

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
  final FileService _fileService = FileService();

  List<types.Message> _messages = [];
  ChatModel? _chat;
  types.User? _currentUser;
  types.User? _otherUser;
  bool _isLoading = true;
  
  // For uploading files
  File? _uploadingFile;
  String? _uploadingFileType;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeToMessages();
  }

  Future<void> _loadData() async {
    print('🔵 ChatScreen: Loading data for chat ${widget.chatId}');
    
    // Load current user
    final currentUserId = _messageService.currentUserId;
    print('👤 Current User ID: $currentUserId');
    
    if (currentUserId != null) {
      final userProfile = await _userService.getUserProfile(currentUserId);
      print('📝 User Profile: ${userProfile?.displayName}');
      
      if (userProfile != null) {
        _currentUser = types.User(
          id: userProfile.id,
          firstName: userProfile.displayName,
          imageUrl: userProfile.avatarUrl,
        );
        print('✅ Current user loaded: ${_currentUser?.firstName}');
      }
    }

    // Load chat details
    print('💬 Loading chat details...');
    _chat = await _chatService.getChatById(widget.chatId);
    print('💬 Chat loaded: ${_chat?.name ?? "Direct Chat"}');
    print('   Is Group: ${_chat?.isGroup}');
    print('   Created by: ${_chat?.createdBy}');

    // Load other user for direct chat
    if (_chat != null && !_chat!.isGroup) {
      print('👥 Loading other user for direct chat...');
      final members = await _chatService.getChatMembers(widget.chatId);
      final otherMember = members.firstWhere(
        (m) => m.userId != currentUserId,
        orElse: () => members.first,
      );
      final otherUserProfile = await _userService.getUserProfile(otherMember.userId);
      if (otherUserProfile != null) {
        _otherUser = types.User(
          id: otherUserProfile.id,
          firstName: otherUserProfile.displayName,
          imageUrl: otherUserProfile.avatarUrl,
        );
        print('✅ Other user loaded: ${_otherUser?.firstName}');
      }
    }

    // Load messages
    print('📨 Loading messages...');
    await _loadMessages();
    print('📨 Loaded ${_messages.length} messages');

    // Mark as read
    await _messageService.markAsRead(widget.chatId);
    print('✅ Marked as read');

    setState(() {
      _isLoading = false;
    });
    print('✅ ChatScreen: Data loading complete');
  }

  Future<void> _loadMessages() async {
    final messages = await _messageService.getMessages(chatId: widget.chatId);
    setState(() {
      // Group consecutive images and convert to chat messages
      _messages = _groupAndConvertMessages(messages.reversed.toList());
    });
  }

  List<types.Message> _groupAndConvertMessages(List<MessageModel> messages) {
    final result = <types.Message>[];
    final List<String> imageGroup = [];
    String? currentSender;

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final content = message.content ?? '';
      final isImage = content.contains('supabase.co/storage') && 
          (content.contains('.jpg') || content.contains('.jpeg') || 
           content.contains('.png') || content.contains('.webp') || content.contains('.gif'));

      if (isImage && message.senderId == currentSender) {
        // Same sender, add to group
        imageGroup.add(content);
      } else {
        // Different sender or not image, flush current group
        if (imageGroup.isNotEmpty) {
          result.add(_createImageGroupMessage(imageGroup, currentSender!, messages[i - 1].createdAt));
          imageGroup.clear();
        }

        if (isImage) {
          // Start new group
          imageGroup.add(content);
          currentSender = message.senderId;
        } else {
          // Regular message
          result.add(_convertToFlutterChatMessage(message));
          currentSender = null;
        }
      }
    }

    // Flush remaining group
    if (imageGroup.isNotEmpty) {
      result.add(_createImageGroupMessage(imageGroup, currentSender!, messages.last.createdAt));
    }

    return result;
  }

  types.Message _createImageGroupMessage(List<String> urls, String senderId, DateTime createdAt, {Map<String, int>? reactions}) {
    print('📦 Creating image group: ${urls.length} images');
    print('   URLs: $urls');
    if (reactions != null) {
      print('   🎭 With reactions: $reactions');
    }
    
    // Store URLs in metadata for grid widget
    final metadata = {
      'type': 'image_grid',
      'urls': List<String>.from(urls),
    };
    
    if (reactions != null && reactions.isNotEmpty) {
      metadata['reactions'] = reactions;
    }
    
    return types.CustomMessage(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      author: types.User(id: senderId),
      createdAt: createdAt.millisecondsSinceEpoch,
      metadata: metadata,
      status: types.Status.seen,
      showStatus: senderId == _messageService.currentUserId,
    );
  }

  void _subscribeToMessages() {
    _messageService.streamMessages(widget.chatId).listen((messages) {
      setState(() {
        // Group consecutive images and convert
        _messages = _groupAndConvertMessages(messages.reversed.toList());
      });
      _messageService.markAsRead(widget.chatId);
    });
  }

  types.Message _convertToFlutterChatMessage(MessageModel message) {
    final content = message.content ?? '[Deleted]';
    
    // Check if content is an image URL
    if (content.contains('supabase.co/storage') && 
        (content.contains('.jpg') || content.contains('.jpeg') || 
         content.contains('.png') || content.contains('.webp') || content.contains('.gif'))) {
      return types.ImageMessage(
        id: message.id,
        author: types.User(id: message.senderId),
        uri: content,
        name: 'Image',
        size: 0,
        createdAt: message.createdAt.millisecondsSinceEpoch,
        status: types.Status.seen,
        showStatus: message.senderId == _messageService.currentUserId,
        metadata: message.reactions != null ? {'reactions': message.reactions} : null,
      );
    }
    
    // Check if content is a video URL
    if (content.contains('supabase.co/storage') && 
        (content.contains('.mp4') || content.contains('.mov') || content.contains('.avi') || content.contains('.webm'))) {
      final metadata = <String, dynamic>{'type': 'video'};
      if (message.reactions != null && message.reactions!.isNotEmpty) {
        metadata['reactions'] = message.reactions!;
      }
      return types.FileMessage(
        id: message.id,
        author: types.User(id: message.senderId),
        uri: content,
        name: 'Video',
        size: 0,
        createdAt: message.createdAt.millisecondsSinceEpoch,
        status: types.Status.seen,
        showStatus: message.senderId == _messageService.currentUserId,
        metadata: metadata,
      );
    }
    
    // Check if content is a document URL
    if (content.contains('supabase.co/storage') && 
        (content.contains('.pdf') || content.contains('.doc') || content.contains('.docx') || 
         content.contains('.txt') || content.contains('.xls') || content.contains('.xlsx') || 
         content.contains('.ppt') || content.contains('.pptx'))) {
      final fileName = content.split('/').last;
      final metadata = <String, dynamic>{'type': 'document'};
      if (message.reactions != null && message.reactions!.isNotEmpty) {
        metadata['reactions'] = message.reactions!;
      }
      return types.FileMessage(
        id: message.id,
        author: types.User(id: message.senderId),
        uri: content,
        name: fileName,
        size: 0,
        createdAt: message.createdAt.millisecondsSinceEpoch,
        status: types.Status.seen,
        showStatus: message.senderId == _messageService.currentUserId,
        metadata: metadata,
      );
    }
    
    // Check if content is an audio URL
    if (content.contains('supabase.co/storage') && 
        (content.contains('.mp3') || content.contains('.wav') || content.contains('.m4a') || 
         content.contains('.aac') || content.contains('.ogg'))) {
      final fileName = content.split('/').last;
      final metadata = <String, dynamic>{'type': 'audio'};
      if (message.reactions != null && message.reactions!.isNotEmpty) {
        metadata['reactions'] = message.reactions!;
      }
      return types.FileMessage(
        id: message.id,
        author: types.User(id: message.senderId),
        uri: content,
        name: fileName,
        size: 0,
        createdAt: message.createdAt.millisecondsSinceEpoch,
        status: types.Status.seen,
        showStatus: message.senderId == _messageService.currentUserId,
        metadata: metadata,
      );
    }
    
    // Default: Text message
    return types.TextMessage(
      id: message.id,
      author: types.User(id: message.senderId),
      text: content,
      createdAt: message.createdAt.millisecondsSinceEpoch,
      status: types.Status.seen,
      showStatus: message.senderId == _messageService.currentUserId,
      metadata: message.reactions != null ? {'reactions': message.reactions} : null,
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

  void _handleMessageLongPress(BuildContext context, types.Message message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'React to message',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Reaction emojis
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildReactionButton('❤️', message),
                _buildReactionButton('👍', message),
                _buildReactionButton('😂', message),
                _buildReactionButton('😮', message),
                _buildReactionButton('😢', message),
                _buildReactionButton('🙏', message),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(String emoji, types.Message message) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        // Try to add reaction, if duplicate then remove it (toggle)
        final success = await _messageService.addReaction(message.id, emoji);
        if (!success) {
          // If failed (duplicate), remove it instead
          await _messageService.removeReaction(message.id, emoji);
          print('🔄 Reaction toggled: $emoji');
        } else {
          print('✅ Reaction added: $emoji');
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('🔙 Back button pressed');
        context.go('/chats');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              print('🔙 Back icon pressed');
              context.go('/chats');
            },
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
                  backgroundImage: (_chat?.isGroup == true
                          ? _chat?.avatarUrl
                          : _otherUser?.imageUrl) !=
                      null
                      ? NetworkImage(
                          _chat?.isGroup == true
                              ? _chat!.avatarUrl!
                              : _otherUser!.imageUrl!,
                        )
                      : null,
                  child: (_chat?.isGroup == true
                          ? _chat?.avatarUrl
                          : _otherUser?.imageUrl) ==
                      null
                      ? Text(
                          (_chat?.isGroup == true
                                  ? _chat?.name?.substring(0, 1)
                                  : _otherUser?.firstName?.substring(0, 1))
                              ?.toUpperCase() ??
                              '?',
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
                    _chat?.isGroup == true
                        ? (_chat?.name ?? 'Group Chat')
                        : (_otherUser?.firstName ?? 'Chat'),
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
        // actions: [
        //   PopupMenuButton<String>(
        //     icon: const Icon(Icons.more_vert),
        //     onSelected: (value) {
        //       if (value == 'clear_chat') {
        //         _showClearChatDialog();
        //       }
        //     },
        //     itemBuilder: (context) => [
        //       const PopupMenuItem(
        //         value: 'clear_chat',
        //         child: Row(
        //           children: [
        //             Icon(Icons.delete_sweep, size: 20),
        //             SizedBox(width: 12),
        //             Text('Clear Chat'),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Chat(
                  messages: _messages,
                  onSendPressed: _handleSendPressed,
                  onMessageLongPress: (context, message) {
                    // Disable long press for image grid
                    if (message is types.CustomMessage && message.metadata?['type'] == 'image_grid') {
                      return;
                    }
                    _handleMessageLongPress(context, message);
                  },
                  user: _currentUser ?? types.User(id: 'unknown'),
                  textMessageBuilder: (textMessage, {required messageWidth, required showName}) {
                    final reactions = textMessage.metadata?['reactions'] as Map<String, dynamic>?;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Original text message
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: textMessage.author.id == _currentUser?.id
                                ? const Color(0xFF667eea)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            textMessage.text,
                            style: TextStyle(
                              color: textMessage.author.id == _currentUser?.id
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Reactions below message
                        if (reactions != null && reactions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Wrap(
                              spacing: 4,
                              children: reactions.entries.map((entry) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${entry.key} ${entry.value}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    );
                  },
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
                // Image message size - WhatsApp style (smaller)
                messageMaxWidth: 250, // Max width for messages
              ),
              imageMessageBuilder: (message, {required messageWidth}) {
                final imgMsg = message as types.ImageMessage;
                final reactions = imgMsg.metadata?['reactions'] as Map<String, dynamic>?;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ImageMessageWidget(
                      message: imgMsg,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageViewer(
                              imageUrls: [imgMsg.uri],
                              initialIndex: 0,
                            ),
                          ),
                        );
                      },
                    ),
                    // Reactions below image
                    if (reactions != null && reactions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 4,
                          children: reactions.entries.map((entry) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.key} ${entry.value}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                );
              },
              fileMessageBuilder: (message, {required messageWidth}) {
                final fileMsg = message as types.FileMessage;
                final fileType = fileMsg.metadata?['type'] as String?;
                final reactions = fileMsg.metadata?['reactions'] as Map<String, dynamic>?;
                
                Widget messageWidget;
                
                // Video message
                if (fileType == 'video') {
                  messageWidget = VideoMessageWidget(
                    message: fileMsg,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            videoUrl: fileMsg.uri,
                            videoName: fileMsg.name,
                          ),
                        ),
                      );
                    },
                  );
                }
                // Document message
                else if (fileType == 'document') {
                  messageWidget = DocumentMessageWidget(
                    message: fileMsg,
                    onTap: () {
                      print('📄 Document tapped: ${fileMsg.uri}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentViewerScreen(
                            documentUrl: fileMsg.uri,
                            documentName: fileMsg.name,
                          ),
                        ),
                      );
                    },
                  );
                }
                // Audio message with player
                else if (fileType == 'audio') {
                  messageWidget = AudioPlayerWidget(
                    message: fileMsg,
                  );
                }
                // Default: Video widget
                else {
                  messageWidget = VideoMessageWidget(
                    message: fileMsg,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            videoUrl: fileMsg.uri,
                            videoName: fileMsg.name,
                          ),
                        ),
                      );
                    },
                  );
                }
                
                // Wrap with reactions
                if (reactions != null && reactions.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      messageWidget,
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 4,
                          children: reactions.entries.map((entry) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.key} ${entry.value}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }
                
                return messageWidget;
              },
              customMessageBuilder: (message, {required messageWidth}) {
                final customMsg = message as types.CustomMessage;
                if (customMsg.metadata?['type'] == 'image_grid') {
                  final urlsList = customMsg.metadata?['urls'];
                  final reactions = customMsg.metadata?['reactions'] as Map<String, dynamic>?;
                  print('📸 Grid metadata: $urlsList');
                  
                  if (urlsList == null || (urlsList as List).isEmpty) {
                    print('❌ Empty URLs list!');
                    return const SizedBox();
                  }
                  
                  final urls = (urlsList as List).cast<String>();
                  print('✅ Grid with ${urls.length} images');
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageGridWidget(
                        imageUrls: urls,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageViewer(
                                imageUrls: urls,
                                initialIndex: 0,
                              ),
                            ),
                          );
                        },
                      ),
                      // Reactions below grid
                      if (reactions != null && reactions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 4,
                            children: reactions.entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${entry.key} ${entry.value}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                }
                return const SizedBox();
              },
              showUserAvatars: true,
              showUserNames: false,
              onAttachmentPressed: _handleAttachmentPressed,
              emptyState: const EmptyChatWidget(),
            ),
                // Uploading preview overlay
                if (_uploadingFile != null)
                  UploadingPreviewWidget(
                    file: _uploadingFile!,
                    fileType: _uploadingFileType!,
                    progress: _uploadProgress,
                  ),
              ],
            ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    print('📸 Picking image from gallery...');
    final image = await FilePickerHelper.pickImageFromGallery();
    if (image != null) {
      await _uploadAndSendFile(image, 'image');
    }
  }

  Future<void> _pickImageFromCamera() async {
    print('📷 Picking image from camera...');
    final image = await FilePickerHelper.pickImageFromCamera();
    if (image != null) {
      await _uploadAndSendFile(image, 'image');
    }
  }

  Future<void> _pickVideo() async {
    print('🎥 Picking video...');
    final video = await FilePickerHelper.pickVideoFromGallery();
    if (video != null) {
      await _uploadAndSendFile(video, 'video');
    }
  }

  Future<void> _pickDocument() async {
    print('📄 Picking document...');
    final document = await FilePickerHelper.pickDocument();
    if (document != null) {
      await _uploadAndSendFile(document, 'document');
    }
  }

  Future<void> _pickAudio() async {
    print('🎵 Picking audio...');
    final audio = await FilePickerHelper.pickAudio();
    if (audio != null) {
      await _uploadAndSendFile(audio, 'audio');
    }
  }

  Future<void> _uploadAndSendFile(File file, String type) async {
    print('📤 Starting upload for $type file...');
    
    // Show uploading preview in chat
    setState(() {
      _uploadingFile = file;
      _uploadingFileType = type;
      _uploadProgress = 0.0;
    });

    // Simulate progress (since Supabase doesn't provide real progress)
    _simulateProgress();

    try {
      // Upload file
      final fileData = await _fileService.uploadFile(
        file: file,
        chatId: widget.chatId,
      );
      
      if (!mounted) return;

      // Clear uploading state
      setState(() {
        _uploadingFile = null;
        _uploadingFileType = null;
        _uploadProgress = 0.0;
      });

      if (fileData != null) {
        final url = fileData['public_url'] as String?;
        print('✅ File uploaded: $url');
        print('📝 File data: $fileData');
        
        if (url != null && url.isNotEmpty) {
          // Send message with file URL
          await _messageService.sendMessage(
            chatId: widget.chatId,
            content: url,
          );
          
          print('✅ File message sent with URL: $url');
        } else {
          print('❌ URL is null or empty');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get file URL')),
          );
        }
      } else {
        print('❌ File upload failed - fileData is null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload file')),
        );
      }
    } catch (e) {
      print('❌ Error uploading file: $e');
      
      // Clear uploading state
      setState(() {
        _uploadingFile = null;
        _uploadingFileType = null;
        _uploadProgress = 0.0;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _simulateProgress() {
    // Simulate upload progress
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_uploadingFile != null && mounted) {
        setState(() {
          _uploadProgress = 0.3;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_uploadingFile != null && mounted) {
        setState(() {
          _uploadProgress = 0.6;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_uploadingFile != null && mounted) {
        setState(() {
          _uploadProgress = 0.9;
        });
      }
    });
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat?'),
        content: const Text(
          'This will clear all messages from this chat for you only. Other participants will still see their messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearChat();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearChat() async {
    print('🗑️ Clearing chat messages...');
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // TODO: Implement clear chat logic in message service
      // For now, just clear local state
      setState(() {
        _messages.clear();
      });
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat cleared successfully')),
      );
      
      print('✅ Chat cleared');
    } catch (e) {
      print('❌ Error clearing chat: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AttachmentBottomSheet(
          onGalleryTap: () async {
            Navigator.pop(context);
            await _pickImageFromGallery();
          },
          onVideoTap: () async {
            Navigator.pop(context);
            await _pickVideo();
          },
          onDocumentTap: () async {
            Navigator.pop(context);
            await _pickDocument();
          },
          onAudioTap: () async {
            Navigator.pop(context);
            await _pickAudio();
          },
        );
      },
    );
  }

}
