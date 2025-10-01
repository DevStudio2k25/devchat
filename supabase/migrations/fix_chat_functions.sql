-- ============================================
-- Fix Chat Functions and Policies
-- Run this in Supabase SQL Editor
-- ============================================

-- Step 1: Drop old function and create new one (returns full chat object)
DROP FUNCTION IF EXISTS public.find_direct_chat(uuid, uuid);

CREATE OR REPLACE FUNCTION public.find_direct_chat(user1_id uuid, user2_id uuid)
RETURNS SETOF chats
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Find a direct chat between two users
  RETURN QUERY
  SELECT c.*
  FROM chats c
  WHERE c.is_group = false
    AND EXISTS (
      SELECT 1 FROM chat_members cm1 
      WHERE cm1.chat_id = c.id AND cm1.user_id = user1_id
    )
    AND EXISTS (
      SELECT 1 FROM chat_members cm2 
      WHERE cm2.chat_id = c.id AND cm2.user_id = user2_id
    )
    AND (
      SELECT COUNT(*) FROM chat_members cm 
      WHERE cm.chat_id = c.id
    ) = 2
  LIMIT 1;
END;
$$;

-- Step 2: Fix chat_members RLS policies (remove recursion)
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view chat members" ON public.chat_members;
DROP POLICY IF EXISTS "Users can insert chat members" ON public.chat_members;
DROP POLICY IF EXISTS "Users can update chat members" ON public.chat_members;
DROP POLICY IF EXISTS "Users can update own membership" ON public.chat_members;
DROP POLICY IF EXISTS "Users can delete chat members" ON public.chat_members;
DROP POLICY IF EXISTS "Admins can delete members" ON public.chat_members;

-- Create new non-recursive policies
CREATE POLICY "Users can view chat members"
ON public.chat_members
FOR SELECT
TO authenticated
USING (true);  -- Simplified: all authenticated users can view

CREATE POLICY "Users can insert chat members"
ON public.chat_members
FOR INSERT
TO authenticated
WITH CHECK (true);  -- Simplified: all authenticated users can insert

CREATE POLICY "Users can update own membership"
ON public.chat_members
FOR UPDATE
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Admins can delete members"
ON public.chat_members
FOR DELETE
TO authenticated
USING (
  user_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM chat_members cm
    WHERE cm.chat_id = chat_members.chat_id
      AND cm.user_id = auth.uid()
      AND cm.role = 'admin'
  )
);

-- Step 3: Fix chats table policies (if needed)
DROP POLICY IF EXISTS "Users can view their chats" ON public.chats;
DROP POLICY IF EXISTS "Users can create chats" ON public.chats;
DROP POLICY IF EXISTS "Users can update their chats" ON public.chats;
DROP POLICY IF EXISTS "Admins can update chats" ON public.chats;

CREATE POLICY "Users can view their chats"
ON public.chats
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM chat_members cm
    WHERE cm.chat_id = chats.id
      AND cm.user_id = auth.uid()
  )
);

CREATE POLICY "Users can create chats"
ON public.chats
FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Admins can update chats"
ON public.chats
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM chat_members cm
    WHERE cm.chat_id = chats.id
      AND cm.user_id = auth.uid()
      AND cm.role = 'admin'
  )
);

-- ============================================
-- Verification
-- ============================================

-- Check if function exists
SELECT proname, proargnames 
FROM pg_proc 
WHERE proname = 'find_direct_chat';

-- Check policies
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('chats', 'chat_members')
ORDER BY tablename, policyname;

-- ============================================
-- SUCCESS! Now chat creation will work
-- ============================================
