---
description: Migrate to new Firebase project after security incident
---

# Firebase Project Migration Workflow

## Prerequisites
- New Firebase project created at https://console.firebase.google.com
- Firebase CLI installed: `npm install -g firebase-tools`
- FlutterFire CLI installed: `flutter pub global activate flutterfire_cli`

## Phase 1: Create New Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Create Project"
3. Name it (e.g., `guardiancare-v2`)
4. Enable Google Analytics
5. Wait for project creation

## Phase 2: Enable Firebase Services

In the new Firebase project:

1. **Authentication**:
   - Go to Build > Authentication
   - Click "Get Started"
   - Enable "Google" provider
   - Configure OAuth consent screen

2. **Cloud Firestore**:
   - Go to Build > Firestore Database
   - Click "Create Database"
   - Choose region (asia-southeast1 for consistency)
   - Start in production mode

3. **Firebase Storage** (if needed):
   - Go to Build > Storage
   - Click "Get Started"

## Phase 3: Reconfigure Flutter App

// turbo
```bash
cd "c:\Users\uumai\Downloads\Telegram Desktop\guardiancare"
```

1. Delete old Firebase config:
```bash
del lib\firebase_options.dart
del android\app\google-services.json
```

2. Login to Firebase:
```bash
firebase login
```

3. Reconfigure FlutterFire (interactive):
```bash
flutterfire configure
```
- Select your NEW project
- Enable: android, ios, macos, web, windows

## Phase 4: Update Android SHA Keys

1. Get your SHA-1 keys:
// turbo
```bash
cd android
.\gradlew signingReport
```

2. In Firebase Console > Project Settings > Your apps > Android app
3. Add all SHA-1 fingerprints

## Phase 5: Data Migration

### Export from Old Project (if accessible):

If you have Google Cloud access:
```bash
gcloud config set project guardiancare-a210f
gcloud firestore export gs://guardiancare-a210f.appspot.com/backup-YYYYMMDD
```

### Import to New Project:
```bash
gcloud config set project YOUR_NEW_PROJECT_ID
gcloud firestore import gs://YOUR_NEW_BUCKET/backup-YYYYMMDD
```

### For User Migration:
See `/scripts/migrate-users.js` for user migration script

## Phase 6: Security Hardening

1. **Check Git History for Secrets**:
// turbo
```bash
git log --all --full-history -- "**/google-services.json"
git log --all --full-history -- "**/firebase_options.dart"
```

2. **If secrets found, purge with BFG**:
```bash
# Download BFG from https://rtyley.github.io/bfg-repo-cleaner/
java -jar bfg.jar --delete-files google-services.json
java -jar bfg.jar --delete-files firebase_options.dart
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

3. **Verify .gitignore is active**:
Ensure these are listed:
- `**/google-services.json`
- `**/GoogleService-Info.plist`
- `firebase_options.dart`
- `*.keystore`
- `*.jks`

## Phase 7: Update Firestore Security Rules

Deploy secure rules to new project:
```bash
firebase deploy --only firestore:rules
```

## Phase 8: Test the App

// turbo
```bash
flutter clean
flutter pub get
flutter run
```

Verify:
- [ ] Google Sign-In works
- [ ] User profile loads
- [ ] Firestore data accessible
- [ ] Forum posts load
- [ ] Quiz functionality works
- [ ] No errors in console

## Post-Migration Checklist

- [ ] New Firebase project created
- [ ] All services enabled
- [ ] FlutterFire reconfigured
- [ ] SHA keys added to Firebase
- [ ] Data migrated (if accessible)
- [ ] Users notified to re-login
- [ ] Git history cleaned of secrets
- [ ] Security rules deployed
- [ ] App tested and working
- [ ] Old project deleted (after confirming migration)
