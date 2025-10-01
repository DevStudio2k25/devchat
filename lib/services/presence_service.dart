import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Update user online status
  Future<bool> setOnlineStatus(bool isOnline) async {
    if (currentUserId == null) return false;

    try {
      final status = isOnline ? 'online' : 'offline';
      await _supabase.from('users').update({
        'status': status,
        'last_seen': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUserId!);

      print('✅ User status updated: $status');
      return true;
    } catch (e) {
      print('❌ Error updating status: $e');
      return false;
    }
  }

  /// Set user as online
  Future<bool> setOnline() => setOnlineStatus(true);

  /// Set user as offline
  Future<bool> setOffline() => setOnlineStatus(false);

  /// Update last seen timestamp
  Future<bool> updateLastSeen() async {
    if (currentUserId == null) return false;

    try {
      await _supabase.from('users').update({
        'last_seen': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUserId!);

      return true;
    } catch (e) {
      print('❌ Error updating last seen: $e');
      return false;
    }
  }

  /// Set user status (online, offline, away, busy)
  Future<bool> setStatus(String status) async {
    if (currentUserId == null) return false;

    try {
      await _supabase.from('users').update({
        'status': status,
        'last_seen': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUserId!);

      print('✅ User status set to: $status');
      return true;
    } catch (e) {
      print('❌ Error setting status: $e');
      return false;
    }
  }

  /// Handle app lifecycle changes
  void handleAppLifecycleChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        setOnline();
        break;
      case AppLifecycleState.paused:
        // App is in background
        updateLastSeen();
        break;
      case AppLifecycleState.inactive:
        // App is inactive
        updateLastSeen();
        break;
      case AppLifecycleState.detached:
        // App is detached
        setOffline();
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        updateLastSeen();
        break;
    }
  }

  /// Stream user presence
  Stream<Map<String, dynamic>?> streamUserPresence(String userId) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .map((data) {
          final user = data.where((u) => u['id'] == userId).toList();
          if (user.isEmpty) return null;
          return user.first;
        });
  }

  /// Get formatted last seen text
  static String getLastSeenText(DateTime? lastSeen, String? status) {
    if (status == 'online') {
      return 'Online';
    }

    if (lastSeen == null) {
      return 'Offline';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return 'Last seen ${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }

  /// Get status color
  static Color getStatusColor(String? status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'busy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
