# 📁 DevChat - Project Structure

> **Last Updated**: October 1, 2025  
> **Organization**: Feature-based + Layer-based hybrid

---

## 📂 Directory Structure

```
devchat/
├── android/                    # Android platform code
├── ios/                        # iOS platform code
├── web/                        # Web platform code
├── windows/                    # Windows platform code
├── linux/                      # Linux platform code
├── macos/                      # macOS platform code
├── assets/                     # Static assets
│   ├── images/                 # Image assets
│   └── icons/                  # Icon assets
├── lib/                        # Main Flutter code
│   ├── main.dart              # App entry point
│   ├── config/                # Configuration
│   │   └── env_config.dart    # Environment variables
│   ├── models/                # Data models
│   │   ├── user.dart
│   │   ├── chat.dart
│   │   ├── message.dart
│   │   └── ...
│   ├── screens/               # UI Screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── chat/
│   │   │   ├── chat_list_screen.dart
│   │   │   └── chat_screen.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   └── ...
│   ├── widgets/               # Reusable widgets
│   │   ├── chat_list_item.dart
│   │   ├── message_bubble.dart
│   │   ├── user_avatar.dart
│   │   └── ...
│   ├── services/              # Business logic & API
│   │   ├── auth_service.dart
│   │   ├── chat_service.dart
│   │   ├── message_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   ├── providers/             # State management
│   │   ├── auth_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── message_provider.dart
│   │   └── ...
│   ├── utils/                 # Utility functions
│   │   ├── constants.dart
│   │   ├── helpers.dart
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── constants/             # App constants
│       ├── app_colors.dart
│       ├── app_strings.dart
│       └── app_routes.dart
├── supabase/                  # Supabase configuration
│   ├── migrations/            # Database migrations
│   │   └── 001_initial_schema.sql
│   └── README.md
├── docs/                      # Documentation
│   ├── ARCHITECTURE.md
│   ├── DATABASE_SCHEMA.md
│   ├── SETUP.md
│   ├── SUPABASE_SETUP.md
│   ├── ONESIGNAL_SETUP.md
│   ├── FEATURES.md
│   ├── API_REFERENCE.md
│   ├── STATE_MANAGEMENT.md
│   ├── TESTING.md
│   ├── DEPLOYMENT.md
│   ├── TASKS.md
│   └── README.md
├── test/                      # Tests
│   ├── unit/
│   ├── widget/
│   └── integration/
├── .env.example               # Environment template
├── .gitignore                 # Git ignore rules
├── pubspec.yaml               # Dependencies
├── README.md                  # Project overview
├── PLAN.md                    # Quick reference plan
├── TASKS.md                   # Task tracking
├── DEPENDENCIES.md            # Package documentation
├── ENV_SETUP.md               # Environment setup guide
└── PROJECT_STRUCTURE.md       # This file
```

---

## 📋 Folder Descriptions

### `/lib` - Main Application Code

#### `/lib/config`
**Purpose**: Application configuration and environment setup
- Environment variables
- App configuration
- Feature flags

**Files**:
- `env_config.dart` - Environment variable management

#### `/lib/models`
**Purpose**: Data models and entities
- User models
- Chat models
- Message models
- DTOs (Data Transfer Objects)

**Naming Convention**: `snake_case.dart`

**Example**:
```dart
// lib/models/user.dart
class User {
  final String id;
  final String username;
  final String email;
  // ...
}
```

#### `/lib/screens`
**Purpose**: Full-page UI screens
- Organized by feature
- Each screen is a StatefulWidget or StatelessWidget

**Structure**:
```
screens/
├── auth/           # Authentication screens
├── chat/           # Chat screens
├── profile/        # Profile screens
└── settings/       # Settings screens
```

**Naming Convention**: `feature_screen.dart`

#### `/lib/widgets`
**Purpose**: Reusable UI components
- Custom widgets
- Shared components
- UI building blocks

**Naming Convention**: `descriptive_widget.dart`

**Example**:
```dart
// lib/widgets/message_bubble.dart
class MessageBubble extends StatelessWidget {
  // ...
}
```

#### `/lib/services`
**Purpose**: Business logic and API communication
- API calls
- Data processing
- External service integration

**Naming Convention**: `feature_service.dart`

**Example**:
```dart
// lib/services/auth_service.dart
class AuthService {
  Future<User> signIn(String email, String password) async {
    // ...
  }
}
```

#### `/lib/providers`
**Purpose**: State management (Provider/Riverpod)
- Application state
- UI state
- Data caching

**Naming Convention**: `feature_provider.dart`

**Example**:
```dart
// lib/providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  // ...
}
```

#### `/lib/utils`
**Purpose**: Utility functions and helpers
- Helper functions
- Validators
- Formatters
- Extensions

**Files**:
- `constants.dart` - App-wide constants
- `helpers.dart` - Helper functions
- `validators.dart` - Input validation
- `formatters.dart` - Data formatting

#### `/lib/constants`
**Purpose**: Application constants
- Colors
- Strings
- Routes
- API endpoints

**Files**:
- `app_colors.dart` - Color palette
- `app_strings.dart` - Static strings
- `app_routes.dart` - Route names

---

## 🎨 Naming Conventions

### Files
- **Dart files**: `snake_case.dart`
- **Screens**: `feature_screen.dart`
- **Widgets**: `descriptive_widget.dart`
- **Services**: `feature_service.dart`
- **Providers**: `feature_provider.dart`
- **Models**: `model_name.dart`

### Classes
- **PascalCase**: `UserProfile`, `ChatScreen`
- **Descriptive names**: `MessageBubble`, `ChatListItem`

### Variables
- **camelCase**: `userName`, `chatId`
- **Private**: `_privateVariable`

### Constants
- **SCREAMING_SNAKE_CASE**: `API_BASE_URL`, `MAX_FILE_SIZE`
- **Colors**: `primaryColor`, `accentColor`

---

## 🔄 Data Flow

```
User Action
    ↓
Screen (UI)
    ↓
Provider (State)
    ↓
Service (Business Logic)
    ↓
Supabase (Backend)
    ↓
Service (Process Response)
    ↓
Provider (Update State)
    ↓
Screen (Re-render)
```

---

## 📦 Import Organization

Order imports in this sequence:

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. External packages
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 4. Internal imports
import 'package:devchat/models/user.dart';
import 'package:devchat/services/auth_service.dart';
import 'package:devchat/providers/auth_provider.dart';
```

---

## 🧪 Testing Structure

```
test/
├── unit/                      # Unit tests
│   ├── models/
│   ├── services/
│   └── utils/
├── widget/                    # Widget tests
│   ├── screens/
│   └── widgets/
└── integration/               # Integration tests
    └── flows/
```

---

## 📝 Best Practices

### File Organization
1. ✅ One class per file
2. ✅ Group related files in folders
3. ✅ Use meaningful file names
4. ✅ Keep files under 300 lines

### Code Organization
1. ✅ Separate UI from business logic
2. ✅ Use services for API calls
3. ✅ Use providers for state management
4. ✅ Keep widgets small and focused

### Imports
1. ✅ Use relative imports for project files
2. ✅ Group imports by type
3. ✅ Remove unused imports

### Comments
1. ✅ Document public APIs
2. ✅ Explain complex logic
3. ✅ Use TODO for pending work
4. ✅ Keep comments up-to-date

---

## 🔗 Related Documentation

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - System architecture
- [SETUP.md](docs/SETUP.md) - Development setup
- [TASKS.md](TASKS.md) - Task tracking

---

**Document Version**: 1.0  
**Last Updated**: October 1, 2025
