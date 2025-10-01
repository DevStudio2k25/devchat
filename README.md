# 💬 DevChat - Real-time Developer Chat Application

<div align="center">

**A feature-rich, cross-platform chat application built with Flutter and Supabase**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[Features](#-features) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started) • [Documentation](#-documentation) • [Roadmap](#-roadmap)

</div>

---

## 📋 Overview

**DevChat** is a modern, real-time chat application designed specifically for developers. Built with Flutter for cross-platform compatibility and powered by Supabase for backend services, it offers a seamless communication experience across Android, iOS, Web, and Desktop platforms.

### 🎯 Key Highlights

- 🔐 **Secure Authentication** - Email/Password & Social Login via Supabase Auth
- 💬 **Real-time Messaging** - Instant 1-to-1 and group chats with Supabase Realtime
- 🧵 **Threaded Conversations** - Reply to specific messages for organized discussions
- 📎 **File Sharing** - Share code snippets, images, and documents
- 🟢 **Presence System** - See who's online in real-time
- 🔔 **Push Notifications** - Never miss a message with OneSignal integration
- 🔍 **Smart Search** - Find chats, messages, and users instantly
- ⭐ **Message Reactions** - Express yourself with emoji reactions
- 🛡️ **Enterprise Security** - Row-level security policies with Supabase
- ⚡ **Cross-platform** - One codebase for Android, iOS, Web, and Desktop

---

## 🚀 Features

### Core Features

| Feature | Description | Status |
|---------|-------------|--------|
| 🔐 **Authentication** | Email/Password + Social Login (Google, GitHub) | 📋 Planned |
| 👤 **User Profiles** | Customizable profiles with avatar, bio, and status | 📋 Planned |
| 💬 **Real-time Chat** | 1-to-1 and Group Chats with instant delivery | 📋 Planned |
| 🧵 **Threaded Messages** | Reply to specific messages in threads | 📋 Planned |
| 📎 **File Sharing** | Upload & share code snippets, images, documents | 📋 Planned |
| 🟢 **Presence Indicator** | Online/Offline/Away status tracking | 📋 Planned |
| 🔔 **Push Notifications** | Real-time message alerts via OneSignal | 📋 Planned |
| 🔍 **Search** | Search across chats, messages, and users | 📋 Planned |
| ⭐ **Message Reactions** | Emoji-based reactions to messages | 📋 Planned |
| 🛡️ **Secure Data** | Row-level security policies in Supabase | 📋 Planned |

### Advanced Features (Future)

- 📹 **Video/Voice Calls** - WebRTC integration
- 🎨 **Themes** - Light/Dark mode with custom themes
- 🌐 **Internationalization** - Multi-language support
- 📊 **Analytics** - User engagement and chat analytics
- 🤖 **Bot Integration** - Custom chatbots and automation
- 📝 **Rich Text Editor** - Markdown support for messages
- 🔗 **Deep Linking** - Direct links to specific chats/messages

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Provider / Riverpod
- **UI Components**: flutter_chat_ui, Material Design 3
- **Local Storage**: flutter_secure_storage

### Backend
- **BaaS**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Real-time**: Supabase Realtime (WebSockets)
- **Storage**: Supabase Storage
- **Database**: PostgreSQL with Row-Level Security

### Services
- **Push Notifications**: OneSignal (with native FCM/APNs)
- **File Storage**: Supabase Storage (S3-compatible)
- **Analytics**: (To be determined)

### Key Packages

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter: ^2.0.0
  
  # State Management
  provider: ^6.1.0
  # OR riverpod: ^2.4.0
  
  # Chat UI
  flutter_chat_ui: ^1.6.0
  flutter_chat_types: ^3.6.0
  
  # Authentication & Security
  flutter_secure_storage: ^9.0.0
  
  # File Handling
  image_picker: ^1.0.0
  file_picker: ^6.0.0
  open_filex: ^4.3.0
  
  # Notifications
  onesignal_flutter: ^5.1.2
  
  # UI/UX
  emoji_picker_flutter: ^2.0.0
  
  # Utilities
  intl: ^0.18.0
  uuid: ^4.0.0
```

---

## 📚 Documentation

Comprehensive documentation is available in the `/docs` folder:

### 📖 Planning & Architecture
- **[PLAN.md](PLAN.md)** - Quick reference plan and project overview
- **[TASKS.md](TASKS.md)** - Detailed task breakdown and progress tracking
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System architecture and design patterns
- **[docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md)** - Database structure and relationships

### 🔧 Setup & Configuration
- **[docs/SETUP.md](docs/SETUP.md)** - Complete setup guide for development
- **[docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md)** - Supabase configuration guide
- **[docs/ONESIGNAL_SETUP.md](docs/ONESIGNAL_SETUP.md)** - Push notification setup

### 💻 Development
- **[docs/FEATURES.md](docs/FEATURES.md)** - Detailed feature specifications
- **[docs/API_REFERENCE.md](docs/API_REFERENCE.md)** - API endpoints and usage
- **[docs/STATE_MANAGEMENT.md](docs/STATE_MANAGEMENT.md)** - State management patterns

### 🧪 Testing & Deployment
- **[docs/TESTING.md](docs/TESTING.md)** - Testing strategy and guidelines
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Deployment instructions

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- Supabase Account
- OneSignal Account (for push notifications)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/devchat.git
   cd devchat
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase and OneSignal credentials
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

For detailed setup instructions, see **[docs/SETUP.md](docs/SETUP.md)**

---

## 📱 Supported Platforms

| Platform | Status | Minimum Version |
|----------|--------|-----------------|
| 🤖 Android | ✅ Supported | Android 5.0 (API 21+) |
| 🍎 iOS | ✅ Supported | iOS 12.0+ |
| 🌐 Web | ✅ Supported | Modern browsers |
| 🖥️ Desktop (Windows) | ✅ Supported | Windows 10+ |
| 🖥️ Desktop (macOS) | ✅ Supported | macOS 10.14+ |
| 🖥️ Desktop (Linux) | ✅ Supported | Ubuntu 20.04+ |

---

## 🗺️ Roadmap

### Phase 1: Foundation (Current)
- [x] Project setup and structure
- [ ] Supabase integration
- [ ] Authentication system
- [ ] Basic chat UI
- [ ] Real-time messaging

### Phase 2: Core Features
- [ ] User profiles
- [ ] Group chats
- [ ] File sharing
- [ ] Push notifications
- [ ] Message reactions

### Phase 3: Advanced Features
- [ ] Threaded messages
- [ ] Search functionality
- [ ] Presence system
- [ ] Message editing/deletion
- [ ] Read receipts

### Phase 4: Enhancement
- [ ] Video/Voice calls
- [ ] Rich text editor
- [ ] Custom themes
- [ ] Internationalization
- [ ] Performance optimization

### Phase 5: Production
- [ ] Security audit
- [ ] Performance testing
- [ ] App store deployment
- [ ] Documentation completion
- [ ] Marketing materials

See **[TASKS.md](TASKS.md)** for detailed task breakdown.

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting PRs.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Supabase](https://supabase.com) - Backend infrastructure
- [OneSignal](https://onesignal.com) - Push notifications
- [flutter_chat_ui](https://pub.dev/packages/flutter_chat_ui) - Chat UI components

---

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/devchat/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/devchat/discussions)
- **Email**: your.email@example.com

---

<div align="center">

**Made with ❤️ using Flutter and Supabase**

⭐ Star this repo if you find it helpful!

</div>
