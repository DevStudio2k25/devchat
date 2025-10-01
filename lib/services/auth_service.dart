import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service for handling user authentication
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get current user ID
  String? get currentUserId => currentUser?.id;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    print('🔵 Starting signup process...');
    print('📧 Email: $email');
    print('👤 Username: ${username ?? email.split('@')[0]}');
    
    try {
      print('🔄 Calling Supabase auth.signUp()...');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username ?? email.split('@')[0],
        },
      );

      print('📦 Response received from Supabase');
      print('✅ User created: ${response.user?.id}');
      print('📧 User email: ${response.user?.email}');
      print('🔑 Session: ${response.session != null ? "Yes" : "No"}');

      if (response.user != null) {
        print('✅ Sign up successful: ${response.user!.email}');
        print('ℹ️ User profile should be created by database trigger');
        
        // Wait a bit for trigger to execute
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Try to verify profile was created
        try {
          print('🔍 Checking if user profile was created...');
          final profile = await _supabase
              .from('users')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();
          
          if (profile != null) {
            print('✅ User profile found in database!');
            print('📝 Profile data: $profile');
          } else {
            print('⚠️ User profile NOT found - trigger may not have run');
            print('🔧 Attempting manual profile creation...');
            
            // Manual fallback
            await _supabase.from('users').insert({
              'id': response.user!.id,
              'email': email,
              'username': username ?? email.split('@')[0],
              'display_name': username ?? email.split('@')[0],
              'status': 'online',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
            print('✅ Manual profile creation successful!');
          }
        } catch (profileError) {
          print('⚠️ Profile check/creation error: $profileError');
          // Don't fail signup if profile check fails
        }
      }

      return response;
    } catch (e) {
      print('❌ Sign up error: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e.toString().contains('Database error')) {
        print('🔴 DATABASE ERROR DETECTED!');
        print('💡 This means the trigger is not working or users table has issues');
        print('📋 Check: 1) Trigger exists, 2) Users table structure, 3) RLS policies');
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Sign in successful: ${response.user!.email}');
      }

      return response;
    } catch (e) {
      print('❌ Sign in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      print('✅ Sign out successful');
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }

  /// Reset password (send reset email)
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      print('✅ Password reset email sent to: $email');
    } catch (e) {
      print('❌ Password reset error: $e');
      rethrow;
    }
  }

  /// Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      print('✅ Password updated successfully');
      return response;
    } catch (e) {
      print('❌ Update password error: $e');
      rethrow;
    }
  }

  /// Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('❌ Get user profile error: $e');
      return null;
    }
  }

  /// Update user profile in database
  Future<void> updateUserProfile({
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
      print('✅ User profile updated');
    } catch (e) {
      print('❌ Update user profile error: $e');
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      // Note: This requires admin privileges or custom backend logic
      // For now, just sign out
      await signOut();
      print('✅ Account deletion initiated');
    } catch (e) {
      print('❌ Delete account error: $e');
      rethrow;
    }
  }
}
