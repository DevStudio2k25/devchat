-- DevChat Database Schema
-- Migration: 001_initial_schema
-- Created: 2025-10-01

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- USERS TABLE
-- =====================================================
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

-- Users indexes
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);

-- =====================================================
-- CHATS TABLE
-- =====================================================
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

-- Chats indexes
CREATE INDEX idx_chats_is_group ON chats(is_group);
CREATE INDEX idx_chats_created_by ON chats(created_by);
CREATE INDEX idx_chats_last_message_at ON chats(last_message_at DESC);

-- =====================================================
-- CHAT_MEMBERS TABLE
-- =====================================================
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

-- Chat members indexes
CREATE INDEX idx_chat_members_chat_id ON chat_members(chat_id);
CREATE INDEX idx_chat_members_user_id ON chat_members(user_id);
CREATE INDEX idx_chat_members_role ON chat_members(role);

-- =====================================================
-- MESSAGES TABLE
-- =====================================================
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT,
  message_type VARCHAR(20) DEFAULT 'text',
  file_id UUID,
  reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  is_edited BOOLEAN DEFAULT false,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_message_type CHECK (
    message_type IN ('text', 'image', 'file', 'audio', 'video', 'system')
  )
);

-- Messages indexes
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_reply_to_id ON messages(reply_to_id);
CREATE INDEX idx_messages_is_deleted ON messages(is_deleted) WHERE is_deleted = false;
CREATE INDEX idx_messages_content_search ON messages USING gin(to_tsvector('english', content));

-- =====================================================
-- REACTIONS TABLE
-- =====================================================
CREATE TABLE reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  emoji VARCHAR(10) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(message_id, user_id, emoji)
);

-- Reactions indexes
CREATE INDEX idx_reactions_message_id ON reactions(message_id);
CREATE INDEX idx_reactions_user_id ON reactions(user_id);

-- =====================================================
-- FILES TABLE
-- =====================================================
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

-- Files indexes
CREATE INDEX idx_files_chat_id ON files(chat_id);
CREATE INDEX idx_files_uploaded_by ON files(uploaded_by);
CREATE INDEX idx_files_created_at ON files(created_at DESC);

-- Add foreign key for messages.file_id
ALTER TABLE messages ADD CONSTRAINT fk_messages_file_id 
  FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL;

-- =====================================================
-- PRESENCE TABLE
-- =====================================================
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

-- Presence indexes
CREATE INDEX idx_presence_user_id ON presence(user_id);
CREATE INDEX idx_presence_chat_id ON presence(chat_id);
CREATE INDEX idx_presence_status ON presence(status);
CREATE INDEX idx_presence_last_activity ON presence(last_activity DESC);

-- =====================================================
-- NOTIFICATIONS TABLE
-- =====================================================
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

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(type);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

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

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

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

CREATE POLICY "Users can insert own profile"
ON users FOR INSERT
WITH CHECK (auth.uid() = id);

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

CREATE POLICY "Users can leave chat"
ON chat_members FOR DELETE
USING (user_id = auth.uid());

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

CREATE POLICY "Users can delete own messages"
ON messages FOR DELETE
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

-- Presence policies
CREATE POLICY "Users can view presence in their chats"
ON presence FOR SELECT
USING (
  user_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM chat_members
    WHERE chat_id = presence.chat_id
    AND user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert own presence"
ON presence FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own presence"
ON presence FOR UPDATE
USING (user_id = auth.uid());

-- Notifications policies
CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
ON notifications FOR UPDATE
USING (user_id = auth.uid());

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE users IS 'User profiles and authentication data';
COMMENT ON TABLE chats IS 'Chat rooms (1-to-1 and groups)';
COMMENT ON TABLE chat_members IS 'Chat participants and their roles';
COMMENT ON TABLE messages IS 'All chat messages';
COMMENT ON TABLE reactions IS 'Emoji reactions to messages';
COMMENT ON TABLE files IS 'File metadata for uploads';
COMMENT ON TABLE presence IS 'User online status and typing indicators';
COMMENT ON TABLE notifications IS 'Push notification history';
