# Localization Quick Guide 🌍

## ✅ Setup Complete!

Your app now supports **9 languages** with a beautiful language selector!

## Supported Languages

| Language | Code | Native Name | Flag |
|----------|------|-------------|------|
| English | en | English | 🇬🇧 |
| Hindi | hi | हिन्दी | 🇮🇳 |
| Marathi | mr | मराठी | 🇮🇳 |
| Gujarati | gu | ગુજરાતી | 🇮🇳 |
| Bengali | bn | বাংলা | 🇮🇳 |
| Tamil | ta | தமிழ் | 🇮🇳 |
| Telugu | te | తెలుగు | 🇮🇳 |
| Kannada | kn | ಕನ್ನಡ | 🇮🇳 |
| Malayalam | ml | മലയാളം | 🇮🇳 |

## How to Change Language

1. Open app
2. Go to **Profile** tab
3. Tap **Account**
4. Under **Settings**, tap **Language**
5. Select your preferred language
6. Restart app to apply

## For Developers

### Use Localized Strings

```dart
// Import
import 'package:guardiancare/core/l10n/generated/app_localizations.dart';

// Use in widgets
Text(AppLocalizations.of(context)!.home)
Text(AppLocalizations.of(context)!.login)
Text(AppLocalizations.of(context)!.settings)
```

### Available Strings

- `appTitle` - App name
- `home`, `learn`, `explore`, `forum`, `profile` - Tab labels
- `login`, `signup`, `logout` - Auth actions
- `email`, `password` - Form fields
- `settings`, `language`, `account` - Settings
- `save`, `cancel`, `delete`, `confirm` - Actions
- `yes`, `no` - Confirmations
- `loading`, `error`, `success` - States
- And more...

### Add New Translation

1. **Edit ARB files** (l10n/app_*.arb)
```json
"newKey": "English Text",
"@newKey": {
  "description": "What this text is for"
}
```

2. **Translate to other languages**
```json
// l10n/app_hi.arb
"newKey": "हिन्दी पाठ"
```

3. **Regenerate**
```bash
flutter gen-l10n
```

4. **Use in code**
```dart
Text(AppLocalizations.of(context)!.newKey)
```

### With Placeholders

```dart
// ARB file:
"welcomeUser": "Welcome, {name}!"

// Code:
AppLocalizations.of(context)!.welcomeUser('John')
```

### With Plurals

```dart
// ARB file:
"itemsCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}"

// Code:
AppLocalizations.of(context)!.itemsCount(5)
```

## Files Structure

```
guardiancare/
├── l10n/
│   ├── app_en.arb (English - template)
│   ├── app_hi.arb (Hindi)
│   ├── app_mr.arb (Marathi)
│   ├── app_gu.arb (Gujarati)
│   ├── app_bn.arb (Bengali)
│   ├── app_ta.arb (Tamil)
│   ├── app_te.arb (Telugu)
│   ├── app_kn.arb (Kannada)
│   └── app_ml.arb (Malayalam)
├── l10n.yaml (config)
└── lib/
    └── core/
        ├── l10n/generated/ (auto-generated)
        ├── services/locale_service.dart
        └── widgets/language_selector_dialog.dart
```

## Commands

```bash
# Generate localizations
flutter gen-l10n

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check for issues
flutter analyze
```

## Troubleshooting

### Language not changing?
- Restart the app after changing language
- Check if locale is saved in LocaleService

### Missing translation?
```bash
flutter gen-l10n
flutter clean
flutter run
```

### Add new language?
1. Create `l10n/app_XX.arb` (XX = language code)
2. Add translations
3. Update `main.dart` supportedLocales
4. Update `LocaleService.getSupportedLocales()`
5. Run `flutter gen-l10n`

## Best Practices

✅ **DO**:
- Use `AppLocalizations.of(context)!.key` for all text
- Add descriptions in ARB files
- Test in multiple languages
- Keep translations consistent

❌ **DON'T**:
- Hardcode strings in widgets
- Forget to regenerate after ARB changes
- Use English text directly
- Skip translation descriptions

## Status

✅ **READY TO USE**

- 9 languages supported
- Language selector in Account page
- All strings ready for translation
- Clean Architecture compliant

**Happy Localizing!** 🎉
