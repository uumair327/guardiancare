# go_router Migration Plan

## Status: In Progress

This document outlines the migration from Navigator to go_router following clean architecture principles.

## Completed Steps

### ✅ Step 1: Added go_router dependency
- Added `go_router: ^14.6.2` to pubspec.yaml
- Ran `flutter pub get`

### ✅ Step 2: Created router configuration
- Created `lib/core/routing/app_router.dart`
- Defined all routes with proper authentication redirect logic
- Routes include:
  - `/login` - Login page
  - `/signup` - Signup page
  - `/password-reset` - Password reset
  - `/` - Main app with bottom navigation (Pages widget)
  - `/quiz` - Quiz selection
  - `/quiz-questions` - Quiz questions (with extra data)
  - `/video` - Video learning page
  - `/emergency` - Emergency contacts
  - `/account` - User account/profile
  - `/forum/:id` - Forum detail (with path parameter)
  - `/webview` - WebView (with extra data)
  - `/video-player` - Video player (with extra data)

### ✅ Step 3: Updated main.dart
- Changed from `MaterialApp` to `MaterialApp.router`
- Removed StreamBuilder and manual route handling
- Router now handles authentication redirects automatically

## Remaining Steps

### Step 4: Update all Navigator.push calls

Files that need updating (11 files):

1. **lib/features/quiz/presentation/pages/quiz_page.dart**
   - Line 119: Navigate to quiz questions
   - Change: `Navigator.push(context, MaterialPageRoute(...))` 
   - To: `context.push('/quiz-questions', extra: questions)`

2. **lib/features/learn/presentation/pages/video_page.dart**
   - Line 176: Navigate to video player
   - Change: `Navigator.push(context, MaterialPageRoute(...))`
   - To: `context.push('/video-player', extra: videoUrl)`

3. **lib/features/profile/presentation/pages/account_page.dart**
   - Line 152: Navigate to emergency
   - Change: `Navigator.push(context, MaterialPageRoute(...))`
   - To: `context.push('/emergency')`

4. **lib/features/home/presentation/pages/home_page.dart**
   - Lines 105, 117, 129, 152, 167: Multiple navigations
   - Quiz: `context.push('/quiz')`
   - Learn: `context.push('/video')`
   - Emergency: `context.push('/emergency')`
   - Profile: `context.push('/account')`
   - Website: `context.push('/webview', extra: url)`

5. **lib/features/explore/presentation/pages/explore_page.dart**
   - Line 143: Navigate to quiz
   - Change: `Navigator.push(context, MaterialPageRoute(...))`
   - To: `context.push('/quiz')`

6. **lib/features/forum/presentation/widgets/forum_list_item.dart**
   - Line 14: Navigate to forum detail
   - Change: `Navigator.push(context, MaterialPageRoute(...))`
   - To: `context.push('/forum/${forumId}', extra: forumData)`

7. **lib/features/home/presentation/widgets/home_carousel_widget.dart**
   - Lines 43, 52: Navigate to custom content or webview
   - Custom: `context.push('/webview', extra: url)` (or create custom route)
   - Web: `context.push('/webview', extra: url)`

8. **lib/features/home/presentation/widgets/simple_carousel.dart**
   - Lines 50, 59: Navigate to custom content or webview
   - Same as above

9. **lib/core/widgets/content_card.dart**
   - Line 20: Navigate to video player
   - Change: `Navigator.push(context, MaterialPageRoute(...))`
   - To: `context.push('/video-player', extra: videoUrl)`

### Step 5: Update Navigator.pop calls

Search for `Navigator.pop` and replace with `context.pop()` where appropriate.

### Step 6: Update pushNamedAndRemoveUntil calls

Search for `pushNamedAndRemoveUntil` and replace with `context.go('/')` for logout scenarios.

### Step 7: Remove old routing

- Delete or deprecate `lib/core/routing/pages.dart` routes map
- Remove named routes from main.dart (already done)

### Step 8: Testing

Test all navigation flows:
- [ ] Login → Home
- [ ] Logout → Login
- [ ] Home → Quiz → Questions → Back
- [ ] Home → Learn → Video Player → Back
- [ ] Home → Emergency → Back
- [ ] Home → Profile/Account → Back
- [ ] Explore → Quiz → Back
- [ ] Forum → Detail → Back
- [ ] Deep linking (if applicable)
- [ ] Back button behavior
- [ ] Authentication redirects

## Benefits of go_router

1. **Type-safe navigation**: Compile-time route checking
2. **Deep linking**: Built-in support for web URLs
3. **Declarative routing**: Easier to understand and maintain
4. **Authentication**: Built-in redirect logic
5. **Clean architecture**: Router in core layer, separate from features
6. **Better testing**: Easier to test navigation logic

## Migration Strategy

To minimize risk:
1. ✅ Add go_router alongside existing navigation
2. ✅ Create router configuration
3. ✅ Update main.dart
4. ⏳ Update files one by one
5. ⏳ Test each change
6. ⏳ Remove old navigation code
7. ⏳ Final integration testing

## Notes

- The Pages widget (bottom navigation) remains unchanged
- Authentication redirect logic moved to router
- Extra data passed via `extra` parameter
- Path parameters used for IDs (e.g., `/forum/:id`)

---

**Started**: November 23, 2025
**Status**: Router configured, main.dart updated, navigation calls need updating
