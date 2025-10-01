# 🗄️ DevChat - Supabase Setup Guide

> **Version**: 1.0  
> **Last Updated**: October 1, 2025  
> **Estimated Time**: 1-2 hours

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Project Creation](#project-creation)
3. [Database Setup](#database-setup)
4. [Authentication Setup](#authentication-setup)
5. [Storage Setup](#storage-setup)
6. [Realtime Setup](#realtime-setup)
7. [Edge Functions](#edge-functions)
8. [Testing & Verification](#testing--verification)

---

## 🎯 Overview

Supabase provides the complete backend infrastructure for DevChat including:
- **PostgreSQL Database** - Data storage with RLS
- **Authentication** - User management and OAuth
- **Storage** - File uploads (S3-compatible)
- **Realtime** - WebSocket subscriptions
- **Edge Functions** - Serverless functions

---

## 🚀 Project Creation

### Step 1: Create Account

1. Go to https://supabase.com
2. Click "Start your project"
3. Sign up with GitHub (recommended) or email

### Step 2: Create New Project

1. Click "New Project"
2. Select organization (or create new)
3. Fill in project details:

```
Project Name: devchat
Database Password: [Generate strong password - SAVE THIS!]
Region: [Select closest region]
Pricing Plan: Free (for development)
```

4. Click "Create new project"
5. Wait 2-3 minutes for provisioning

### Step 3: Save Credentials

1. Go to **Settings** > **API**
2. Copy and save:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **Project API keys**:
     - `anon` `public` key (for client-side)
     - `service_role` `secret` key (for server-side only)

3. Update your `.env` file:

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
# NEVER commit service_role key to version control!
```

---

## 🗄️ Database Setup

### Step 1: Access SQL Editor

1. Navigate to **SQL Editor** in sidebar
2. Click "New query"

### Step 2: Enable Extensions

```sql
-- Enable required PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- Text search
CREATE EXTENSION IF NOT EXISTS "pgcrypto";       -- Encryption functions
```

Click "Run" to execute.

### Step 3: Create Tables

Copy the complete schema from [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) or use the migration below:

```sql
-- Create users table
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

-- Create chats table
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

-- Create chat_members table
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

-- Create messages table
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
  )
);

-- Create reactions table
CREATE TABLE reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  emoji VARCHAR(10) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(message_id, user_id, emoji)
);

-- Create files table
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
  
  CONSTRAINT valid_file_size CHECK (file_size > 0 AND file_size <= 104857600)
);

-- Create presence table
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

-- Create notifications table
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
```

### Step 4: Create Indexes

```sql
-- Users indexes
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);

-- Chats indexes
CREATE INDEX idx_chats_is_group ON chats(is_group);
CREATE INDEX idx_chats_created_by ON chats(created_by);
CREATE INDEX idx_chats_last_message_at ON chats(last_message_at DESC);

-- Chat members indexes
CREATE INDEX idx_chat_members_chat_id ON chat_members(chat_id);
CREATE INDEX idx_chat_members_user_id ON chat_members(user_id);
CREATE INDEX idx_chat_members_role ON chat_members(role);

-- Messages indexes
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_reply_to_id ON messages(reply_to_id);
CREATE INDEX idx_messages_content_search ON messages USING gin(to_tsvector('english', content));

-- Reactions indexes
CREATE INDEX idx_reactions_message_id ON reactions(message_id);
CREATE INDEX idx_reactions_user_id ON reactions(user_id);

-- Files indexes
CREATE INDEX idx_files_chat_id ON files(chat_id);
CREATE INDEX idx_files_uploaded_by ON files(uploaded_by);
CREATE INDEX idx_files_created_at ON files(created_at DESC);

-- Presence indexes
CREATE INDEX idx_presence_user_id ON presence(user_id);
CREATE INDEX idx_presence_chat_id ON presence(chat_id);
CREATE INDEX idx_presence_status ON presence(status);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
```

### Step 5: Create Functions & Triggers

```sql
-- Update timestamp function
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

-- Update chat last message timestamp
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

-- Create user profile on signup
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

### Step 6: Enable Row-Level Security

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view all profiles"
ON users FOR SELECT
USING (true);

CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- Chats policies
CREATE POLICY "Users can view their chats"
ON chats FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = chats.id
    AND user_id = auth.uid()
  )
);

CREATE POLICY "Users can create chats"
ON chats FOR INSERT
WITH CHECK (auth.uid() = created_by);

-- Chat members policies
CREATE POLICY "Users can view chat members"
ON chat_members FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM chat_members cm
    WHERE cm.chat_id = chat_members.chat_id
    AND cm.user_id = auth.uid()
  )
);

-- Messages policies
CREATE POLICY "Users can view messages in their chats"
ON messages FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = messages.chat_id
    AND user_id = auth.uid()
  )
);

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

CREATE POLICY "Users can edit own messages"
ON messages FOR UPDATE
USING (sender_id = auth.uid());

-- Reactions policies
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

CREATE POLICY "Users can add reactions"
ON reactions FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can remove own reactions"
ON reactions FOR DELETE
USING (user_id = auth.uid());

-- Files policies
CREATE POLICY "Users can view files in their chats"
ON files FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = files.chat_id
    AND user_id = auth.uid()
  )
);

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

-- Notifications policies
CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
ON notifications FOR UPDATE
USING (user_id = auth.uid());
```

---

## 🔐 Authentication Setup

### Step 1: Configure Email Provider

1. Go to **Authentication** > **Providers**
2. Find **Email** provider
3. Enable it
4. Configure settings:
   - ✅ Enable email confirmations (recommended for production)
   - ✅ Enable secure email change
   - Set confirmation URL: `https://yourapp.com/auth/confirm`

### Step 2: Configure OAuth Providers

#### Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create new project or select existing
3. Enable Google+ API
4. Go to **Credentials** > **Create Credentials** > **OAuth 2.0 Client ID**
5. Configure OAuth consent screen
6. Create OAuth client:
   - Application type: Web application
   - Authorized redirect URIs: `https://xxxxx.supabase.co/auth/v1/callback`
7. Copy Client ID and Client Secret
8. In Supabase:
   - Go to **Authentication** > **Providers**
   - Enable **Google**
   - Paste Client ID and Secret
   - Save

#### GitHub OAuth

1. Go to [GitHub Settings](https://github.com/settings/developers)
2. Click **New OAuth App**
3. Fill in details:
   - Application name: DevChat
   - Homepage URL: `https://yourapp.com`
   - Authorization callback URL: `https://xxxxx.supabase.co/auth/v1/callback`
4. Register application
5. Copy Client ID and generate Client Secret
6. In Supabase:
   - Go to **Authentication** > **Providers**
   - Enable **GitHub**
   - Paste Client ID and Secret
   - Save

### Step 3: Configure Auth Settings

1. Go to **Authentication** > **Settings**
2. Configure:
   - **Site URL**: `https://yourapp.com`
   - **Redirect URLs**: Add allowed redirect URLs
   - **JWT expiry**: 3600 (1 hour)
   - **Refresh token rotation**: Enabled
   - **Reuse interval**: 10 seconds

---

## 📦 Storage Setup

### Step 1: Create Buckets

1. Go to **Storage** in sidebar
2. Click **New bucket**

Create these buckets:

```
Bucket Name: avatars
Public: Yes
File size limit: 5MB
Allowed MIME types: image/*
```

```
Bucket Name: chat-images
Public: No
File size limit: 10MB
Allowed MIME types: image/*
```

```
Bucket Name: chat-files
Public: No
File size limit: 100MB
Allowed MIME types: */*
```

### Step 2: Configure Storage Policies

Go to **Storage** > **Policies** and add:

#### Avatars Bucket

```sql
-- Public read access
CREATE POLICY "Public avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- Users can upload own avatar
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can update own avatar
CREATE POLICY "Users can update own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete own avatar
CREATE POLICY "Users can delete own avatar"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

#### Chat Files Bucket

```sql
-- Users can view files in their chats
CREATE POLICY "Users can view chat files"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'chat-files' AND
  EXISTS (
    SELECT 1 FROM files f
    JOIN chat_members cm ON f.chat_id = cm.chat_id
    WHERE f.storage_path = name
    AND cm.user_id = auth.uid()
  )
);

-- Users can upload files to their chats
CREATE POLICY "Users can upload chat files"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'chat-files' AND
  auth.uid() IS NOT NULL
);
```

---

## ⚡ Realtime Setup

### Step 1: Enable Realtime

1. Go to **Database** > **Replication**
2. Find and enable replication for:
   - ✅ `messages`
   - ✅ `chats`
   - ✅ `presence`
   - ✅ `reactions`
   - ✅ `chat_members`

### Step 2: Configure Realtime Settings

1. Go to **Settings** > **API**
2. Scroll to **Realtime**
3. Configure:
   - Max connections: 100 (Free tier)
   - Max channels per client: 100
   - Max events per second: 100

---

## 🔧 Edge Functions (Optional)

### Step 1: Install Supabase CLI

```bash
npm install -g supabase
```

### Step 2: Create Edge Function

```bash
# Login
supabase login

# Link project
supabase link --project-ref your-project-ref

# Create function
supabase functions new send-notification
```

### Step 3: Write Function

Edit `supabase/functions/send-notification/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { userId, message } = await req.json()
  
  // Send OneSignal notification
  const response = await fetch('https://onesignal.com/api/v1/notifications', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Key ${Deno.env.get('ONESIGNAL_REST_API_KEY')}`
    },
    body: JSON.stringify({
      app_id: Deno.env.get('ONESIGNAL_APP_ID'),
      include_external_user_ids: [userId],
      contents: { en: message }
    })
  })
  
  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

### Step 4: Deploy Function

```bash
supabase functions deploy send-notification --no-verify-jwt
```

---

## ✅ Testing & Verification

### Test Database Connection

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testConnection() async {
  try {
    final response = await Supabase.instance.client
      .from('users')
      .select()
      .limit(1);
    print('✅ Database connection successful');
  } catch (e) {
    print('❌ Database connection failed: $e');
  }
}
```

### Test Authentication

```dart
Future<void> testAuth() async {
  try {
    final response = await Supabase.instance.client.auth.signUp(
      email: 'test@example.com',
      password: 'testpassword123',
    );
    print('✅ Authentication working');
  } catch (e) {
    print('❌ Authentication failed: $e');
  }
}
```

### Test Storage

```dart
Future<void> testStorage() async {
  try {
    final bytes = Uint8List.fromList([1, 2, 3]);
    await Supabase.instance.client.storage
      .from('avatars')
      .uploadBinary('test/test.txt', bytes);
    print('✅ Storage working');
  } catch (e) {
    print('❌ Storage failed: $e');
  }
}
```

### Test Realtime

```dart
void testRealtime() {
  Supabase.instance.client
    .channel('test')
    .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        print('✅ Realtime working: $payload');
      },
    )
    .subscribe();
}
```

---

## 📊 Monitoring

### View Logs

1. Go to **Logs** in sidebar
2. Select log type:
   - API logs
   - Database logs
   - Auth logs
   - Storage logs
   - Realtime logs

### Check Usage

1. Go to **Settings** > **Usage**
2. Monitor:
   - Database size
   - Storage usage
   - Bandwidth
   - API requests

---

## 🔒 Security Best Practices

1. ✅ **Never expose service_role key** in client code
2. ✅ **Always use RLS policies** for data access
3. ✅ **Validate all inputs** in Edge Functions
4. ✅ **Use environment variables** for secrets
5. ✅ **Enable email confirmation** in production
6. ✅ **Set up rate limiting** for API endpoints
7. ✅ **Regular backups** of database
8. ✅ **Monitor logs** for suspicious activity

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)
- [Realtime Guide](https://supabase.com/docs/guides/realtime)

---

**Document Version**: 1.0  
**Last Updated**: October 1, 2025  
**Need Help?** Join [Supabase Discord](https://discord.supabase.com)
