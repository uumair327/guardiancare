# Firebase ↔ Supabase Data Sync

This module provides two mechanisms to keep Firebase and Supabase data in sync:

## Architecture

```
Phase 1: Migration Script (One-time)          Phase 2: Sync Adapter (Ongoing)
┌──────────────────────────────────┐           ┌──────────────────────────────────┐
│  sync_firebase_to_supabase.js    │           │  SyncDataStoreAdapter (Dart)     │
│                                  │           │                                  │
│  Firebase ──read──→ Transform    │           │       App Write Operation        │
│                     │            │           │              │                   │
│                     └──write──→  │           │    ┌─────────┴─────────┐         │
│                       Supabase   │           │    ▼                   ▼         │
│                                  │           │  Firebase           Supabase     │
│  Handles:                        │           │  (primary)          (secondary)  │
│  • All 13 collections            │           │  ↑ reads            async write  │
│  • Subcollections (comments)     │           │  ↑ streams          fire-forget  │
│  • Timestamp conversion          │           │  └─── source of truth            │
│  • Batch upserts                 │           │                                  │
└──────────────────────────────────┘           └──────────────────────────────────┘
```

---

## Phase 1: One-Time Migration

### Prerequisites

```bash
npm install firebase-admin @supabase/supabase-js
```

Ensure `serviceAccountKey.json` is in the project root.

### Run

```powershell
# Set environment variables
$env:SUPABASE_URL="https://your-project.supabase.co"
$env:SUPABASE_SERVICE_KEY="your-service-role-key"

# Dry run first (preview without writing)
node sync_firebase_to_supabase.js --dry-run

# Full sync
node sync_firebase_to_supabase.js

# Sync a specific collection
node sync_firebase_to_supabase.js --collection=users

# Force overwrite existing data
node sync_firebase_to_supabase.js --force
```

### Collections Synced

| Firebase Collection | Supabase Table | Notes |
|---|---|---|
| `users` | `users` | User profiles |
| `consents` | `consents` | Parental consent forms |
| `forum` | `forum` | Forum posts |
| `forum/{id}/comments` | `forum_comments` | Subcollection → flat table with `forumId` FK |
| `carousel_items` | `carousel_items` | Homepage carousel |
| `learn` | `learn` | Learning categories |
| `videos` | `videos` | Educational videos |
| `resources` | `resources` | External resources |
| `recommendations` | `recommendations` | Personalized recommendations |
| `notifications` | `notifications` | User notifications |
| `settings` | `settings` | App configuration |
| `quizzes` | `quizzes` | Quiz metadata |
| `quiz_questions` | `quiz_questions` | Quiz questions |

### Important

> Before running, ensure the Supabase schema is created:
> ```bash
> # Run supabase_schema.sql in your Supabase Dashboard → SQL Editor
> ```

---

## Phase 2: Dual-Write Sync Adapter

### Enable Sync Mode

```bash
# Via dart-define flag
flutter run --dart-define=BACKEND=sync

# Or in launch.json
{
  "configurations": [{
    "args": ["--dart-define=BACKEND=sync"]
  }]
}
```

### How It Works

| Operation | Primary (Firebase) | Secondary (Supabase) |
|---|---|---|
| **Read** (get, query, getAll) | ✅ Source of truth | ❌ Not read |
| **Stream** (streamDocument, etc.) | ✅ Source of truth | ❌ Not streamed |
| **Write** (add, set, update) | ✅ Synchronous | ✅ Async (fire-and-forget) |
| **Delete** | ✅ Synchronous | ✅ Async (fire-and-forget) |
| **Batch/Transaction** | ✅ Synchronous | ✅ Async (batch only) |
| **Field ops** (increment, etc.) | ✅ Synchronous | ✅ Async |

### Key Design Decisions

1. **Primary-first**: All reads come from Firebase (source of truth)
2. **Fire-and-forget secondary writes**: Supabase write failures are logged but never block the user
3. **Auth stays single-backend**: Authentication can't be dual-written (uses Firebase in sync mode)
4. **Storage stays single-backend**: File storage uses Firebase in sync mode

### File Structure

```
lib/core/backend/
├── adapters/
│   ├── firebase/        # Firebase adapters (existing)
│   ├── supabase/        # Supabase adapters (existing)
│   └── sync/            # NEW: Sync adapter
│       └── sync_data_store_adapter.dart
├── backend.dart         # Updated: exports sync adapter
├── backend_factory.dart # Updated: handles BackendProvider.sync
└── config/
    └── backend_config.dart  # Updated: recognizes 'sync' provider
```

---

## Rollback Strategy

If issues arise, simply switch back:

```bash
# Back to Firebase only
flutter run --dart-define=BACKEND=firebase

# Or to Supabase only
flutter run --dart-define=BACKEND=supabase
```

No code changes needed — the factory pattern handles everything.
