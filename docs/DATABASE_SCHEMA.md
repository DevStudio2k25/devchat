# 🗄️ DevChat - Database Schema

> **Version**: 1.0  
> **Last Updated**: October 1, 2025  
> **Database**: PostgreSQL (Supabase)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Entity Relationship Diagram](#entity-relationship-diagram)
3. [Tables](#tables)
4. [Relationships](#relationships)
5. [Indexes](#indexes)
6. [Row-Level Security](#row-level-security)
7. [Functions & Triggers](#functions--triggers)
8. [Migration Scripts](#migration-scripts)

---

## 🎯 Overview

The DevChat database is built on PostgreSQL and leverages Supabase's built-in features including:
- Row-Level Security (RLS)
- Real-time subscriptions
- Authentication integration
- Storage integration

---

## 📊 Entity Relationship Diagram

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│    users    │────┬───→│chat_members │←───┬────│    chats    │
└─────────────┘    │    └─────────────┘    │    └─────────────┘
       │           │                        │           │
       │           │    ┌─────────────┐    │           │
       │           └───→│  messages   │←───┘           │
       │                └─────────────┘                │
       │                       │                       │
       │                       ↓                       │
       │                ┌─────────────┐               │
       │                │  reactions  │               │
       │                └─────────────┘               │
       │                                               │
       │                ┌─────────────┐               │
       └───────────────→│    files    │←──────────────┘
                        └─────────────┘
                        
       ┌─────────────┐         ┌─────────────┐
       │  presence   │         │notifications│
       └─────────────┘         └─────────────┘
```

---

## 📋 Tables

### 1. users

Stores user profile information. Linked to Supabase Auth.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(100),
  avatar_url TEXT,
  bio TEXT,
  status VARCHAR(50) DEFAULT 'offline',
  last_seen TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT username_length CHECK (char_length(username) >= 3),
  CONSTRAINT valid_status CHECK (status IN ('online', 'offline', 'away', 'busy'))
);

-- Indexes
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
```

**Columns**:
- `id` - UUID, primary key (from auth.users)
- `username` - Unique username (3-50 chars)
- `email` - User email address
- `full_name` - Display name
- `avatar_url` - Profile picture URL
- `bio` - User biography
- `status` - Online status (online/offline/away/busy)
- `last_seen` - Last activity timestamp
- `created_at` - Account creation timestamp
- `updated_at` - Last profile update timestamp

---

### 2. chats

Stores chat room information (both 1-to-1 and group chats).

```sql
CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100),
  description TEXT,
  is_group BOOLEAN DEFAULT false,
  avatar_url TEXT,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_message_at TIMESTAMPTZ,
  
  CONSTRAINT group_must_have_name CHECK (
    (is_group = false) OR (is_group = true AND name IS NOT NULL)
  )
);

-- Indexes
CREATE INDEX idx_chats_is_group ON chats(is_group);
CREATE INDEX idx_chats_created_by ON chats(created_by);
CREATE INDEX idx_chats_last_message_at ON chats(last_message_at DESC);
```

**Columns**:
- `id` - UUID, primary key
- `name` - Chat name (required for groups)
- `description` - Chat description (groups only)
- `is_group` - Boolean flag for group chats
- `avatar_url` - Group avatar URL
- `created_by` - User who created the chat
- `created_at` - Chat creation timestamp
- `updated_at` - Last chat update timestamp
- `last_message_at` - Timestamp of last message

---

### 3. chat_members

Junction table for chat participants.

```sql
CREATE TABLE chat_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(20) DEFAULT 'member',
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  last_read_at TIMESTAMPTZ,
  is_muted BOOLEAN DEFAULT false,
  
  UNIQUE(chat_id, user_id),
  CONSTRAINT valid_role CHECK (role IN ('admin', 'member'))
);

-- Indexes
CREATE INDEX idx_chat_members_chat_id ON chat_members(chat_id);
CREATE INDEX idx_chat_members_user_id ON chat_members(user_id);
CREATE INDEX idx_chat_members_role ON chat_members(role);
```

**Columns**:
- `id` - UUID, primary key
- `chat_id` - Reference to chat
- `user_id` - Reference to user
- `role` - User role (admin/member)
- `joined_at` - When user joined chat
- `last_read_at` - Last message read timestamp
- `is_muted` - Notification mute status

---

### 4. messages

Stores all chat messages.

```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT,
  message_type VARCHAR(20) DEFAULT 'text',
  file_id UUID REFERENCES files(id) ON DELETE SET NULL,
  reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  is_edited BOOLEAN DEFAULT false,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_message_type CHECK (
    message_type IN ('text', 'image', 'file', 'audio', 'video', 'system')
  ),
  CONSTRAINT content_or_file CHECK (
    (message_type = 'text' AND content IS NOT NULL) OR
    (message_type != 'text' AND file_id IS NOT NULL)
  )
);

-- Indexes
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_reply_to_id ON messages(reply_to_id);
CREATE INDEX idx_messages_is_deleted ON messages(is_deleted) WHERE is_deleted = false;

-- Full-text search index
CREATE INDEX idx_messages_content_search ON messages USING gin(to_tsvector('english', content));
```

**Columns**:
- `id` - UUID, primary key
- `chat_id` - Reference to chat
- `sender_id` - Reference to sender user
- `content` - Message text content
- `message_type` - Type of message (text/image/file/audio/video/system)
- `file_id` - Reference to file (if applicable)
- `reply_to_id` - Reference to parent message (for threads)
- `is_edited` - Flag for edited messages
- `is_deleted` - Soft delete flag
- `created_at` - Message creation timestamp
- `updated_at` - Last edit timestamp

---

### 5. reactions

Stores emoji reactions to messages.

```sql
CREATE TABLE reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  emoji VARCHAR(10) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(message_id, user_id, emoji)
);

-- Indexes
CREATE INDEX idx_reactions_message_id ON reactions(message_id);
CREATE INDEX idx_reactions_user_id ON reactions(user_id);
```

**Columns**:
- `id` - UUID, primary key
- `message_id` - Reference to message
- `user_id` - Reference to user who reacted
- `emoji` - Emoji character
- `created_at` - Reaction timestamp

---

### 6. files

Stores metadata for uploaded files.

```sql
CREATE TABLE files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_type VARCHAR(100) NOT NULL,
  file_size BIGINT NOT NULL,
  storage_path TEXT NOT NULL,
  public_url TEXT,
  thumbnail_url TEXT,
  mime_type VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_file_size CHECK (file_size > 0 AND file_size <= 104857600) -- 100MB max
);

-- Indexes
CREATE INDEX idx_files_chat_id ON files(chat_id);
CREATE INDEX idx_files_uploaded_by ON files(uploaded_by);
CREATE INDEX idx_files_created_at ON files(created_at DESC);
CREATE INDEX idx_files_file_type ON files(file_type);
```

**Columns**:
- `id` - UUID, primary key
- `chat_id` - Reference to chat
- `uploaded_by` - Reference to uploader user
- `file_name` - Original file name
- `file_type` - File extension
- `file_size` - File size in bytes
- `storage_path` - Path in Supabase Storage
- `public_url` - Public access URL
- `thumbnail_url` - Thumbnail URL (for images/videos)
- `mime_type` - MIME type
- `created_at` - Upload timestamp

---

### 7. presence

Tracks user online status in real-time.

```sql
CREATE TABLE presence (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'online',
  is_typing BOOLEAN DEFAULT false,
  last_activity TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, chat_id),
  CONSTRAINT valid_presence_status CHECK (status IN ('online', 'away', 'offline'))
);

-- Indexes
CREATE INDEX idx_presence_user_id ON presence(user_id);
CREATE INDEX idx_presence_chat_id ON presence(chat_id);
CREATE INDEX idx_presence_status ON presence(status);
CREATE INDEX idx_presence_last_activity ON presence(last_activity DESC);
```

**Columns**:
- `id` - UUID, primary key
- `user_id` - Reference to user
- `chat_id` - Reference to chat (optional)
- `status` - Presence status (online/away/offline)
- `is_typing` - Typing indicator
- `last_activity` - Last activity timestamp

---

### 8. notifications

Stores notification history.

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ,
  
  CONSTRAINT valid_notification_type CHECK (
    type IN ('new_message', 'mention', 'group_invite', 'system')
  )
);

-- Indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(type);
```

**Columns**:
- `id` - UUID, primary key
- `user_id` - Reference to recipient user
- `type` - Notification type
- `title` - Notification title
- `body` - Notification body
- `data` - Additional JSON data
- `is_read` - Read status
- `created_at` - Notification timestamp
- `read_at` - When notification was read

---

## 🔗 Relationships

### One-to-Many Relationships

1. **users → messages**: One user can send many messages
2. **users → files**: One user can upload many files
3. **chats → messages**: One chat can have many messages
4. **chats → files**: One chat can have many files
5. **messages → reactions**: One message can have many reactions

### Many-to-Many Relationships

1. **users ↔ chats** (via chat_members): Users can be in multiple chats, chats can have multiple users

### Self-Referencing Relationships

1. **messages → messages** (reply_to_id): Messages can reply to other messages

---

## 📑 Indexes

### Performance Indexes

```sql
-- Chat list optimization
CREATE INDEX idx_chat_members_user_last_read 
ON chat_members(user_id, last_read_at);

-- Message pagination
CREATE INDEX idx_messages_chat_created 
ON messages(chat_id, created_at DESC);

-- Unread message count
CREATE INDEX idx_messages_unread 
ON messages(chat_id, created_at) 
WHERE is_deleted = false;

-- User search
CREATE INDEX idx_users_username_trgm 
ON users USING gin(username gin_trgm_ops);

-- Message search
CREATE INDEX idx_messages_content_trgm 
ON messages USING gin(content gin_trgm_ops);
```

---

## 🔒 Row-Level Security (RLS)

### Enable RLS on All Tables

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
```

### RLS Policies

#### users Table

```sql
-- Users can view all user profiles
CREATE POLICY "Users can view all profiles"
ON users FOR SELECT
USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
ON users FOR INSERT
WITH CHECK (auth.uid() = id);
```

#### chats Table

```sql
-- Users can view chats they are members of
CREATE POLICY "Users can view their chats"
ON chats FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = chats.id
    AND user_id = auth.uid()
  )
);

-- Users can create chats
CREATE POLICY "Users can create chats"
ON chats FOR INSERT
WITH CHECK (auth.uid() = created_by);

-- Chat admins can update chat
CREATE POLICY "Admins can update chat"
ON chats FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = chats.id
    AND user_id = auth.uid()
    AND role = 'admin'
  )
);
```

#### chat_members Table

```sql
-- Users can view members of their chats
CREATE POLICY "Users can view chat members"
ON chat_members FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM chat_members cm
    WHERE cm.chat_id = chat_members.chat_id
    AND cm.user_id = auth.uid()
  )
);

-- Admins can add members
CREATE POLICY "Admins can add members"
ON chat_members FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = chat_members.chat_id
    AND user_id = auth.uid()
    AND role = 'admin'
  )
);

-- Users can remove themselves
CREATE POLICY "Users can leave chat"
ON chat_members FOR DELETE
USING (user_id = auth.uid());
```

#### messages Table

```sql
-- Users can view messages in their chats
CREATE POLICY "Users can view messages in their chats"
ON messages FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = messages.chat_id
    AND user_id = auth.uid()
  )
);

-- Users can send messages to their chats
CREATE POLICY "Users can send messages"
ON messages FOR INSERT
WITH CHECK (
  sender_id = auth.uid() AND
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = messages.chat_id
    AND user_id = auth.uid()
  )
);

-- Users can update their own messages
CREATE POLICY "Users can edit own messages"
ON messages FOR UPDATE
USING (sender_id = auth.uid());

-- Users can delete their own messages
CREATE POLICY "Users can delete own messages"
ON messages FOR DELETE
USING (sender_id = auth.uid());
```

#### reactions Table

```sql
-- Users can view reactions in their chats
CREATE POLICY "Users can view reactions"
ON reactions FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM messages m
    JOIN chat_members cm ON m.chat_id = cm.chat_id
    WHERE m.id = reactions.message_id
    AND cm.user_id = auth.uid()
  )
);

-- Users can add reactions
CREATE POLICY "Users can add reactions"
ON reactions FOR INSERT
WITH CHECK (user_id = auth.uid());

-- Users can remove their own reactions
CREATE POLICY "Users can remove own reactions"
ON reactions FOR DELETE
USING (user_id = auth.uid());
```

#### files Table

```sql
-- Users can view files in their chats
CREATE POLICY "Users can view files in their chats"
ON files FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = files.chat_id
    AND user_id = auth.uid()
  )
);

-- Users can upload files to their chats
CREATE POLICY "Users can upload files"
ON files FOR INSERT
WITH CHECK (
  uploaded_by = auth.uid() AND
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = files.chat_id
    AND user_id = auth.uid()
  )
);
```

#### notifications Table

```sql
-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
USING (user_id = auth.uid());

-- Users can update their own notifications
CREATE POLICY "Users can update own notifications"
ON notifications FOR UPDATE
USING (user_id = auth.uid());
```

---

## ⚙️ Functions & Triggers

### 1. Update Timestamp Function

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chats_updated_at
  BEFORE UPDATE ON chats
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at
  BEFORE UPDATE ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### 2. Update Last Message Timestamp

```sql
CREATE OR REPLACE FUNCTION update_chat_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE chats
  SET last_message_at = NEW.created_at
  WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_chat_last_message_trigger
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_chat_last_message();
```

### 3. Create User Profile on Signup

```sql
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO users (id, email, username)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_user_profile();
```

### 4. Send Notification on New Message

```sql
CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER AS $$
DECLARE
  member_record RECORD;
BEGIN
  -- Create notifications for all chat members except sender
  FOR member_record IN
    SELECT user_id FROM chat_members
    WHERE chat_id = NEW.chat_id
    AND user_id != NEW.sender_id
  LOOP
    INSERT INTO notifications (user_id, type, title, body, data)
    VALUES (
      member_record.user_id,
      'new_message',
      'New Message',
      NEW.content,
      jsonb_build_object(
        'chat_id', NEW.chat_id,
        'message_id', NEW.id,
        'sender_id', NEW.sender_id
      )
    );
  END LOOP;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_new_message_trigger
  AFTER INSERT ON messages
  FOR EACH ROW
  WHEN (NEW.is_deleted = false)
  EXECUTE FUNCTION notify_new_message();
```

### 5. Clean Up Old Presence Records

```sql
CREATE OR REPLACE FUNCTION cleanup_old_presence()
RETURNS void AS $$
BEGIN
  DELETE FROM presence
  WHERE last_activity < NOW() - INTERVAL '1 hour'
  AND status = 'offline';
END;
$$ LANGUAGE plpgsql;

-- Schedule with pg_cron (if available)
-- SELECT cron.schedule('cleanup-presence', '*/15 * * * *', 'SELECT cleanup_old_presence()');
```

---

## 📜 Migration Scripts

### Initial Migration

```sql
-- migrations/001_initial_schema.sql

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create tables in order
-- (Include all CREATE TABLE statements from above)

-- Enable RLS
-- (Include all ALTER TABLE ENABLE RLS statements)

-- Create policies
-- (Include all CREATE POLICY statements)

-- Create functions and triggers
-- (Include all function and trigger definitions)
```

### Sample Data Migration

```sql
-- migrations/002_sample_data.sql

-- Insert sample users (for testing)
INSERT INTO users (id, username, email, full_name, bio)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'john_doe', 'john@example.com', 'John Doe', 'Software Developer'),
  ('00000000-0000-0000-0000-000000000002', 'jane_smith', 'jane@example.com', 'Jane Smith', 'UI/UX Designer');
```

---

## 🔍 Useful Queries

### Get User's Chats with Last Message

```sql
SELECT 
  c.*,
  cm.last_read_at,
  cm.is_muted,
  (
    SELECT COUNT(*)
    FROM messages m
    WHERE m.chat_id = c.id
    AND m.created_at > COALESCE(cm.last_read_at, '1970-01-01')
    AND m.sender_id != auth.uid()
    AND m.is_deleted = false
  ) as unread_count,
  (
    SELECT json_build_object(
      'id', m.id,
      'content', m.content,
      'sender_id', m.sender_id,
      'created_at', m.created_at
    )
    FROM messages m
    WHERE m.chat_id = c.id
    AND m.is_deleted = false
    ORDER BY m.created_at DESC
    LIMIT 1
  ) as last_message
FROM chats c
JOIN chat_members cm ON c.id = cm.chat_id
WHERE cm.user_id = auth.uid()
ORDER BY c.last_message_at DESC NULLS LAST;
```

### Search Messages

```sql
SELECT m.*, u.username, u.avatar_url
FROM messages m
JOIN users u ON m.sender_id = u.id
WHERE m.chat_id = :chat_id
AND m.is_deleted = false
AND to_tsvector('english', m.content) @@ plainto_tsquery('english', :search_query)
ORDER BY m.created_at DESC;
```

### Get Unread Message Count

```sql
SELECT 
  cm.chat_id,
  COUNT(m.id) as unread_count
FROM chat_members cm
LEFT JOIN messages m ON m.chat_id = cm.chat_id
  AND m.created_at > COALESCE(cm.last_read_at, '1970-01-01')
  AND m.sender_id != cm.user_id
  AND m.is_deleted = false
WHERE cm.user_id = auth.uid()
GROUP BY cm.chat_id;
```

---

**Document Version**: 1.0  
**Last Updated**: October 1, 2025  
**Next Review**: TBD
