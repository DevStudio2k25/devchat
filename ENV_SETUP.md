# 🔐 DevChat - Environment Configuration Guide

> **Last Updated**: October 1, 2025  
> **Status**: Required for Development

---

## 📋 Overview

This guide explains how to set up environment variables for the DevChat application. Environment variables store sensitive configuration data like API keys and database credentials.

---

## 🚀 Quick Setup

### Step 1: Copy the Example File

```bash
# Copy .env.example to create your local .env file
cp .env.example .env
```

### Step 2: Edit .env with Your Credentials

Open `.env` file and replace the placeholder values:

```env
# Supabase Configuration
SUPABASE_URL=https://plnoxgimfhyyvzokbita.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# OneSignal Configuration
ONESIGNAL_APP_ID=27e1057f-88cf-4a4f-adab-f5fbd0546579
ONESIGNAL_REST_API_KEY=os_v2_app_e7qqk74iz5fe7lnl6x55avdfphokpmg4...

# Environment
ENVIRONMENT=development
```

### Step 3: Verify Setup

Run the app and check console for:
```
✅ All required environment variables are set
🔧 Environment Configuration:
   Environment: development
   Supabase URL: ✓ Set
   Supabase Key: ✓ Set
   OneSignal App ID: ✓ Set
   OneSignal API Key: ✓ Set
```

---

## 📝 Environment Variables Reference

### Required Variables

| Variable | Description | Where to Get |
|----------|-------------|--------------|
| `SUPABASE_URL` | Your Supabase project URL | Supabase Dashboard > Settings > API |
| `SUPABASE_ANON_KEY` | Supabase anonymous/public key | Supabase Dashboard > Settings > API |
| `ONESIGNAL_APP_ID` | OneSignal application ID | OneSignal Dashboard > Settings > Keys & IDs |
| `ONESIGNAL_REST_API_KEY` | OneSignal REST API key | OneSignal Dashboard > Settings > Keys & IDs |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ENVIRONMENT` | Current environment (development/staging/production) | development |

---

## 🔑 How to Get Your Credentials

### Supabase Credentials

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Navigate to **Settings** > **API**
4. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`

### OneSignal Credentials

1. Go to [OneSignal Dashboard](https://dashboard.onesignal.com)
2. Select your app
3. Navigate to **Settings** > **Keys & IDs**
4. Copy:
   - **OneSignal App ID** → `ONESIGNAL_APP_ID`
   - **REST API Key** → `ONESIGNAL_REST_API_KEY`

---

## 🔒 Security Best Practices

### ✅ DO:
- ✅ Keep `.env` file in `.gitignore` (already configured)
- ✅ Use `.env.example` as a template (no real keys)
- ✅ Store production keys in secure environment (CI/CD secrets)
- ✅ Rotate keys regularly
- ✅ Use different keys for development and production

### ❌ DON'T:
- ❌ **NEVER** commit `.env` file to Git
- ❌ **NEVER** share API keys publicly
- ❌ **NEVER** put real keys in `.env.example`
- ❌ **NEVER** hardcode keys in source code
- ❌ **NEVER** use production keys in development

---

## 🌍 Multiple Environments

### Development (.env)
```env
ENVIRONMENT=development
SUPABASE_URL=https://dev-project.supabase.co
# ... dev credentials
```

### Staging (.env.staging)
```env
ENVIRONMENT=staging
SUPABASE_URL=https://staging-project.supabase.co
# ... staging credentials
```

### Production (.env.production)
```env
ENVIRONMENT=production
SUPABASE_URL=https://prod-project.supabase.co
# ... production credentials
```

---

## 💻 Usage in Code

### Initialize in main.dart

```dart
import 'package:flutter/material.dart';
import 'config/env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await EnvConfig.initialize();
  
  // Validate configuration
  if (!EnvConfig.validate()) {
    throw Exception('Environment configuration is invalid');
  }
  
  // Print config in development
  EnvConfig.printConfig();
  
  runApp(MyApp());
}
```

### Access Variables

```dart
import 'package:devchat/config/env_config.dart';

// Get Supabase URL
final supabaseUrl = EnvConfig.supabaseUrl;

// Get OneSignal App ID
final oneSignalAppId = EnvConfig.oneSignalAppId;

// Check environment
if (EnvConfig.isDevelopment) {
  print('Running in development mode');
}
```

---

## 🐛 Troubleshooting

### Issue: "Missing required environment variable"

**Solution**:
1. Check if `.env` file exists
2. Verify all required variables are set
3. Restart the app after editing `.env`

### Issue: "Unable to load asset: .env"

**Solution**:
1. Ensure `.env` is listed in `pubspec.yaml` assets
2. Run `flutter clean` and `flutter pub get`
3. Rebuild the app

### Issue: Variables are empty

**Solution**:
1. Check `.env` file format (no quotes needed)
2. Ensure no extra spaces around `=`
3. Verify file is saved

---

## 📦 CI/CD Configuration

### GitHub Actions

```yaml
env:
  SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
  ONESIGNAL_APP_ID: ${{ secrets.ONESIGNAL_APP_ID }}
  ONESIGNAL_REST_API_KEY: ${{ secrets.ONESIGNAL_REST_API_KEY }}
```

### GitLab CI

```yaml
variables:
  SUPABASE_URL: $SUPABASE_URL
  SUPABASE_ANON_KEY: $SUPABASE_ANON_KEY
  ONESIGNAL_APP_ID: $ONESIGNAL_APP_ID
  ONESIGNAL_REST_API_KEY: $ONESIGNAL_REST_API_KEY
```

---

## ✅ Checklist

Before running the app:

- [ ] `.env` file created from `.env.example`
- [ ] All required variables are set
- [ ] Supabase credentials are correct
- [ ] OneSignal credentials are correct
- [ ] `.env` is in `.gitignore`
- [ ] `.env.example` has no real keys
- [ ] Environment is set correctly

---

## 📞 Need Help?

If you're having issues:
1. Check this guide thoroughly
2. Verify credentials in respective dashboards
3. Check console logs for specific errors
4. Review `docs/SETUP.md` for detailed setup

---

**Document Version**: 1.0  
**Last Updated**: October 1, 2025
