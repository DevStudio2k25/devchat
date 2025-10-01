# 🚀 DevChat - Development Setup Guide

> **Version**: 1.0  
> **Last Updated**: October 1, 2025  
> **Estimated Setup Time**: 2-3 hours

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Project Setup](#project-setup)
4. [Supabase Configuration](#supabase-configuration)
5. [OneSignal Configuration](#onesignal-configuration)
6. [Running the Application](#running-the-application)
7. [Troubleshooting](#troubleshooting)

---

## ✅ Prerequisites

### Required Software

| Software | Minimum Version | Download Link |
|----------|----------------|---------------|
| Flutter SDK | 3.0.0 | https://flutter.dev/docs/get-started/install |
| Dart SDK | 3.0.0 | (Included with Flutter) |
| Git | 2.30+ | https://git-scm.com/downloads |
| VS Code or Android Studio | Latest | https://code.visualstudio.com/ |

### Platform-Specific Requirements

#### For Android Development
- Android Studio (latest)
- Android SDK (API 21+)
- Java JDK 11+
- Android Emulator or physical device

#### For iOS Development (macOS only)
- Xcode 14+
- CocoaPods
- iOS Simulator or physical device
- Apple Developer Account (for device testing)

#### For Web Development
- Chrome browser (latest)

#### For Desktop Development
- Windows: Visual Studio 2022 with C++ tools
- macOS: Xcode Command Line Tools
- Linux: clang, cmake, ninja-build, libgtk-3-dev

### Required Accounts

1. **Supabase Account** - https://supabase.com
2. **OneSignal Account** - https://onesignal.com
3. **GitHub Account** - https://github.com (for version control)
4. **Google Cloud Account** - https://console.cloud.google.com (for OAuth - optional)

---

## 🔧 Environment Setup

### 1. Install Flutter

#### Windows
```powershell
# Download Flutter SDK
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

#### macOS/Linux
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (add to ~/.zshrc or ~/.bashrc)
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Configure Flutter

```bash
# Accept Android licenses
flutter doctor --android-licenses

# Enable platforms
flutter config --enable-web
flutter config --enable-windows-desktop  # Windows only
flutter config --enable-macos-desktop    # macOS only
flutter config --enable-linux-desktop    # Linux only

# Check configuration
flutter doctor -v
```

### 3. Install IDE Extensions

#### VS Code Extensions
- Flutter
- Dart
- Flutter Widget Snippets
- Error Lens
- GitLens
- Prettier

#### Android Studio Plugins
- Flutter
- Dart

---

## 📦 Project Setup

### 1. Clone Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/devchat.git
cd devchat

# Or if starting fresh
flutter create devchat
cd devchat
```

### 2. Install Dependencies

```bash
# Get all packages
flutter pub get

# Verify no issues
flutter pub outdated
```

### 3. Project Structure

Create the following folder structure:

```
lib/
├── main.dart
├── config/
│   ├── app_config.dart
│   ├── supabase_config.dart
│   └── onesignal_config.dart
├── models/
│   ├── user.dart
│   ├── chat.dart
│   ├── message.dart
│   └── ...
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── chat/
│   │   ├── chat_list_screen.dart
│   │   └── chat_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/
│   ├── chat_list_item.dart
│   ├── message_bubble.dart
│   └── ...
├── services/
│   ├── auth_service.dart
│   ├── chat_service.dart
│   ├── message_service.dart
│   └── ...
├── providers/
│   ├── auth_provider.dart
│   ├── chat_provider.dart
│   └── ...
├── utils/
│   ├── constants.dart
│   ├── helpers.dart
│   └── validators.dart
└── routes/
    └── app_router.dart
```

### 4. Environment Configuration

Create `.env` file in project root:

```bash
# Copy example file
cp .env.example .env
```

Edit `.env` with your credentials:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# OneSignal Configuration
ONESIGNAL_APP_ID=your-onesignal-app-id

# Optional: OneSignal REST API Key (for backend)
ONESIGNAL_REST_API_KEY=your-rest-api-key

# Environment
ENVIRONMENT=development
```

Create `.env.example` for version control:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# OneSignal Configuration
ONESIGNAL_APP_ID=your-onesignal-app-id
ONESIGNAL_REST_API_KEY=your-rest-api-key

# Environment
ENVIRONMENT=development
```

### 5. Update .gitignore

Add to `.gitignore`:

```gitignore
# Environment files
.env
.env.local
.env.production

# IDE
.vscode/
.idea/
*.iml

# Build
build/
.dart_tool/

# Android
android/key.properties
*.jks

# iOS
ios/Pods/
ios/.symlinks/
```

---

## 🗄️ Supabase Configuration

### 1. Create Supabase Project

1. Go to https://supabase.com
2. Click "New Project"
3. Fill in project details:
   - Name: `devchat`
   - Database Password: (strong password)
   - Region: (closest to you)
4. Wait for project to initialize (~2 minutes)

### 2. Get Project Credentials

1. Go to Project Settings > API
2. Copy:
   - Project URL → `SUPABASE_URL`
   - `anon` `public` key → `SUPABASE_ANON_KEY`
3. Update `.env` file

### 3. Setup Database Schema

#### Option A: Using Supabase Dashboard

1. Go to SQL Editor
2. Copy contents from `docs/DATABASE_SCHEMA.md`
3. Run migration scripts

#### Option B: Using Supabase CLI

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push
```

### 4. Configure Authentication

1. Go to Authentication > Providers
2. Enable Email provider
3. Configure OAuth providers (optional):
   - **Google**: 
     - Enable Google provider
     - Add Client ID and Secret from Google Cloud Console
   - **GitHub**:
     - Enable GitHub provider
     - Add Client ID and Secret from GitHub OAuth Apps

### 5. Configure Storage

1. Go to Storage
2. Create buckets:
   - `avatars` (public)
   - `chat-files` (private)
   - `chat-images` (private)

3. Set bucket policies:

```sql
-- avatars bucket (public read)
CREATE POLICY "Public avatars" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload own avatar" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- chat-files bucket (private)
CREATE POLICY "Users can view files in their chats" ON storage.objects
FOR SELECT USING (
  bucket_id = 'chat-files' AND
  EXISTS (
    SELECT 1 FROM chat_members cm
    JOIN files f ON f.storage_path = name
    WHERE cm.chat_id = f.chat_id
    AND cm.user_id = auth.uid()
  )
);
```

### 6. Enable Realtime

1. Go to Database > Replication
2. Enable replication for tables:
   - `messages`
   - `chats`
   - `presence`
   - `reactions`

---

## 🔔 OneSignal Configuration

### 1. Create OneSignal App

1. Go to https://onesignal.com
2. Click "New App/Website"
3. Enter app name: `DevChat`
4. Select platforms: Android, iOS

### 2. Configure Android

1. Select "Google Android (FCM)"
2. OneSignal will automatically configure FCM for you
3. No Firebase setup needed - OneSignal handles this natively!
4. Click "Save"

### 3. Configure iOS

1. Select "Apple iOS (APNs)"
2. Upload APNs certificate:
   - **Option A: .p8 Key (Recommended)**
     - Go to Apple Developer > Certificates, IDs & Profiles
     - Create APNs Auth Key
     - Download .p8 file
     - Upload to OneSignal with Key ID and Team ID
   - **Option B: .p12 Certificate**
     - Generate certificate in Xcode
     - Export as .p12
     - Upload to OneSignal

### 4. Get OneSignal Credentials

1. Go to Settings > Keys & IDs
2. Copy:
   - OneSignal App ID → `ONESIGNAL_APP_ID`
   - REST API Key → `ONESIGNAL_REST_API_KEY`
3. Update `.env` file

### 5. Configure OneSignal in Flutter

Add to `pubspec.yaml`:

```yaml
dependencies:
  onesignal_flutter: ^5.1.2
```

Initialize in `main.dart`:

```dart
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  OneSignal.Notifications.requestPermission(true);
  
  runApp(MyApp());
}
```

---

## ▶️ Running the Application

### Run on Android

```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release

# Run with specific device
flutter run -d <device-id>
```

### Run on iOS

```bash
# Open iOS project in Xcode (first time)
cd ios
open Runner.xcworkspace

# Install pods
pod install

# Return to project root
cd ..

# Run on simulator
flutter run

# Run on physical device
flutter run -d <device-id>
```

### Run on Web

```bash
# Run in Chrome
flutter run -d chrome

# Run with specific port
flutter run -d web-server --web-port=8080

# Build for production
flutter build web
```

### Run on Desktop

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

---

## 🧪 Testing Setup

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Integration Tests

```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d <device-id>
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues

```bash
# Android licenses not accepted
flutter doctor --android-licenses

# Xcode not configured
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# CocoaPods not installed
sudo gem install cocoapods
```

#### 2. Build Errors

```bash
# Clean build
flutter clean
flutter pub get

# Reset pods (iOS)
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Rebuild
flutter run
```

#### 3. Supabase Connection Issues

- Verify `.env` file exists and has correct values
- Check Supabase project is active
- Verify API keys are correct
- Check network connection
- Review Supabase logs in dashboard

#### 4. OneSignal Not Working

- Verify App ID is correct
- Check platform configuration (FCM for Android, APNs for iOS)
- Ensure permissions are granted
- Check OneSignal dashboard for delivery status
- Review device logs

#### 5. Hot Reload Not Working

```bash
# Restart with hot reload
r

# Full restart
R

# Quit and restart
q
flutter run
```

---

## 📚 Additional Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Supabase Documentation](https://supabase.com/docs)
- [OneSignal Documentation](https://documentation.onesignal.com)

### Tutorials
- [Flutter Codelabs](https://flutter.dev/docs/codelabs)
- [Supabase Tutorials](https://supabase.com/docs/guides/getting-started)
- [OneSignal Flutter Setup](https://documentation.onesignal.com/docs/flutter-sdk-setup)

### Community
- [Flutter Discord](https://discord.gg/flutter)
- [Supabase Discord](https://discord.supabase.com)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

## ✅ Setup Checklist

- [ ] Flutter SDK installed and configured
- [ ] IDE setup with extensions
- [ ] Project cloned/created
- [ ] Dependencies installed
- [ ] `.env` file created and configured
- [ ] Supabase project created
- [ ] Database schema deployed
- [ ] Supabase authentication configured
- [ ] Supabase storage configured
- [ ] OneSignal app created
- [ ] OneSignal Android configured
- [ ] OneSignal iOS configured
- [ ] App runs successfully on at least one platform
- [ ] Tests pass
- [ ] Git repository initialized

---

## 🎉 Next Steps

Once setup is complete:

1. Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
2. Check [TASKS.md](TASKS.md) for development tasks
3. Read [FEATURES.md](FEATURES.md) for feature specifications
4. Start with Phase 1 tasks (Authentication)

---

**Document Version**: 1.0  
**Last Updated**: October 1, 2025  
**Need Help?** Create an issue on GitHub or contact the team
