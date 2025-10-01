# 🔔 DevChat - OneSignal Push Notifications Setup

> **Version**: 1.0  
> **Last Updated**: October 1, 2025  
> **Estimated Time**: 1-2 hours

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [OneSignal Account Setup](#onesignal-account-setup)
3. [Android Configuration](#android-configuration)
4. [iOS Configuration](#ios-configuration)
5. [Flutter Integration](#flutter-integration)
6. [Testing Notifications](#testing-notifications)
7. [Advanced Features](#advanced-features)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

OneSignal provides push notification services for DevChat across all platforms. This guide covers complete setup for Android and iOS.

**Note**: OneSignal handles FCM (Firebase Cloud Messaging) integration natively for Android. You don't need to set up Firebase separately - OneSignal manages this for you!

### What You'll Need

- OneSignal account (free)
- Apple Developer account (for iOS)
- Flutter project with OneSignal package
- Google Play Console access (for production Android)

---

## 🚀 OneSignal Account Setup

### Step 1: Create OneSignal Account

1. Go to https://onesignal.com
2. Click "Get Started Free"
3. Sign up with email or GitHub
4. Verify your email

### Step 2: Create New App

1. Click "New App/Website"
2. Enter app name: **DevChat**
3. Select platforms:
   - ✅ Google Android (FCM)
   - ✅ Apple iOS (APNs)
4. Click "Next"

### Step 3: Save Credentials

After setup, save these from **Settings** > **Keys & IDs**:

```env
ONESIGNAL_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ONESIGNAL_REST_API_KEY=your-rest-api-key-here
```

---

## 🤖 Android Configuration

**Good News!** OneSignal handles all FCM (Firebase Cloud Messaging) setup automatically. You don't need to create a Firebase project or download any `google-services.json` file. OneSignal uses its own FCM integration.

### Step 1: Configure OneSignal for Android

1. Go to OneSignal dashboard
2. Navigate to **Settings** > **Platforms**
3. Click **Google Android (FCM)**
4. OneSignal will automatically configure FCM for you
5. Click "Save"

**Note**: OneSignal provides its own FCM sender ID and handles all the backend configuration. No Firebase Console access needed!

### Step 2: Update Android Project Files

#### android/build.gradle

```gradle
buildscript {
    ext.kotlin_version = '1.8.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

#### android/app/build.gradle

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.yourcompany.devchat"
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "com.yourcompany.devchat"
        minSdkVersion 21  // OneSignal requires minimum API 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
```

#### android/app/src/main/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <application
        android:label="DevChat"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

---

## 🍎 iOS Configuration

### Step 1: Apple Developer Setup

#### Create App ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Identifiers** > **+** button
4. Select **App IDs** > Continue
5. Fill in details:
   - **Description**: DevChat
   - **Bundle ID**: `com.yourcompany.devchat` (Explicit)
   - **Capabilities**: Check **Push Notifications**
6. Click "Register"

### Step 2: Generate APNs Auth Key (Recommended)

#### Option A: .p8 Token Authentication (Recommended)

1. Go to **Keys** section
2. Click **+** button
3. Enter **Key Name**: DevChat APNs Key
4. Check **Apple Push Notifications service (APNs)**
5. Click "Continue" > "Register"
6. **Download the .p8 file** (you can only download once!)
7. Note the **Key ID** and **Team ID**

#### Option B: .p12 Certificate (Alternative)

1. Open **Keychain Access** on Mac
2. Go to **Keychain Access** > **Certificate Assistant** > **Request a Certificate from a Certificate Authority**
3. Enter email and name, select "Saved to disk"
4. Save the CSR file
5. In Apple Developer Portal, go to **Certificates**
6. Click **+** > Select **Apple Push Notification service SSL**
7. Select your App ID
8. Upload CSR file
9. Download certificate
10. Double-click to install in Keychain
11. Export as .p12 file with password

### Step 3: Configure OneSignal with APNs

#### For .p8 Key:

1. Go to OneSignal dashboard
2. **Settings** > **Platforms** > **Apple iOS (APNs)**
3. Select **.p8 Key**
4. Upload .p8 file
5. Enter **Key ID**
6. Enter **Team ID** (found in Apple Developer account)
7. Enter **Bundle ID**: `com.yourcompany.devchat`
8. Click "Save"

#### For .p12 Certificate:

1. Select **.p12 Certificate**
2. Upload .p12 file
3. Enter password
4. Enter **Bundle ID**
5. Click "Save"

### Step 4: Configure Xcode Project

#### Open iOS Project

```bash
cd ios
open Runner.xcworkspace
```

#### Add Push Notifications Capability

1. Select **Runner** project
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Push Notifications**

#### Add Background Modes Capability

1. Click **+ Capability** again
2. Add **Background Modes**
3. Check:
   - ✅ **Remote notifications**

#### Add App Groups Capability

1. Click **+ Capability** again
2. Add **App Groups**
3. Click **+** to add new group
4. Enter: `group.com.yourcompany.devchat.onesignal`
5. Click "OK"

### Step 5: Add Notification Service Extension

#### Create Extension

1. In Xcode: **File** > **New** > **Target**
2. Select **Notification Service Extension**
3. Enter **Product Name**: `OneSignalNotificationServiceExtension`
4. Click "Finish"
5. Click "Cancel" on the activate scheme prompt

#### Configure Extension Target

1. Select **OneSignalNotificationServiceExtension** target
2. Go to **Signing & Capabilities**
3. Add **App Groups** capability
4. Add same group: `group.com.yourcompany.devchat.onesignal`
5. Set **Deployment Target** to match main app (iOS 12.0+)

#### Update NotificationService.swift

Replace contents of `OneSignalNotificationServiceExtension/NotificationService.swift`:

```swift
import UserNotifications
import OneSignalExtension

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            OneSignalExtension.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent, withContentHandler: self.contentHandler)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
}
```

#### Update Podfile

Edit `ios/Podfile`:

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  target 'OneSignalNotificationServiceExtension' do
    inherit! :search_paths
    pod 'OneSignalXCFramework', '>= 5.0.0', '< 6.0'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

#### Install Pods

```bash
cd ios
pod install
cd ..
```

---

## 📱 Flutter Integration

### Step 1: Add OneSignal Package

Edit `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  onesignal_flutter: ^5.1.2
  flutter_dotenv: ^5.1.0
```

Run:

```bash
flutter pub get
```

### Step 2: Initialize OneSignal

Edit `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize OneSignal
  await initOneSignal();
  
  runApp(const MyApp());
}

Future<void> initOneSignal() async {
  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  
  // Initialize with your OneSignal App ID
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  
  // Request notification permissions
  OneSignal.Notifications.requestPermission(true);
  
  // Set up notification handlers
  setupNotificationHandlers();
}

void setupNotificationHandlers() {
  // Handle notification received (foreground)
  OneSignal.Notifications.addForegroundLifecycleListener((event) {
    print('Notification received in foreground: ${event.notification.title}');
    // You can prevent the notification from displaying
    // event.preventDefault();
  });
  
  // Handle notification clicked
  OneSignal.Notifications.addClickListener((event) {
    print('Notification clicked: ${event.notification.title}');
    // Navigate to specific screen based on notification data
    final data = event.notification.additionalData;
    if (data != null) {
      final chatId = data['chat_id'];
      if (chatId != null) {
        // Navigate to chat screen
        // navigatorKey.currentState?.pushNamed('/chat', arguments: chatId);
      }
    }
  });
  
  // Handle permission changes
  OneSignal.Notifications.addPermissionObserver((state) {
    print('Permission state changed: $state');
  });
  
  // Handle subscription changes
  OneSignal.User.pushSubscription.addObserver((state) {
    print('Subscription state: ${state.current.jsonRepresentation()}');
    final playerId = state.current.id;
    if (playerId != null) {
      print('Player ID: $playerId');
      // Save player ID to your backend
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevChat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

### Step 3: Create Notification Service

Create `lib/services/notification_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static const String _baseUrl = 'https://api.onesignal.com/notifications';
  
  /// Get current user's Player ID
  static String? getPlayerId() {
    return OneSignal.User.pushSubscription.id;
  }
  
  /// Set external user ID (link OneSignal to your user ID)
  static Future<void> setExternalUserId(String userId) async {
    await OneSignal.login(userId);
  }
  
  /// Remove external user ID (logout)
  static Future<void> removeExternalUserId() async {
    await OneSignal.logout();
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
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Key ${dotenv.env['ONESIGNAL_REST_API_KEY']}',
        },
        body: jsonEncode({
          'app_id': dotenv.env['ONESIGNAL_APP_ID'],
          'include_external_user_ids': [userId],
          'headings': {'en': title},
          'contents': {'en': message},
          if (data != null) 'data': data,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
  
  /// Send notification to specific Player ID
  static Future<bool> sendNotificationToPlayerId({
    required String playerId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Key ${dotenv.env['ONESIGNAL_REST_API_KEY']}',
        },
        body: jsonEncode({
          'app_id': dotenv.env['ONESIGNAL_APP_ID'],
          'include_subscription_ids': [playerId],
          'headings': {'en': title},
          'contents': {'en': message},
          if (data != null) 'data': data,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
  
  /// Send notification to all users
  static Future<bool> sendNotificationToAll({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Key ${dotenv.env['ONESIGNAL_REST_API_KEY']}',
        },
        body: jsonEncode({
          'app_id': dotenv.env['ONESIGNAL_APP_ID'],
          'included_segments': ['Subscribed Users'],
          'headings': {'en': title},
          'contents': {'en': message},
          if (data != null) 'data': data,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
}
```

---

## 🧪 Testing Notifications

### Test 1: Send Test from Dashboard

1. Go to OneSignal dashboard
2. Click **Messages** > **New Push**
3. Select **Send to Test Device**
4. Enter your Player ID (get from app logs)
5. Enter message
6. Click "Send Message"

### Test 2: Send from Flutter App

Create a test screen:

```dart
class TestNotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Player ID: ${NotificationService.getPlayerId()}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final playerId = NotificationService.getPlayerId();
                if (playerId != null) {
                  await NotificationService.sendNotificationToPlayerId(
                    playerId: playerId,
                    title: 'Test Notification',
                    message: 'This is a test message!',
                    data: {'test': 'data'},
                  );
                }
              },
              child: Text('Send Test Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Test 3: Verify Delivery

1. Check OneSignal dashboard > **Delivery** tab
2. View delivery status
3. Check for errors

---

## 🚀 Advanced Features

### Tags & Segmentation

```dart
// Add tags to user
OneSignal.User.addTag('user_type', 'premium');
OneSignal.User.addTags({'language': 'en', 'country': 'US'});

// Remove tags
OneSignal.User.removeTag('user_type');
OneSignal.User.removeTags(['language', 'country']);
```

### In-App Messages

```dart
// Add trigger
OneSignal.InAppMessages.addTrigger('level', '10');

// Pause in-app messages
OneSignal.InAppMessages.paused(true);
```

### Email & SMS

```dart
// Add email
OneSignal.User.addEmail('user@example.com');

// Add SMS
OneSignal.User.addSms('+1234567890');
```

---

## 🐛 Troubleshooting

### Android Issues

**Issue**: Notifications not received
- Verify OneSignal App ID is correct in `.env` file
- Ensure app has notification permissions (Android 13+)
- Check OneSignal dashboard for delivery errors
- Verify device is subscribed (check Player ID)
- Test on physical device (emulator needs Google Play Services)

**Issue**: Build errors
- Run `flutter clean` and `flutter pub get`
- Check Gradle versions are compatible
- Verify `minSdkVersion` is at least 21
- Check Android SDK is properly installed

### iOS Issues

**Issue**: Notifications not received
- Verify APNs certificate/key is valid
- Check Bundle ID matches
- Ensure device has notification permissions
- Test on physical device (simulator doesn't support push)

**Issue**: Build errors
- Run `pod install` in ios directory
- Clean build folder in Xcode
- Verify NSE target is configured correctly

---

## 📚 Additional Resources

- [OneSignal Documentation](https://documentation.onesignal.com)
- [OneSignal Flutter SDK](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [OneSignal REST API](https://documentation.onesignal.com/reference/create-notification)
- [Apple Developer Portal](https://developer.apple.com)
- [Google Play Console](https://play.google.com/console)

---

**Document Version**: 1.0  
**Last Updated**: October 1, 2025  
**Need Help?** Contact OneSignal support or check their Discord
