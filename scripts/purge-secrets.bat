@echo off
REM ============================================================
REM Firebase Credentials Purge Script for GuardianCare
REM ============================================================
REM 
REM This script removes sensitive Firebase files from Git history
REM using git-filter-repo (modern replacement for BFG).
REM
REM PREREQUISITES:
REM 1. Install Python: https://www.python.org/downloads/
REM 2. Install git-filter-repo: pip install git-filter-repo
REM
REM WARNING: This REWRITES Git history! 
REM - All collaborators must re-clone after this
REM - Force push is required
REM ============================================================

echo.
echo ============================================================
echo Firebase Credentials Purge Script
echo ============================================================
echo.
echo This will PERMANENTLY remove secrets from Git history.
echo After running, you must force push and all collaborators
echo must delete their local clones and re-clone.
echo.
pause

REM Step 1: Create a backup
echo.
echo [Step 1/5] Creating backup...
git clone --mirror . ..\guardiancare-backup-%date:~-4,4%%date:~-7,2%%date:~-10,2%
if %ERRORLEVEL% NEQ 0 (
    echo Failed to create backup. Aborting.
    exit /b 1
)

REM Step 2: Remove google-services.json from history
echo.
echo [Step 2/5] Removing google-services.json from history...
git filter-repo --invert-paths --path android/app/google-services.json --force

REM Step 3: Remove firebase_options.dart from history
echo.
echo [Step 3/5] Removing firebase_options.dart from history...
git filter-repo --invert-paths --path lib/firebase_options.dart --force

REM Step 4: Remove any .keystore files from history
echo.
echo [Step 4/5] Removing keystore files from history...
git filter-repo --invert-paths --path-glob "*.keystore" --force
git filter-repo --invert-paths --path-glob "*.jks" --force

REM Step 5: Remove iOS config from history
echo.
echo [Step 5/5] Removing iOS config from history...
git filter-repo --invert-paths --path ios/Runner/GoogleService-Info.plist --force
git filter-repo --invert-paths --path macos/Runner/GoogleService-Info.plist --force

echo.
echo ============================================================
echo Cleanup Complete!
echo ============================================================
echo.
echo NEXT STEPS:
echo 1. Add remote back: git remote add origin https://github.com/uumair327/guardiancare.git
echo 2. Force push: git push origin main --force
echo 3. Tell all collaborators to delete and re-clone the repo
echo.
echo IMPORTANT: You MUST now create a NEW Firebase project
echo as the old credentials are still compromised.
echo.
pause
