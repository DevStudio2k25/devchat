import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:devchat/config/env_config.dart';

class NotificationService {
  /// Setup OneSignal notification handlers
  static void setupHandlers() {
    // Handle notification received (when app is in foreground)
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('📬 Notification received in foreground: ${event.notification.title}');
      // Display notification even in foreground
      event.preventDefault();
      event.notification.display();
    });

    // Handle notification clicked
    OneSignal.Notifications.addClickListener((event) {
      print('🔔 Notification clicked: ${event.notification.title}');
      _handleNotificationClick(event.notification);
    });

    // Handle permission changes
    OneSignal.Notifications.addPermissionObserver((state) {
      print('🔐 Notification permission changed: $state');
    });
  }

  /// Handle notification click
  static void _handleNotificationClick(OSNotification notification) {
    // Get additional data
    final data = notification.additionalData;
    
    if (data != null) {
      // Handle different notification types
      final type = data['type'] as String?;
      final chatId = data['chat_id'] as String?;
      
      switch (type) {
        case 'new_message':
          if (chatId != null) {
            // TODO: Navigate to chat screen
            print('Navigate to chat: $chatId');
          }
          break;
        case 'mention':
          if (chatId != null) {
            // TODO: Navigate to chat and highlight mention
            print('Navigate to mention in chat: $chatId');
          }
          break;
        case 'group_invite':
          if (chatId != null) {
            // TODO: Navigate to group info
            print('Navigate to group: $chatId');
          }
          break;
        default:
          print('Unknown notification type: $type');
      }
    }
  }

  /// Send notification to specific user
  static Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${EnvConfig.oneSignalRestApiKey}',
        },
        body: jsonEncode({
          'app_id': EnvConfig.oneSignalAppId,
          'include_external_user_ids': [userId],
          'headings': {'en': title},
          'contents': {'en': message},
          if (data != null) 'data': data,
          'android_channel_id': 'devchat_messages',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully');
        return true;
      } else {
        print('❌ Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
      return false;
    }
  }

  /// Send notification for new message
  static Future<bool> sendNewMessageNotification({
    required String recipientUserId,
    required String senderName,
    required String messageContent,
    required String chatId,
  }) async {
    return sendNotificationToUser(
      userId: recipientUserId,
      title: senderName,
      message: messageContent,
      data: {
        'type': 'new_message',
        'chat_id': chatId,
      },
    );
  }

  /// Send notification for mention
  static Future<bool> sendMentionNotification({
    required String recipientUserId,
    required String senderName,
    required String chatName,
    required String chatId,
  }) async {
    return sendNotificationToUser(
      userId: recipientUserId,
      title: '$senderName mentioned you',
      message: 'in $chatName',
      data: {
        'type': 'mention',
        'chat_id': chatId,
      },
    );
  }

  /// Send notification for group invite
  static Future<bool> sendGroupInviteNotification({
    required String recipientUserId,
    required String inviterName,
    required String groupName,
    required String chatId,
  }) async {
    return sendNotificationToUser(
      userId: recipientUserId,
      title: 'Group Invitation',
      message: '$inviterName invited you to $groupName',
      data: {
        'type': 'group_invite',
        'chat_id': chatId,
      },
    );
  }

  /// Set external user ID (link OneSignal with your user ID)
  static Future<void> setExternalUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      print('✅ OneSignal external user ID set: $userId');
    } catch (e) {
      print('❌ Error setting external user ID: $e');
    }
  }

  /// Remove external user ID (on logout)
  static Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      print('✅ OneSignal external user ID removed');
    } catch (e) {
      print('❌ Error removing external user ID: $e');
    }
  }

  /// Get notification permission status
  static Future<bool> hasPermission() async {
    return await OneSignal.Notifications.permission;
  }

  /// Request notification permission
  static Future<bool> requestPermission() async {
    return await OneSignal.Notifications.requestPermission(true);
  }
}
