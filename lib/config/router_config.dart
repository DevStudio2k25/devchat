import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:devchat/constants/app_routes.dart';
import 'package:devchat/screens/auth/login_screen.dart';
import 'package:devchat/screens/auth/signup_screen.dart';
import 'package:devchat/screens/auth/forgot_password_screen.dart';
import 'package:devchat/screens/chat/chat_list_screen.dart';
import 'package:devchat/screens/chat/chat_screen.dart';
import 'package:devchat/screens/chat/user_search_screen.dart';
import 'package:devchat/screens/profile/profile_screen.dart';
import 'package:devchat/screens/profile/edit_profile_screen.dart';

/// Router configuration for the app
class RouterConfig {
  // Private constructor
  RouterConfig._();

  /// Global navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    
    // Redirect logic for authentication
    redirect: (BuildContext context, GoRouterState state) {
      // TODO: Implement auth redirect logic
      // Check if user is authenticated
      // If not authenticated and trying to access protected route, redirect to login
      // If authenticated and trying to access auth route, redirect to home
      return null; // No redirect for now
    },

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),

    // Routes
    routes: [
      // Splash / Root - redirect to login
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        redirect: (context, state) => AppRoutes.login,
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main app routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
      ),
      GoRoute(
        path: AppRoutes.chatList,
        name: 'chatList',
        builder: (context, state) => const ChatListScreen(),
      ),

      // Chat route with parameter
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          return ChatScreen(chatId: chatId);
        },
        routes: [
          // Chat info
          GoRoute(
            path: 'info',
            name: 'chatInfo',
            builder: (context, state) {
              final chatId = state.pathParameters['chatId'] ?? '';
              return _PlaceholderScreen(title: 'Chat Info: $chatId');
            },
          ),
          // Chat members
          GoRoute(
            path: 'members',
            name: 'chatMembers',
            builder: (context, state) {
              final chatId = state.pathParameters['chatId'] ?? '';
              return _PlaceholderScreen(title: 'Chat Members: $chatId');
            },
          ),
        ],
      ),

      // Profile routes
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'editProfile',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),

      // User profile with parameter
      GoRoute(
        path: AppRoutes.userProfile,
        name: 'userProfile',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return _PlaceholderScreen(title: 'User Profile: $userId');
        },
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Settings'),
      ),

      // Search
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const _PlaceholderScreen(title: 'Search'),
      ),

      // New chat
      GoRoute(
        path: AppRoutes.newChat,
        name: 'newChat',
        builder: (context, state) => const UserSearchScreen(),
      ),
    ],
  );
}

/// Placeholder screen for routes (temporary until actual screens are created)
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('This screen is under construction'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
