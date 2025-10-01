# 🔧 Signup Error Fix - Database Trigger Setup

## ❌ Problem
Getting error during signup:
```
AuthRetryableFetchException: Database error saving new user
```

## ✅ Solution
The issue is that Supabase needs a **database trigger** to automatically create user profiles when someone signs up.

---

## 📝 Steps to Fix

### Step 1: Open Supabase Dashboard
1. Go to https://supabase.com
2. Open your **devchat** project
3. Click on **SQL Editor** in the left sidebar

### Step 2: Run the Trigger SQL

Copy and paste this SQL code into the SQL Editor:

```sql
-- Create a function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, username, display_name, status, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    'online',
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a trigger to automatically create user profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
```

### Step 3: Execute the SQL
1. Click the **Run** button (or press Ctrl+Enter)
2. Wait for "Success" message
3. You should see: ✅ **Success. No rows returned**

### Step 4: Verify the Trigger
Run this query to check if trigger was created:

```sql
SELECT 
  trigger_name, 
  event_manipulation, 
  event_object_table 
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';
```

You should see:
```
trigger_name: on_auth_user_created
event_manipulation: INSERT
event_object_table: users
```

---

## 🧪 Test the Fix

### Step 1: Try Signup Again
1. Open your app
2. Go to Signup screen
3. Enter:
   - Email: test@example.com
   - Username: testuser
   - Password: Test@123
4. Click **Sign Up**

### Step 2: Check Database
1. Go to **Table Editor** in Supabase
2. Open **users** table
3. You should see the new user with:
   - ✅ id (UUID)
   - ✅ email
   - ✅ username
   - ✅ display_name
   - ✅ status: "online"
   - ✅ created_at
   - ✅ updated_at

---

## 🔍 How It Works

### Before (❌ Error):
```
User signs up → Supabase Auth creates user → App tries to create profile → RLS blocks it → ERROR
```

### After (✅ Working):
```
User signs up → Supabase Auth creates user → Trigger automatically creates profile → SUCCESS
```

### The Trigger:
- **Listens**: When a new user is inserted in `auth.users`
- **Action**: Automatically inserts a profile in `public.users`
- **Data**: Uses email and username from signup metadata
- **Security**: Runs with SECURITY DEFINER (bypasses RLS)

---

## 📊 What Changed in Code

### auth_service.dart
**Before:**
```dart
// Manually tried to insert user profile
await _supabase.from('users').insert({...});
```

**After:**
```dart
// Trigger handles it automatically
print('ℹ️ User profile will be created automatically by database trigger');
```

---

## ✅ Benefits

1. **Automatic**: No manual profile creation needed
2. **Reliable**: Database-level guarantee
3. **Secure**: Bypasses RLS restrictions
4. **Consistent**: Every signup creates a profile
5. **Clean**: No extra code in the app

---

## 🚨 Troubleshooting

### If signup still fails:

#### 1. Check if trigger exists:
```sql
SELECT * FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';
```

#### 2. Check if function exists:
```sql
SELECT proname FROM pg_proc 
WHERE proname = 'handle_new_user';
```

#### 3. Check users table structure:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users';
```

#### 4. Test trigger manually:
```sql
-- This should create a profile automatically
INSERT INTO auth.users (id, email) 
VALUES (gen_random_uuid(), 'test@test.com');
```

#### 5. Check RLS policies:
```sql
SELECT * FROM pg_policies WHERE tablename = 'users';
```

---

## 📝 Alternative: Manual Profile Creation

If you can't use triggers, enable this RLS policy:

```sql
-- Allow users to insert their own profile
CREATE POLICY "Users can insert own profile"
ON public.users
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);
```

Then uncomment the manual insert code in `auth_service.dart`.

---

## ✅ Success!

After running the SQL trigger, signup should work perfectly! 🎉

The error **"Database error saving new user"** will be gone and users can signup successfully.
