# Localization Debug & Testing Guide

**Date:** November 23, 2025  
**Status:** 🔧 DEBUGGING ENABLED

---

## 🔍 CHANGES MADE

### 1. Added Debug Logging
Added comprehensive logging throughout the localization flow to track exactly what's happening:

```dart
// In _changeAppLocale
print('🌍 _changeAppLocale called with: ${newLocale.languageCode}');
print('💾 Locale saved to storage: $saved');
print('✅ Root state updated');
print('📢 Showing snackbar for: ${localeInfo.nativeName}');
print('🔄 Restarting app...');

// In _loadSavedLocale
print('📱 Loading saved locale: ${savedLocale?.languageCode}');
print('✅ Loaded locale: ${_locale.languageCode}');

// In changeLocale
print('🔄 GuardiancareState.changeLocale called with: ${newLocale.languageCode}');
print('✅ Locale changed to: ${_locale.languageCode}');
```

### 2. Simplified Restart Flow
Removed the "Restart Now" button and made it automatic:
- Shows snackbar for 2 seconds
- Automatically restarts after 1.5 seconds
- Simpler, more reliable

### 3. Fixed State Update Order
Changed the order in `changeLocale`:
```dart
// OLD (Wrong order)
localeService.saveLocale(newLocale);  // Save first
setState(() { _locale = newLocale; }); // Update state second

// NEW (Correct order)
setState(() { _locale = newLocale; }); // Update state FIRST
localeService.saveLocale(newLocale);  // Save second
```

---

## 🧪 TESTING INSTRUCTIONS

### Step 1: Run with Console Open
```bash
flutter run
```

**Keep the console visible** to see debug logs!

### Step 2: Navigate to Account Page
1. Tap Profile button
2. Enter parental key
3. You should see Account page

### Step 3: Change Language to Hindi
1. Tap "Language" setting
2. Select "हिन्दी (Hindi)"
3. **Watch the console** for these logs:

```
🌍 _changeAppLocale called with: hi
💾 Locale saved to storage: true
🔄 GuardiancareState.changeLocale called with: hi
✅ Locale changed to: hi
✅ Root state updated
📢 Showing snackbar for: हिन्दी
🔄 Restarting app...
```

### Step 4: After Restart
After the app restarts, watch console for:

```
📱 Loading saved locale: hi
✅ Loaded locale: hi
```

### Step 5: Verify UI
Check the Account page:
- "Profile" should show "प्रोफाइल"
- "Settings" should show "सेटिंग्स"
- "Language" should show "भाषा"
- "Emergency Contact" should show "आपातकालीन संपर्क"
- "Log Out" should show "लॉगआउट"

---

## 🐛 TROUBLESHOOTING

### Issue 1: Console shows "Root state is null!"
**Problem:** Can't find GuardiancareState  
**Solution:** Check that AppRestartWidget wraps the app in main.dart

### Issue 2: Locale saves but doesn't load on restart
**Problem:** _loadSavedLocale not being called  
**Console shows:** No "Loading saved locale" message  
**Solution:** Check initState in GuardiancareState

### Issue 3: UI doesn't update after restart
**Problem:** UI still using hardcoded strings  
**Console shows:** Locale changes correctly but UI stays English  
**Solution:** Check that widgets use `l10n.keyName` not hardcoded strings

### Issue 4: App doesn't restart
**Problem:** AppRestartWidget.restartApp() not working  
**Console shows:** "Restarting app..." but nothing happens  
**Solution:** Check AppRestartWidget implementation

---

## 📊 EXPECTED CONSOLE OUTPUT

### Complete Flow:

```
// User selects Hindi
🌍 _changeAppLocale called with: hi
💾 Locale saved to storage: true
🔄 GuardiancareState.changeLocale called with: hi
✅ Locale changed to: hi
✅ Root state updated
📢 Showing snackbar for: हिन्दी
🔄 Restarting app...

// App restarts
📱 Loading saved locale: hi
✅ Loaded locale: hi
I am the user: [user_id]

// Account page loads
I am the user: [user_id]
```

---

## ✅ VERIFICATION CHECKLIST

Run through this checklist:

### Before Language Change
- [ ] Console shows: `📱 Loading saved locale: en` (or previous language)
- [ ] Account page shows English text
- [ ] Current language shows "🇬🇧 English"

### During Language Change
- [ ] Console shows: `🌍 _changeAppLocale called with: hi`
- [ ] Console shows: `💾 Locale saved to storage: true`
- [ ] Console shows: `🔄 GuardiancareState.changeLocale called with: hi`
- [ ] Console shows: `✅ Locale changed to: hi`
- [ ] Console shows: `✅ Root state updated`
- [ ] Console shows: `📢 Showing snackbar for: हिन्दी`
- [ ] Snackbar appears on screen
- [ ] Console shows: `🔄 Restarting app...`

### After Restart
- [ ] Console shows: `📱 Loading saved locale: hi`
- [ ] Console shows: `✅ Loaded locale: hi`
- [ ] Account page shows Hindi text
- [ ] "Profile" → "प्रोफाइल"
- [ ] "Settings" → "सेटिंग्स"
- [ ] "Language" → "भाषा"
- [ ] Current language shows "🇮🇳 हिन्दी"

### Persistence Test
- [ ] Close app completely
- [ ] Reopen app
- [ ] Console shows: `📱 Loading saved locale: hi`
- [ ] App opens in Hindi
- [ ] Account page still shows Hindi text

---

## 🎯 WHAT TO LOOK FOR

### Success Indicators ✅
1. **Console logs appear in order**
2. **"Locale saved to storage: true"**
3. **"Root state updated"**
4. **App restarts automatically**
5. **Locale loads on restart**
6. **UI shows translated text**

### Failure Indicators ❌
1. **"Root state is null!"** - State not accessible
2. **"Locale saved to storage: false"** - Storage failed
3. **No restart happens** - AppRestartWidget issue
4. **Locale doesn't load** - initState issue
5. **UI stays English** - Hardcoded strings

---

## 🔧 QUICK FIXES

### If locale doesn't save:
```dart
// Check SharedPreferences is initialized
final prefs = await SharedPreferences.getInstance();
print('SharedPreferences ready: ${prefs != null}');
```

### If state doesn't update:
```dart
// Check GuardiancareState is accessible
final state = guardiancare.of(context);
print('GuardiancareState found: ${state != null}');
```

### If app doesn't restart:
```dart
// Check AppRestartWidget is in tree
final restartState = context.findAncestorStateOfType<_AppRestartWidgetState>();
print('AppRestartWidget found: ${restartState != null}');
```

---

## 📱 TEST ALL LANGUAGES

Test each language and verify console output:

### English (en)
```
🌍 _changeAppLocale called with: en
✅ Locale changed to: en
```

### Hindi (hi)
```
🌍 _changeAppLocale called with: hi
✅ Locale changed to: hi
```

### Marathi (mr)
```
🌍 _changeAppLocale called with: mr
✅ Locale changed to: mr
```

### Gujarati (gu)
```
🌍 _changeAppLocale called with: gu
✅ Locale changed to: gu
```

### Bengali (bn)
```
🌍 _changeAppLocale called with: bn
✅ Locale changed to: bn
```

### Tamil (ta)
```
🌍 _changeAppLocale called with: ta
✅ Locale changed to: ta
```

### Telugu (te)
```
🌍 _changeAppLocale called with: te
✅ Locale changed to: te
```

### Kannada (kn)
```
🌍 _changeAppLocale called with: kn
✅ Locale changed to: kn
```

### Malayalam (ml)
```
🌍 _changeAppLocale called with: ml
✅ Locale changed to: ml
```

---

## 🎓 UNDERSTANDING THE FLOW

### 1. User Selects Language
```
LanguageSelectorDialog
    ↓
onLocaleSelected(newLocale)
    ↓
_changeAppLocale(context, newLocale)
```

### 2. Save & Update
```
LocaleService.saveLocale(newLocale)
    ↓ (saves to SharedPreferences)
GuardiancareState.changeLocale(newLocale)
    ↓ (updates _locale state)
setState(() => _locale = newLocale)
```

### 3. Restart
```
AppRestartWidget.restartApp(context)
    ↓
_AppRestartWidgetState.restartApp()
    ↓
setState(() => _key = UniqueKey())
    ↓
Entire app rebuilds
```

### 4. Load on Restart
```
GuardiancareState.initState()
    ↓
_loadSavedLocale()
    ↓
LocaleService.getSavedLocale()
    ↓ (reads from SharedPreferences)
setState(() => _locale = savedLocale)
```

### 5. MaterialApp Rebuilds
```
MaterialApp.router(
  key: ValueKey(_locale.languageCode),  // New key
  locale: _locale,                       // New locale
  ...
)
```

---

## 🎉 SUCCESS CRITERIA

The localization is working correctly when:

1. ✅ Console shows all expected logs
2. ✅ Locale saves successfully
3. ✅ State updates correctly
4. ✅ App restarts automatically
5. ✅ Locale loads on restart
6. ✅ UI shows translated text
7. ✅ Language persists after app close/reopen
8. ✅ All 9 languages work

---

## 📞 NEXT STEPS

1. **Run the app** with console open
2. **Change language** to Hindi
3. **Watch console logs** carefully
4. **Verify UI updates** after restart
5. **Report** which step fails (if any)

With the debug logging, we can pinpoint exactly where the issue is!

---

**Debug Mode:** ENABLED  
**Logging:** COMPREHENSIVE  
**Ready to test:** YES
