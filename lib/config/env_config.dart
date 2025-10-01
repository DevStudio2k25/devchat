import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration class
/// Loads and provides access to environment variables
class EnvConfig {
  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // OneSignal Configuration
  static String get oneSignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  static String get oneSignalRestApiKey =>
      dotenv.env['ONESIGNAL_REST_API_KEY'] ?? '';

  // Environment
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  // Helper methods
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  /// Initialize environment variables
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  /// Validate that all required environment variables are set
  static bool validate() {
    final requiredVars = [
      'SUPABASE_URL',
      'SUPABASE_ANON_KEY',
      'ONESIGNAL_APP_ID',
    ];

    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        print('❌ Missing required environment variable: $varName');
        return false;
      }
    }

    print('✅ All required environment variables are set');
    return true;
  }

  /// Print configuration (for debugging - don't use in production)
  static void printConfig() {
    if (!isProduction) {
      print('🔧 Environment Configuration:');
      print('   Environment: $environment');
      print('   Supabase URL: ${supabaseUrl.isNotEmpty ? "✓ Set" : "✗ Missing"}');
      print('   Supabase Key: ${supabaseAnonKey.isNotEmpty ? "✓ Set" : "✗ Missing"}');
      print('   OneSignal App ID: ${oneSignalAppId.isNotEmpty ? "✓ Set" : "✗ Missing"}');
      print('   OneSignal API Key: ${oneSignalRestApiKey.isNotEmpty ? "✓ Set" : "✗ Missing"}');
    }
  }
}
