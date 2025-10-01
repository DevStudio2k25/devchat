# 🗄️ Supabase Database Setup

## 📋 Quick Setup Guide

### Step 1: Access Supabase SQL Editor

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project: **plnoxgimfhyyvzokbita**
3. Click on **SQL Editor** in the left sidebar

### Step 2: Run the Migration

1. Click **New Query**
2. Copy the entire content from `migrations/001_initial_schema.sql`
3. Paste it into the SQL Editor
4. Click **Run** button (or press Ctrl+Enter)

### Step 3: Verify Tables Created

1. Go to **Table Editor** in the left sidebar
2. You should see these tables:
   - ✅ users
   - ✅ chats
   - ✅ chat_members
   - ✅ messages
   - ✅ reactions
   - ✅ files
   - ✅ presence
   - ✅ notifications

### Step 4: Enable Realtime (Important!)

1. Go to **Database** > **Replication**
2. Enable replication for these tables:
   - ✅ messages
   - ✅ chats
   - ✅ presence
   - ✅ reactions
   - ✅ chat_members

## 📊 Database Schema Overview

### Tables Created:

| Table | Purpose | Rows (Initial) |
|-------|---------|----------------|
| **users** | User profiles | 0 |
| **chats** | Chat rooms (1-to-1 & groups) | 0 |
| **chat_members** | Chat participants | 0 |
| **messages** | All messages | 0 |
| **reactions** | Message reactions | 0 |
| **files** | File metadata | 0 |
| **presence** | Online status | 0 |
| **notifications** | Notification history | 0 |

### Features Enabled:

✅ **Row-Level Security (RLS)** - All tables secured  
✅ **Indexes** - Optimized for performance  
✅ **Triggers** - Auto-update timestamps  
✅ **Functions** - Business logic  
✅ **Full-text Search** - Message search capability  
✅ **Foreign Keys** - Data integrity  

## 🔒 Security

All tables have Row-Level Security (RLS) enabled with policies:
- Users can only see data they have access to
- Admins have special permissions in groups
- Messages are only visible to chat members

## 🧪 Test the Setup

Run this query to verify everything is working:

```sql
-- Check if all tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

Expected output: 8 tables

## 📝 Next Steps

After running the migration:

1. ✅ Verify all tables are created
2. ✅ Enable Realtime replication
3. ✅ Test RLS policies (try inserting test data)
4. ✅ Configure Storage buckets (for file uploads)
5. ✅ Update Flutter app to use the schema

## 🔗 Useful Links

- **Your Project**: https://supabase.com/dashboard/project/plnoxgimfhyyvzokbita
- **SQL Editor**: https://supabase.com/dashboard/project/plnoxgimfhyyvzokbita/sql
- **Table Editor**: https://supabase.com/dashboard/project/plnoxgimfhyyvzokbita/editor
- **Database**: https://supabase.com/dashboard/project/plnoxgimfhyyvzokbita/database/tables

## ⚠️ Important Notes

- **Backup**: Always backup before running migrations
- **Testing**: Test in development first
- **RLS**: Don't disable RLS in production
- **Indexes**: Monitor query performance

## 🐛 Troubleshooting

### Error: "relation already exists"
- Tables already created. Drop them first or use a new migration number.

### Error: "permission denied"
- Check if you're using the correct Supabase project
- Verify you have admin access

### Error: "syntax error"
- Copy the entire SQL file content
- Make sure no characters are missing

## 📞 Need Help?

Check the detailed schema documentation in:
- `docs/DATABASE_SCHEMA.md`
- `docs/SUPABASE_SETUP.md`
