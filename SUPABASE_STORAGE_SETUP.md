# 🗄️ Supabase Storage Setup - Avatar Upload

## ❌ Current Error
```
StorageException: Bucket not found, statusCode: 404
```

## ✅ Solution: Create Storage Bucket

### Step 1: Open Supabase Dashboard
1. Go to https://supabase.com
2. Open your **devchat** project
3. Click **Storage** in left sidebar

### Step 2: Create Avatars Bucket
1. Click **New bucket** button
2. Fill in details:
   ```
   Name: avatars
   Public bucket: ✅ YES (checked)
   File size limit: 5MB
   Allowed MIME types: image/*
   ```
3. Click **Create bucket**

### Step 3: Set Bucket Policies (Optional but Recommended)

Run this SQL in **SQL Editor**:

```sql
-- Allow authenticated users to upload their own avatars
CREATE POLICY "Users can upload own avatar"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow public read access to avatars
CREATE POLICY "Public avatar access"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Allow users to update their own avatars
CREATE POLICY "Users can update own avatar"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to delete their own avatars
CREATE POLICY "Users can delete own avatar"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
```

### Step 4: Verify Bucket Created

1. Go to **Storage** → **avatars**
2. You should see empty bucket
3. Try uploading a test file manually

---

## 🧪 Test Avatar Upload

### After creating bucket:

1. Open app
2. Go to **Profile** → **Edit Profile**
3. Click camera icon
4. Select image from Camera/Gallery
5. Click **Save**
6. Check console logs:
   ```
   📸 Uploading avatar image...
   📤 Uploading to: avatars/userId_timestamp.jpg
   ✅ Avatar uploaded successfully: https://...
   ✅ User profile updated successfully
   ```

### Verify in Supabase:

1. **Storage** → **avatars** bucket
   - Should see uploaded image file
2. **Table Editor** → **users** table
   - Check `avatar_url` column has URL
3. **App Profile Screen**
   - Avatar should display

---

## 📁 Bucket Structure

```
avatars/
├── userId1_1234567890.jpg
├── userId2_1234567891.jpg
└── userId3_1234567892.jpg
```

Each file is named: `{userId}_{timestamp}.jpg`

---

## 🔒 Security Notes

### Public Bucket:
- ✅ Anyone can view avatars (good for profile pictures)
- ✅ Only authenticated users can upload
- ✅ Users can only manage their own avatars

### File Naming:
- Uses `userId` to organize files
- Timestamp prevents filename conflicts
- Easy to identify and manage

---

## 🚨 Troubleshooting

### Error: "Bucket not found"
**Solution:** Create the `avatars` bucket (see Step 2)

### Error: "Permission denied"
**Solution:** Make bucket public or add RLS policies (see Step 3)

### Error: "File too large"
**Solution:** 
- Reduce image size
- Or increase bucket file size limit
- Or add image compression in app

### Avatar not showing after upload
**Check:**
1. Bucket is public
2. `avatar_url` saved in database
3. URL is accessible (open in browser)
4. App is refreshing profile data

---

## ✅ Success Checklist

- [ ] `avatars` bucket created
- [ ] Bucket is public
- [ ] RLS policies added (optional)
- [ ] Test upload works
- [ ] Avatar shows in app
- [ ] Avatar URL in database

---

## 🎉 Done!

After creating the bucket, avatar upload will work perfectly! 🚀
