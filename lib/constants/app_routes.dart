/// App route names and paths
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Root routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String home = '/home';
  static const String chatList = '/chats';
  static const String chat = '/chat/:chatId';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // User routes
  static const String userProfile = '/user/:userId';
  static const String editProfile = '/profile/edit';

  // Chat routes
  static const String newChat = '/chats/new';
  static const String chatInfo = '/chat/:chatId/info';
  static const String chatMembers = '/chat/:chatId/members';

  // Search
  static const String search = '/search';

  // Helper methods
  static String getChatRoute(String chatId) => '/chat/$chatId';
  static String getUserProfileRoute(String userId) => '/user/$userId';
  static String getChatInfoRoute(String chatId) => '/chat/$chatId/info';
  static String getChatMembersRoute(String chatId) => '/chat/$chatId/members';
}
