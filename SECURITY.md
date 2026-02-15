# Security Policy & Credential Management

## Secure Development
This project follows strict security practices to prevent credential leaks.

### 1. Hardcoded Secrets
- **NEVER** commit API keys, service account JSONs, or passwords to git.
- Use `.env` files for local development (which are gitignored).
- Use `lib/core/util/logger.dart` (`Log` class) instead of `print` to prevent leaking data in release builds.

### 2. Environment Variables
Local development uses `flutter_dotenv`.
Create a `.env` file in the root directory (see `.env.example`):
```bash
FIREBASE_PROJECT_ID=your-project-id
STORAGE_BUCKET=your-bucket-url
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-key
```

### 3. CI/CD (GitHub Actions)
Production builds inject secrets via `--dart-define`.
Go to **Settings > Secrets and variables > Actions** in your GitHub repository and add:

- `FIREBASE_PROJECT_ID`
- `STORAGE_BUCKET`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `KEYSTORE_PASSWORD` (if using signing)
- `KEY_PASSWORD` (if using signing)
- `KEY_ALIAS` (if using signing)

### 4. Git History
If you accidentally commit a secret:
1. Revoke the secret immediately.
2. Rewrite git history using `git filter-branch` or BFG Repo-Cleaner.
3. Force push the clean history.

### 5. Reporting Vulnerabilities
Please report security vulnerabilities to the project maintainers privately.
