# 🐛 Debug Recommendations - Step by Step

## Current Status: Enhanced Debugging Added

---

## 🔍 What to Check

### Step 1: Hot Restart the App
```bash
# In your terminal where flutter run is active
Press: R
```

### Step 2: Complete a Quiz
1. Open app
2. Go to Quiz page
3. Select ANY quiz
4. Answer all questions
5. Complete the quiz

### Step 3: Watch Console Logs Carefully

You should see these logs in order:

```
=== QUIZ COMPLETION STARTED ===
Question 0 category: [category value or empty]
Question 1 category: [category value or empty]
...
Collected categories: [list of categories]
User UID: 05D2jkyUDJMNlI6id2fudSUqXNP2
Quiz result saved to Firestore
Calling RecommendationService.generateRecommendations with: [categories]
Starting recommendation generation for categories: [categories]
Clearing old recommendations for user: 05D2jky...
Cleared X old recommendations
Processing category: [category name]
Gemini generated X search terms for [category]: [terms]
Fetching YouTube video for term: [term]
Saved recommendation: [video title]
Successfully generated recommendations for X categories
=== QUIZ COMPLETION FINISHED ===
```

---

## 🚨 Common Issues & Solutions

### Issue 1: No Console Logs at All
**Problem**: Quiz completion not triggering
**Check**:
- Did you complete ALL questions?
- Did you click the "Finish" button?
- Are you on the completion screen?

### Issue 2: "No categories found"
**Problem**: Quiz questions don't have category field
**Solution**: The code now uses quiz name as fallback
**Expected Log**:
```
No categories found, using quiz name as category: Child Safety Quiz
```

### Issue 3: "No user logged in"
**Problem**: User not authenticated
**Solution**: Make sure you're logged in with Firebase Auth
**Check**: Look for "User UID: ..." in logs

### Issue 4: "Error generating recommendations"
**Possible Causes**:
1. **Gemini API Key Invalid**
   - Check `lib/src/constants/keys.dart`
   - Verify: `kGeminiApiKey = "AIzaSyCJz_lIoAxc0ZY1Gk3jBgnLZTKeTbDn6B4"`

2. **YouTube API Key Invalid**
   - Check `lib/src/constants/keys.dart`
   - Verify: `kYoutubeApiKey = "AIzaSyAIuTQTk0_aEawCBLNX-YZwB6qEuFuHnGg"`

3. **Network Issues**
   - Check internet connection
   - Check if APIs are accessible

4. **Firestore Permission Denied**
   - Check Firestore security rules
   - Ensure write permission for 'recommendations' collection

---

## 📊 What Each Log Means

### `=== QUIZ COMPLETION STARTED ===`
✅ Quiz completion function called successfully

### `Question X category: [value]`
Shows category for each question
- If empty: Questions don't have categories
- If has value: Categories will be used

### `Collected categories: [...]`
Shows final list of categories extracted
- If empty: Will use quiz name or defaults

### `User UID: [uid]`
Shows current user ID
- If missing: User not logged in (ERROR)

### `Quiz result saved to Firestore`
✅ Quiz result successfully saved

### `Calling RecommendationService.generateRecommendations`
✅ About to call recommendation service

### `Starting recommendation generation`
✅ Recommendation service started

### `Gemini generated X search terms`
✅ Gemini AI responded successfully

### `Saved recommendation: [title]`
✅ Video saved to Firestore

### `=== QUIZ COMPLETION FINISHED ===`
✅ Everything completed successfully

---

## 🔧 Manual Testing

### Test 1: Check Firestore Directly

1. Open Firebase Console
2. Go to Firestore Database
3. Check `quiz_results` collection
   - Should have new document with your UID
   - Should have categories array

4. Check `recommendations` collection
   - Should have documents with 'UID' field
   - Should match your user UID
   - Should have real YouTube video URLs

### Test 2: Check API Keys

```dart
// In lib/src/constants/keys.dart
const kGeminiApiKey = "AIzaSyCJz_lIoAxc0ZY1Gk3jBgnLZTKeTbDn6B4";
const kYoutubeApiKey = "AIzaSyAIuTQTk0_aEawCBLNX-YZwB6qEuFuHnGg";
```

### Test 3: Test Gemini API Manually

Try this in a test file:
```dart
import 'package:flutter_gemini/flutter_gemini.dart';

void testGemini() async {
  Gemini.init(apiKey: "AIzaSyCJz_lIoAxc0ZY1Gk3jBgnLZTKeTbDn6B4");
  final gemini = Gemini.instance;
  final response = await gemini.text("Say hello");
  print(response?.output);
}
```

---

## 📝 Copy This and Share Console Output

After completing a quiz, copy ALL console output and share it. Look for:

```
=== QUIZ COMPLETION STARTED ===
[... all logs ...]
=== QUIZ COMPLETION FINISHED ===
```

Also check for any ERROR messages:
```
ERROR: [message]
Error generating recommendations: [details]
Error processing category: [details]
```

---

## ✅ Success Indicators

You'll know it's working when you see:

1. ✅ `=== QUIZ COMPLETION STARTED ===`
2. ✅ `User UID: [your-uid]`
3. ✅ `Quiz result saved to Firestore`
4. ✅ `Starting recommendation generation`
5. ✅ `Gemini generated X search terms`
6. ✅ `Saved recommendation: [video title]`
7. ✅ `Successfully generated recommendations`
8. ✅ `=== QUIZ COMPLETION FINISHED ===`

Then go to Explore page and you should see videos!

---

## 🎯 Quick Checklist

- [ ] App is running (`flutter run`)
- [ ] User is logged in
- [ ] Quiz completed fully
- [ ] Console shows "QUIZ COMPLETION STARTED"
- [ ] Console shows "User UID"
- [ ] Console shows "Starting recommendation generation"
- [ ] Console shows "Gemini generated"
- [ ] Console shows "Saved recommendation"
- [ ] Console shows "QUIZ COMPLETION FINISHED"
- [ ] No ERROR messages in console
- [ ] Firestore has new documents in 'recommendations'
- [ ] Explore page shows videos

---

*Debug guide created November 22, 2025*
*Enhanced logging added to track every step*
