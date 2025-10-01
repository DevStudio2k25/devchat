import 'package:flutter/material.dart';
import 'package:devchat/config/router_config.dart' as app_router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize environment variables
  // await EnvConfig.initialize();
  
  // TODO: Initialize Supabase
  // await Supabase.initialize(
  //   url: EnvConfig.supabaseUrl,
  //   anonKey: EnvConfig.supabaseAnonKey,
  // );
  
  // TODO: Initialize OneSignal
  // OneSignal.initialize(EnvConfig.oneSignalAppId);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
    );
  }
}
