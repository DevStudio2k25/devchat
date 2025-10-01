# 📦 DevChat - Package Dependencies

> **Last Updated**: October 1, 2025  
> **Flutter SDK**: ^3.9.0

---

## 📋 Production Dependencies

### Core Framework
- **flutter** - Flutter SDK
- **cupertino_icons** (^1.0.8) - iOS style icons

### Backend & Database
- **supabase_flutter** (^2.5.6) - Supabase client for Flutter
  - Authentication
  - Real-time subscriptions
  - Database operations
  - Storage

### State Management
- **provider** (^6.1.2) - State management solution
  - Simple and scalable
  - Recommended by Flutter team

### Chat UI
- **flutter_chat_ui** (^1.6.15) - Pre-built chat UI components
- **flutter_chat_types** (^3.6.2) - Chat message data models

### Security
- **flutter_secure_storage** (^9.2.2) - Secure token storage
  - Encrypted storage for sensitive data
  - Platform-specific secure storage

### File Handling
- **image_picker** (^1.1.2) - Pick images from camera/gallery
- **file_picker** (^8.0.6) - Pick documents and files
- **open_filex** (^4.5.0) - Open files with default apps

### Push Notifications
- **onesignal_flutter** (^5.2.3) - OneSignal SDK
  - Push notifications
  - In-app messaging
  - User segmentation

### UI/UX
- **emoji_picker_flutter** (^3.0.0) - Emoji picker widget

### Utilities
- **intl** (^0.19.0) - Internationalization and date formatting
- **uuid** (^4.4.2) - Generate unique IDs
- **http** (^1.2.2) - HTTP client for REST API calls
- **flutter_dotenv** (^5.1.0) - Environment variable management

---

## 🧪 Development Dependencies

- **flutter_test** - Flutter testing framework
- **flutter_lints** (^5.0.0) - Recommended lints for Flutter

---

## 📊 Package Statistics

| Category | Count |
|----------|-------|
| Total Dependencies | 17 |
| Backend/Database | 1 |
| State Management | 1 |
| UI/Chat | 3 |
| Security | 1 |
| File Handling | 3 |
| Notifications | 1 |
| Utilities | 4 |
| Dev Dependencies | 2 |

---

## 🔄 Update Strategy

### Check for Updates
```bash
flutter pub outdated
```

### Update All Packages
```bash
flutter pub upgrade
```

### Update to Latest Major Versions
```bash
flutter pub upgrade --major-versions
```

---

## ⚠️ Known Issues

### 1. Package Compatibility
- All packages are compatible with Flutter SDK ^3.9.0
- Some packages have newer versions available but may have breaking changes

### 2. Platform-Specific Notes

#### Android
- `flutter_secure_storage` requires minSdkVersion 21+
- `onesignal_flutter` requires minSdkVersion 21+
- `image_picker` requires permissions in AndroidManifest.xml

#### iOS
- `flutter_secure_storage` requires iOS 12.0+
- `onesignal_flutter` requires iOS 12.0+
- `image_picker` requires permissions in Info.plist

#### Web
- `flutter_secure_storage` uses browser local storage
- `file_picker` has limited functionality on web

---

## 📝 Installation Notes

### First Time Setup
1. Ensure Flutter SDK is installed
2. Run `flutter pub get`
3. Create `.env` file from `.env.example`
4. Configure platform-specific settings

### After Pulling Changes
```bash
flutter pub get
```

### Clean Install
```bash
flutter clean
flutter pub get
```

---

## 🔗 Package Links

### Backend & Database
- [supabase_flutter](https://pub.dev/packages/supabase_flutter)

### State Management
- [provider](https://pub.dev/packages/provider)

### Chat UI
- [flutter_chat_ui](https://pub.dev/packages/flutter_chat_ui)
- [flutter_chat_types](https://pub.dev/packages/flutter_chat_types)

### Security
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

### File Handling
- [image_picker](https://pub.dev/packages/image_picker)
- [file_picker](https://pub.dev/packages/file_picker)
- [open_filex](https://pub.dev/packages/open_filex)

### Push Notifications
- [onesignal_flutter](https://pub.dev/packages/onesignal_flutter)

### UI/UX
- [emoji_picker_flutter](https://pub.dev/packages/emoji_picker_flutter)

### Utilities
- [intl](https://pub.dev/packages/intl)
- [uuid](https://pub.dev/packages/uuid)
- [http](https://pub.dev/packages/http)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

---

## 🎯 Future Considerations

### Potential Additions
- **go_router** - Advanced routing
- **cached_network_image** - Image caching
- **connectivity_plus** - Network connectivity
- **shared_preferences** - Simple key-value storage
- **flutter_local_notifications** - Local notifications

### Performance Optimization
- Consider lazy loading for large packages
- Implement code splitting for web
- Use tree shaking for unused code

---

**Document Version**: 1.0  
**Last Updated**: October 1, 2025
