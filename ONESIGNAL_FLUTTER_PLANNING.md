# OneSignal Flutter Push Notification Integration - Planning Document

## 📋 Project Overview
This document outlines the complete planning and implementation strategy for integrating OneSignal push notifications into a Flutter application. This is a **planning phase document** - no actual code implementation yet.

---

## 🎯 Project Requirements

### Core Features
1. ✅ Initialize OneSignal SDK in `main.dart` with App ID
2. ✅ Handle notification received events (foreground)
3. ✅ Handle notification clicked events
4. ✅ REST API integration for sending test notifications
5. ✅ Simple UI with "Send Test Notification" button
6. ✅ Complete setup for both Android and iOS platforms

---

## 📦 Dependencies Required

### pubspec.yaml Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  onesignal_flutter: ^5.1.2  # Latest stable version
  http: ^1.1.0               # For REST API calls
  flutter_dotenv: ^5.1.0     # For environment variables (API keys)
```

### Dev Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## 🔑 OneSignal Configuration Setup

### Prerequisites
1. **Create OneSignal Account**: https://onesignal.com/
2. **Create New App** in OneSignal Dashboard
3. **Obtain Credentials**:
   - OneSignal App ID (from Settings > Keys & IDs)
   - REST API Key (from Settings > Keys & IDs)
   - For iOS: Apple Push Notification certificate (.p8 token or .p12 certificate)
   - For Android: OneSignal handles FCM natively (no Firebase setup needed!)

### Configuration Steps
1. Navigate to OneSignal Dashboard
2. Go to Settings > Platforms
3. Configure Android (OneSignal manages FCM automatically)
4. Configure iOS (Apple Push Notification Service)
5. Save App ID and REST API Key securely

---

## 📱 Android Setup Requirements

### 1. OneSignal Configuration (No Firebase Needed!)
- OneSignal handles all FCM (Firebase Cloud Messaging) setup automatically
- No need to create Firebase project
- No `google-services.json` file required
- OneSignal provides its own FCM sender ID

### 2. Gradle Configuration

#### android/build.gradle
```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.0'
        // No google-services plugin needed!
    }
}
```

#### android/app/build.gradle
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21  // OneSignal requires API 21+
        targetSdkVersion 34
    }
}
```

### 3. AndroidManifest.xml Permissions
```xml
<manifest>
    <!-- Required for push notifications -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <!-- Optional: For location-based notifications -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <application>
        <!-- Notification icon (optional custom icon) -->
        <meta-data 
            android:name="com.onesignal.NotificationAccentColor.DEFAULT"
            android:value="FF0000FF" />
    </application>
</manifest>
```

### 4. Notification Icons
- Create notification icons in `android/app/src/main/res/drawable/`
- Recommended sizes: 
  - drawable-mdpi: 24x24px
  - drawable-hdpi: 36x36px
  - drawable-xhdpi: 48x48px
  - drawable-xxhdpi: 72x72px
  - drawable-xxxhdpi: 96x96px

---

## 🍎 iOS Setup Requirements

### 1. Apple Developer Account Setup
- Enroll in Apple Developer Program
- Create App ID with Push Notifications capability
- Generate APNs Authentication Key (.p8) or Certificate (.p12)

### 2. Xcode Configuration Steps

#### Step 1: Open Xcode Project
```bash
cd ios
open Runner.xcworkspace
```

#### Step 2: Add Push Notifications Capability
1. Select Runner target
2. Go to "Signing & Capabilities"
3. Click "+ Capability"
4. Add "Push Notifications"

#### Step 3: Add Background Modes Capability
1. Add "Background Modes" capability
2. Enable "Remote notifications" checkbox

#### Step 4: Configure App Groups
1. Add "App Groups" capability
2. Create new container: `group.YOUR_BUNDLE_ID.onesignal`
   - Example: `group.com.example.myapp.onesignal`

#### Step 5: Add Notification Service Extension (NSE)
1. File > New > Target
2. Select "Notification Service Extension"
3. Name it: `OneSignalNotificationServiceExtension`
4. Click "Finish" (Don't activate scheme)
5. Set deployment target same as main app

#### Step 6: Configure NSE Target
1. Select NSE target > Signing & Capabilities
2. Add "App Groups" capability
3. Add same group ID: `group.YOUR_BUNDLE_ID.onesignal`

#### Step 7: Update NSE Code
File: `ios/OneSignalNotificationServiceExtension/NotificationService.swift`
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

#### Step 8: Update Podfile
File: `ios/Podfile`
```ruby
target 'OneSignalNotificationServiceExtension' do
  use_frameworks!
  pod 'OneSignalXCFramework', '>= 5.0.0', '< 6.0'
end
```

### 3. Info.plist Configuration
No additional Info.plist changes required for basic setup.

---

## 💻 Flutter Application Structure

### Project File Structure
```
lib/
├── main.dart                      # App entry point, OneSignal initialization
├── screens/
│   └── home_screen.dart          # Main UI with notification button
├── services/
│   ├── onesignal_service.dart    # OneSignal event handlers
│   └── notification_api_service.dart  # REST API for sending notifications
├── models/
│   └── notification_model.dart   # Notification data models
└── utils/
    └── constants.dart            # App constants (App ID, etc.)

.env                               # Environment variables (API keys)
pubspec.yaml                       # Dependencies
README.md                          # Project documentation
```

---

## 🔧 Implementation Plan

### Phase 1: Basic Setup
1. **Create Flutter Project**
   ```bash
   flutter create onesignal_demo_app
   cd onesignal_demo_app
   ```

2. **Add Dependencies** to `pubspec.yaml`

3. **Create .env File** for sensitive data
   ```env
   ONESIGNAL_APP_ID=your_app_id_here
   ONESIGNAL_REST_API_KEY=your_rest_api_key_here
   ```

4. **Initialize OneSignal in main.dart**
   - Import OneSignal package
   - Set log level for debugging
   - Initialize with App ID
   - Request notification permissions

### Phase 2: Event Handlers
1. **Create OneSignal Service Class**
   - Setup notification click listener
   - Setup foreground notification listener
   - Setup permission observer
   - Setup subscription observer

2. **Handle Notification Events**
   - Log notification received (foreground)
   - Handle notification clicked (with deep linking support)
   - Track permission changes
   - Track subscription changes

### Phase 3: UI Development
1. **Create Home Screen**
   - App bar with title
   - Display subscription status
   - Display OneSignal Player ID
   - "Send Test Notification" button
   - Notification log display area

2. **Implement Material Design**
   - Use modern Flutter widgets
   - Responsive layout
   - Loading indicators
   - Success/error messages

### Phase 4: REST API Integration
1. **Create Notification API Service**
   - HTTP POST to OneSignal API
   - Target specific device (Player ID)
   - Custom notification content
   - Error handling

2. **API Endpoint**: `https://api.onesignal.com/notifications`

3. **Request Headers**:
   - `Content-Type: application/json`
   - `Authorization: Key YOUR_REST_API_KEY`

4. **Request Body Structure**:
   ```json
   {
     "app_id": "YOUR_APP_ID",
     "include_subscription_ids": ["PLAYER_ID"],
     "contents": {
       "en": "Test notification message"
     },
     "headings": {
       "en": "Test Notification"
     }
   }
   ```

### Phase 5: Testing
1. **Android Testing**
   - Test on physical device
   - Test on emulator with Google Play Services
   - Verify notification received in foreground
   - Verify notification clicked opens app
   - Test REST API notification sending

2. **iOS Testing**
   - Test on physical device (required for push)
   - Verify permission prompt appears
   - Test notification received in foreground
   - Test notification clicked opens app
   - Test REST API notification sending

---

## 📝 Key Code Components

### 1. main.dart - OneSignal Initialization
```dart
// Pseudo-code structure
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  
  // Enable debug logging
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  
  // Initialize OneSignal
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  
  // Request permission (iOS will show prompt, Android 13+ will show prompt)
  OneSignal.Notifications.requestPermission(true);
  
  runApp(MyApp());
}
```

### 2. OneSignal Service - Event Handlers
```dart
// Pseudo-code structure
class OneSignalService {
  static void initialize() {
    // Notification clicked handler
    OneSignal.Notifications.addClickListener((event) {
      print('Notification clicked: ${event.notification.title}');
      // Handle deep linking or navigation
    });
    
    // Foreground notification handler
    OneSignal.Notifications.addForegroundLifecycleListener((event) {
      print('Foreground notification: ${event.notification.title}');
      // Optionally prevent display: event.preventDefault()
    });
    
    // Permission observer
    OneSignal.Notifications.addPermissionObserver((state) {
      print('Permission changed: $state');
    });
    
    // Subscription observer
    OneSignal.User.pushSubscription.addObserver((state) {
      print('Subscription changed: ${state.current.id}');
    });
  }
  
  static String? getPlayerId() {
    return OneSignal.User.pushSubscription.id;
  }
}
```

### 3. Notification API Service - Send Notification
```dart
// Pseudo-code structure
class NotificationApiService {
  static const String baseUrl = 'https://api.onesignal.com/notifications';
  
  static Future<bool> sendTestNotification(String playerId) async {
    final apiKey = dotenv.env['ONESIGNAL_REST_API_KEY']!;
    final appId = dotenv.env['ONESIGNAL_APP_ID']!;
    
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Key $apiKey',
      },
      body: jsonEncode({
        'app_id': appId,
        'include_subscription_ids': [playerId],
        'contents': {'en': 'This is a test notification!'},
        'headings': {'en': 'Test Notification'},
      }),
    );
    
    return response.statusCode == 200;
  }
}
```

### 4. Home Screen - UI
```dart
// Pseudo-code structure
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? playerId;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadPlayerId();
  }
  
  void _loadPlayerId() {
    setState(() {
      playerId = OneSignalService.getPlayerId();
    });
  }
  
  Future<void> _sendTestNotification() async {
    if (playerId == null) return;
    
    setState(() => isLoading = true);
    
    final success = await NotificationApiService.sendTestNotification(playerId!);
    
    setState(() => isLoading = false);
    
    // Show success/error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Notification sent!' : 'Failed to send')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OneSignal Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Player ID: ${playerId ?? "Loading..."}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _sendTestNotification,
              child: isLoading 
                ? CircularProgressIndicator()
                : Text('Send Test Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔐 Security Best Practices

### 1. Environment Variables
- **Never commit** API keys to version control
- Use `.env` file for local development
- Add `.env` to `.gitignore`
- Use platform-specific secure storage for production

### 2. API Key Protection
- REST API Key should **never** be in client-side code for production
- For production: Create backend server to send notifications
- Client app should call your backend, not OneSignal directly

### 3. .gitignore Additions
```gitignore
# OneSignal
.env
.env.local
.env.production

# Android
android/app/google-services.json

# iOS
ios/Runner/GoogleService-Info.plist
```

---

## 🧪 Testing Strategy

### Manual Testing Checklist

#### Android
- [ ] App installs successfully
- [ ] Permission prompt appears (Android 13+)
- [ ] Player ID is generated
- [ ] Foreground notification received
- [ ] Background notification received
- [ ] Notification clicked opens app
- [ ] REST API sends notification successfully
- [ ] Notification icon displays correctly
- [ ] Sound and vibration work

#### iOS
- [ ] App installs successfully
- [ ] Permission prompt appears
- [ ] Player ID is generated
- [ ] Foreground notification received
- [ ] Background notification received
- [ ] Notification clicked opens app
- [ ] REST API sends notification successfully
- [ ] Badge count updates
- [ ] Sound works

### Testing Tools
1. **OneSignal Dashboard**: Send test notifications
2. **Postman/cURL**: Test REST API directly
3. **Flutter DevTools**: Debug logs and network calls
4. **Xcode Console**: iOS-specific logs
5. **Android Studio Logcat**: Android-specific logs

### Test Notification via cURL
```bash
curl -X POST https://api.onesignal.com/notifications \
  -H "Content-Type: application/json" \
  -H "Authorization: Key YOUR_REST_API_KEY" \
  -d '{
    "app_id": "YOUR_APP_ID",
    "include_subscription_ids": ["PLAYER_ID"],
    "contents": {"en": "Test from cURL"},
    "headings": {"en": "Test Notification"}
  }'
```

---

## 🐛 Common Issues & Troubleshooting

### Issue 1: No Player ID Generated
**Symptoms**: `OneSignal.User.pushSubscription.id` returns null

**Solutions**:
- Check internet connection
- Verify App ID is correct
- Ensure permissions are granted
- Check OneSignal initialization timing
- For iOS: Verify APNs certificate is valid
- For Android: Verify OneSignal App ID is correct

### Issue 2: Notifications Not Received
**Symptoms**: Notifications sent but not appearing

**Solutions**:
- Check device notification settings
- Verify app is not in battery optimization
- Check OneSignal dashboard for delivery status
- Verify Player ID is correct
- For iOS: Check device is not in Do Not Disturb
- For Android: Check notification channels

### Issue 3: iOS Build Errors
**Symptoms**: Build fails with OneSignal-related errors

**Solutions**:
- Run `pod install` in ios directory
- Clean build folder (Xcode > Product > Clean Build Folder)
- Update CocoaPods: `pod repo update`
- Verify NSE target configuration
- Check deployment target matches

### Issue 4: Android Build Errors
**Symptoms**: Build fails with Gradle errors

**Solutions**:
- Verify `google-services.json` is in correct location
- Check Gradle plugin versions
- Run `flutter clean` and rebuild
- Verify minSdkVersion is 21 or higher
- Check AndroidManifest.xml syntax

### Issue 5: REST API Returns 400 Error
**Symptoms**: API call fails with 400 Bad Request

**Solutions**:
- Verify REST API Key is correct
- Check request body JSON format
- Ensure Player ID is valid
- Verify App ID matches
- Check authorization header format

---

## 📚 Additional Resources

### Official Documentation
- [OneSignal Flutter SDK Setup](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [OneSignal Mobile SDK Reference](https://documentation.onesignal.com/docs/mobile-sdk-reference)
- [OneSignal REST API](https://documentation.onesignal.com/reference/create-message)
- [Flutter Push Notifications Guide](https://flutter.dev/docs/development/platform-integration/platform-channels)

### OneSignal Dashboard Links
- [Dashboard Home](https://dashboard.onesignal.com)
- [Settings > Keys & IDs](https://dashboard.onesignal.com/apps)
- [Messages > New Push](https://dashboard.onesignal.com/messages)
- [Audience > Subscriptions](https://dashboard.onesignal.com/audience)

### Platform-Specific Guides
- [iOS APNs Configuration](https://documentation.onesignal.com/docs/ios-p8-token-based-connection-to-apns)
- [Notification Icons (Android)](https://documentation.onesignal.com/docs/notification-icons)
- [iOS Badges](https://documentation.onesignal.com/docs/badges)
- [Android Setup](https://documentation.onesignal.com/docs/android-sdk-setup)

### Advanced Features
- [Deep Linking](https://documentation.onesignal.com/docs/deep-linking)
- [Action Buttons](https://documentation.onesignal.com/docs/action-buttons)
- [In-App Messages](https://documentation.onesignal.com/docs/in-app-messages)
- [Segmentation](https://documentation.onesignal.com/docs/segmentation)
- [Data Tags](https://documentation.onesignal.com/docs/data-tags)

---

## 🚀 Next Steps After Planning

### Immediate Actions
1. ✅ Create OneSignal account and app
2. ✅ Obtain App ID and REST API Key
3. ✅ Configure OneSignal for Android (automatic FCM)
4. ✅ Setup Apple Developer certificates (iOS)
5. ✅ Create Flutter project structure

### Development Phase
1. Implement basic Flutter app structure
2. Add OneSignal SDK initialization
3. Setup event handlers
4. Create UI components
5. Implement REST API service
6. Add error handling and logging

### Testing Phase
1. Test on Android physical device
2. Test on iOS physical device
3. Verify all notification scenarios
4. Test REST API integration
5. Performance testing

### Production Preparation
1. Remove debug logging
2. Secure API keys properly
3. Implement backend notification service
4. Add analytics tracking
5. Create user documentation
6. Submit to app stores

---

## 📊 Project Timeline Estimate

| Phase | Duration | Tasks |
|-------|----------|-------|
| **Setup & Configuration** | 1-2 hours | OneSignal account, Apple certificates, project setup |
| **Core Implementation** | 4-6 hours | SDK integration, event handlers, UI development |
| **REST API Integration** | 2-3 hours | API service, error handling, testing |
| **Platform Configuration** | 2-3 hours | Android/iOS specific setup, permissions, NSE |
| **Testing & Debugging** | 3-5 hours | Device testing, bug fixes, edge cases |
| **Documentation** | 1-2 hours | Code comments, README, user guide |
| **Total** | **15-23 hours** | Complete implementation |

---

## ✅ Success Criteria

The project will be considered successful when:

1. ✅ App initializes OneSignal without errors
2. ✅ Player ID is generated on both platforms
3. ✅ Foreground notifications are received and displayed
4. ✅ Background notifications are received
5. ✅ Notification clicks open the app correctly
6. ✅ "Send Test Notification" button works
7. ✅ REST API successfully sends notifications
8. ✅ All permissions are properly configured
9. ✅ No console errors or warnings
10. ✅ App works on both Android and iOS

---

## 📝 Notes

- This is a **planning document** - no actual code has been implemented yet
- All code snippets are pseudo-code for planning purposes
- Actual implementation should follow this structure
- Security considerations must be addressed before production
- Testing should be thorough on both platforms
- Consider creating a backend service for production notification sending

---

## 🤝 Support & Contact

For issues or questions:
- OneSignal Support: support@onesignal.com
- OneSignal Documentation: https://documentation.onesignal.com
- OneSignal Community: https://github.com/OneSignal
- Flutter Documentation: https://flutter.dev/docs

---

**Document Version**: 1.0  
**Last Updated**: October 1, 2025  
**Status**: Planning Phase  
**Ready for Implementation**: ✅ Yes
