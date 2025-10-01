import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:devchat/config/env_config.dart';
import 'package:devchat/config/router_config.dart' as app_router;
import 'package:devchat/providers/auth_provider.dart';
import 'package:devchat/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment variables
  await EnvConfig.initialize();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
  
  // Initialize OneSignal (Android only)
  await _initializeOneSignal();
  
  runApp(const MyApp());
}

/// Initialize OneSignal for push notifications
Future<void> _initializeOneSignal() async {
  // Initialize OneSignal
  OneSignal.initialize(EnvConfig.oneSignalAppId);

  // Request notification permission (Android 13+)
  await OneSignal.Notifications.requestPermission(true);

  // Set up notification handlers
  NotificationService.setupHandlers();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'DevChat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.system,
        routerConfig: app_router.RouterConfig.router,
      ),
    );
  }
}
