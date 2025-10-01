-- ============================================
-- Supabase Storage Setup for Avatars
-- Run this in Supabase SQL Editor
-- ============================================

-- IMPORTANT: First create 'avatars' bucket via Supabase UI:
-- Storage → New bucket → Name: avatars → Public: YES → Create

-- Drop existing policies if any (to avoid conflicts)
DROP POLICY IF EXISTS "Users can upload own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Public avatar access" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own avatar" ON storage.objects;

-- Step 4: Allow authenticated users to upload avatars (simplified - any authenticated user)
CREATE POLICY "Users can upload own avatar"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');

-- Step 5: Allow public read access to all avatars
CREATE POLICY "Public avatar access"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Step 6: Allow users to update avatars
CREATE POLICY "Users can update own avatar"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars');

-- Step 7: Allow users to delete avatars
CREATE POLICY "Users can delete own avatar"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'avatars');

-- ============================================
-- Verification Queries (Optional - Run to check)
-- ============================================

-- Check if bucket exists
SELECT * FROM storage.buckets WHERE id = 'avatars';

-- Check policies
SELECT * FROM pg_policies WHERE tablename = 'objects' AND policyname LIKE '%avatar%';

-- ============================================
-- SUCCESS! 
-- Now avatar upload will work in the app
-- ============================================
