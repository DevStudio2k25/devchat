# 🏗️ DevChat - System Architecture

> **Version**: 1.0  
> **Last Updated**: October 1, 2025  
> **Status**: Planning Phase

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture Patterns](#architecture-patterns)
3. [System Components](#system-components)
4. [Data Flow](#data-flow)
5. [Technology Stack](#technology-stack)
6. [Security Architecture](#security-architecture)
7. [Scalability Considerations](#scalability-considerations)

---

## 🎯 Overview

DevChat follows a **client-server architecture** with a **Backend-as-a-Service (BaaS)** approach using Supabase. The application is built using **Clean Architecture** principles with clear separation of concerns.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Layer (Flutter)                   │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer                                          │
│  ├── Screens (UI)                                           │
│  ├── Widgets (Reusable Components)                          │
│  └── State Management (Provider/Riverpod)                   │
├─────────────────────────────────────────────────────────────┤
│  Domain Layer                                                │
│  ├── Models (Data Entities)                                 │
│  ├── Repositories (Abstract Interfaces)                     │
│  └── Use Cases (Business Logic)                             │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                  │
│  ├── Services (API Communication)                           │
│  ├── Data Sources (Remote/Local)                            │
│  └── Repository Implementations                             │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                   Backend Layer (Supabase)                   │
├─────────────────────────────────────────────────────────────┤
│  Authentication (Supabase Auth)                              │
│  Database (PostgreSQL)                                       │
│  Real-time (WebSockets)                                      │
│  Storage (S3-compatible)                                     │
│  Edge Functions (Serverless)                                 │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                   External Services                          │
├─────────────────────────────────────────────────────────────┤
│  OneSignal (Push Notifications)                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🏛️ Architecture Patterns

### 1. Clean Architecture

**Layers**:
- **Presentation**: UI components, state management
- **Domain**: Business logic, entities, use cases
- **Data**: API calls, database operations, external services

**Benefits**:
- Separation of concerns
- Testability
- Maintainability
- Platform independence

### 2. Repository Pattern

Abstracts data sources from business logic.

```dart
// Abstract Repository
abstract class ChatRepository {
  Future<List<Chat>> getUserChats(String userId);
  Future<Chat> createChat(Chat chat);
  Stream<List<Message>> getMessages(String chatId);
}

// Implementation
class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabase;
  
  @override
  Future<List<Chat>> getUserChats(String userId) async {
    // Implementation
  }
}
```

### 3. Provider/Riverpod Pattern

State management using Provider or Riverpod.

```dart
// Chat Provider
class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;
  List<Chat> _chats = [];
  
  List<Chat> get chats => _chats;
  
  Future<void> loadChats() async {
    _chats = await _repository.getUserChats(userId);
    notifyListeners();
  }
}
```

### 4. Service Pattern

Encapsulates external service interactions.

```dart
// OneSignal Service
class NotificationService {
  Future<void> sendNotification(String userId, String message) async {
    // OneSignal API call
  }
}
```

---

## 🧩 System Components

### Frontend Components

#### 1. Presentation Layer

**Screens**:
- `LoginScreen` - User authentication
- `SignupScreen` - User registration
- `ChatListScreen` - List of all chats
- `ChatScreen` - Individual chat view
- `ProfileScreen` - User profile
- `SettingsScreen` - App settings
- `SearchScreen` - Search functionality

**Widgets**:
- `ChatListItem` - Chat preview in list
- `MessageBubble` - Individual message
- `UserAvatar` - User profile picture
- `TypingIndicator` - Shows typing status
- `OnlineIndicator` - Shows online status

**State Management**:
- `AuthProvider` - Authentication state
- `ChatProvider` - Chat list state
- `MessageProvider` - Message state
- `UserProvider` - User profile state
- `ThemeProvider` - Theme state

#### 2. Domain Layer

**Models**:
```dart
class User {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;
}

class Chat {
  final String id;
  final String name;
  final bool isGroup;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;
}
```

**Use Cases**:
- `SendMessageUseCase`
- `CreateChatUseCase`
- `UpdateProfileUseCase`
- `SearchUsersUseCase`

#### 3. Data Layer

**Services**:
- `AuthService` - Authentication operations
- `ChatService` - Chat operations
- `MessageService` - Message operations
- `StorageService` - File uploads
- `NotificationService` - Push notifications
- `PresenceService` - Online status

**Data Sources**:
- `RemoteDataSource` - Supabase API
- `LocalDataSource` - Local storage/cache

### Backend Components (Supabase)

#### 1. Database (PostgreSQL)

**Tables**:
- `users` - User profiles
- `chats` - Chat rooms
- `messages` - All messages
- `chat_members` - Chat participants
- `reactions` - Message reactions
- `files` - File metadata
- `presence` - User online status
- `notifications` - Notification history

**Views**:
- `chat_list_view` - Optimized chat list
- `message_view` - Messages with user info

**Functions**:
- `create_chat()` - Create new chat
- `add_chat_member()` - Add user to chat
- `mark_messages_read()` - Update read status

#### 2. Real-time (Supabase Realtime)

**Channels**:
- `messages:{chatId}` - Message updates
- `presence:{chatId}` - User presence
- `chats:{userId}` - Chat list updates

#### 3. Storage (Supabase Storage)

**Buckets**:
- `avatars` - User profile pictures
- `chat-files` - Shared files
- `chat-images` - Shared images

#### 4. Authentication (Supabase Auth)

**Providers**:
- Email/Password
- Google OAuth
- GitHub OAuth

**Policies**:
- JWT-based authentication
- Row-level security
- Token refresh

---

## 🔄 Data Flow

### 1. Authentication Flow

```
User → LoginScreen → AuthService → Supabase Auth
                         ↓
                   Store Token (Secure Storage)
                         ↓
                   Update AuthProvider
                         ↓
                   Navigate to ChatListScreen
```

### 2. Send Message Flow

```
User → ChatScreen → MessageProvider → MessageService
                                           ↓
                                    Supabase Database
                                           ↓
                                    Real-time Broadcast
                                           ↓
                              Other Users (via Subscription)
                                           ↓
                                    Update UI
```

### 3. Real-time Message Flow

```
Supabase Real-time → MessageService → MessageProvider
                                           ↓
                                    Update Message List
                                           ↓
                                    Trigger Notification
                                           ↓
                                    Update UI
```

### 4. File Upload Flow

```
User → Select File → StorageService → Supabase Storage
                                           ↓
                                    Get File URL
                                           ↓
                                    Create Message with URL
                                           ↓
                                    MessageService
                                           ↓
                                    Save to Database
```

### 5. Push Notification Flow

```
New Message → Database Trigger → Edge Function
                                      ↓
                              OneSignal API
                                      ↓
                              Push Notification
                                      ↓
                              User Device
                                      ↓
                              App Opens Chat
```

---

## 🛠️ Technology Stack

### Frontend

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | Flutter 3.x | Cross-platform UI |
| Language | Dart 3.x | Programming language |
| State Management | Provider/Riverpod | State management |
| Chat UI | flutter_chat_ui | Pre-built chat components |
| Storage | flutter_secure_storage | Secure token storage |
| HTTP Client | http / dio | API requests |
| WebSocket | web_socket_channel | Real-time connections |

### Backend

| Component | Technology | Purpose |
|-----------|-----------|---------|
| BaaS | Supabase | Backend infrastructure |
| Database | PostgreSQL | Data storage |
| Real-time | Supabase Realtime | WebSocket connections |
| Auth | Supabase Auth | User authentication |
| Storage | Supabase Storage | File storage |
| Functions | Edge Functions | Serverless functions |

### External Services

| Service | Purpose |
|---------|---------|
| OneSignal | Push notifications |

---

## 🔒 Security Architecture

### 1. Authentication Security

- **JWT Tokens**: Secure token-based authentication
- **Secure Storage**: Tokens stored in encrypted storage
- **Token Refresh**: Automatic token renewal
- **Session Management**: Proper session handling

### 2. Database Security

**Row-Level Security (RLS)**:

```sql
-- Users can only read their own profile
CREATE POLICY "Users can view own profile"
ON users FOR SELECT
USING (auth.uid() = id);

-- Users can only see messages in their chats
CREATE POLICY "Users can view messages in their chats"
ON messages FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = messages.chat_id
    AND user_id = auth.uid()
  )
);
```

### 3. API Security

- **API Key Protection**: Environment variables
- **Rate Limiting**: Prevent abuse
- **Input Validation**: Sanitize all inputs
- **CORS Configuration**: Restrict origins

### 4. Storage Security

- **Bucket Policies**: Restrict file access
- **File Validation**: Check file types and sizes
- **Signed URLs**: Temporary access URLs
- **Virus Scanning**: (Future consideration)

### 5. Client-Side Security

- **No Sensitive Data**: Never store secrets in code
- **HTTPS Only**: Encrypted connections
- **Certificate Pinning**: (Future consideration)
- **Code Obfuscation**: Protect source code

---

## 📈 Scalability Considerations

### 1. Database Scalability

**Optimization Strategies**:
- Indexing on frequently queried columns
- Pagination for large datasets
- Database connection pooling
- Query optimization

**Indexes**:
```sql
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_chat_members_user_id ON chat_members(user_id);
```

### 2. Real-time Scalability

**Strategies**:
- Selective channel subscriptions
- Unsubscribe when not needed
- Batch updates
- Throttle/debounce updates

### 3. Storage Scalability

**Strategies**:
- Image compression
- Lazy loading
- CDN for static assets
- File size limits

### 4. Client-Side Performance

**Optimization**:
- Lazy loading lists
- Image caching
- Message pagination
- Virtual scrolling
- Memory management

### 5. Caching Strategy

**Multi-Level Caching**:

```dart
class CacheStrategy {
  // Level 1: In-memory cache
  Map<String, dynamic> _memoryCache = {};
  
  // Level 2: Local storage
  final LocalStorage _localStorage;
  
  // Level 3: Remote (Supabase)
  final SupabaseClient _supabase;
  
  Future<T> get<T>(String key) async {
    // Check memory first
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }
    
    // Check local storage
    final local = await _localStorage.get(key);
    if (local != null) {
      _memoryCache[key] = local;
      return local;
    }
    
    // Fetch from remote
    final remote = await _supabase.from('table').select();
    _localStorage.set(key, remote);
    _memoryCache[key] = remote;
    return remote;
  }
}
```

---

## 🔄 State Management Architecture

### Provider/Riverpod Structure

```
providers/
├── auth_provider.dart          # Authentication state
├── chat_provider.dart          # Chat list state
├── message_provider.dart       # Message state
├── user_provider.dart          # User profile state
├── presence_provider.dart      # Online status state
├── notification_provider.dart  # Notification state
└── theme_provider.dart         # Theme state
```

### State Flow

```
User Action → Widget → Provider → Service → Supabase
                ↑                              ↓
                └──────── notifyListeners() ───┘
```

---

## 🧪 Testing Architecture

### Testing Pyramid

```
        ┌─────────────┐
        │  E2E Tests  │  (10%)
        ├─────────────┤
        │Widget Tests │  (30%)
        ├─────────────┤
        │ Unit Tests  │  (60%)
        └─────────────┘
```

**Test Structure**:
```
test/
├── unit/
│   ├── models/
│   ├── services/
│   └── utils/
├── widget/
│   ├── screens/
│   └── widgets/
└── integration/
    └── flows/
```

---

## 📱 Platform-Specific Considerations

### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Notification channels
- Background service restrictions

### iOS
- Minimum version: iOS 12.0
- Push notification certificates
- Background modes
- App Transport Security

### Web
- Progressive Web App (PWA)
- Service workers
- Browser compatibility
- Responsive design

### Desktop
- Window management
- Native menus
- File system access
- Platform-specific UI

---

## 🔗 Integration Points

### 1. Supabase Integration

```dart
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  static SupabaseClient get client => Supabase.instance.client;
}
```

### 2. OneSignal Integration

```dart
class OneSignalConfig {
  static const String appId = String.fromEnvironment('ONESIGNAL_APP_ID');
  
  static Future<void> initialize() async {
    OneSignal.initialize(appId);
    OneSignal.Notifications.requestPermission(true);
  }
}
```

---

## 📊 Monitoring & Analytics

### Error Tracking
- Sentry integration
- Crash reporting
- Error logs

### Performance Monitoring
- App launch time
- Screen load time
- API response time
- Frame rate (FPS)

### User Analytics
- User engagement
- Feature usage
- Retention metrics
- Conversion funnel

---

## 🚀 Deployment Architecture

### CI/CD Pipeline

```
Code Push → GitHub → CI/CD (GitHub Actions)
                         ↓
                    Run Tests
                         ↓
                    Build App
                         ↓
              ┌──────────┴──────────┐
              ↓                     ↓
         Play Store           App Store
```

### Environment Configuration

- **Development**: Local Supabase instance
- **Staging**: Staging Supabase project
- **Production**: Production Supabase project

---

## 📝 Best Practices

1. **Code Organization**: Follow feature-based structure
2. **Naming Conventions**: Use consistent naming
3. **Error Handling**: Comprehensive error handling
4. **Logging**: Structured logging
5. **Documentation**: Inline code documentation
6. **Version Control**: Semantic versioning
7. **Code Review**: Mandatory PR reviews
8. **Testing**: Maintain test coverage >80%

---

## 🔄 Future Enhancements

1. **Microservices**: Split backend into microservices
2. **GraphQL**: Replace REST with GraphQL
3. **Redis**: Add caching layer
4. **Kubernetes**: Container orchestration
5. **CDN**: Content delivery network
6. **Load Balancer**: Distribute traffic
7. **Message Queue**: Async processing

---

**Document Version**: 1.0  
**Last Updated**: October 1, 2025  
**Next Review**: TBD
