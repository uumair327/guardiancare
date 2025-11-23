# Logo Setup - Quick Guide 🎨

## ✅ Setup Complete!

Your custom logo is now used for:
1. **Splash Screen** - Shows when app launches
2. **App Icon** - Shows in device launcher/home screen

## What Was Done

### 1. Splash Screen ✅
- **Image**: `assets/logo/logo_splash.png`
- **Background**: White (#ffffff)
- **Position**: Center
- **Platforms**: Android & iOS
- **Android 12+**: ✅ Supported
- **Dark Mode**: ✅ Supported

### 2. App Launcher Icon ✅
- **Image**: `assets/logo/logo.png`
- **Platforms**: Android & iOS
- **Adaptive Icons**: ✅ Android
- **All Sizes**: ✅ Generated

## How It Looks

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│          [YOUR LOGO]            │  ← Splash Screen
│                                 │
│                                 │
└─────────────────────────────────┘

┌──────┐
│ LOGO │  ← App Icon (on home screen)
└──────┘
```

## Test It

### Android
```bash
flutter run
```
Watch for:
1. White splash screen with your logo (on app start)
2. Your logo as app icon (in launcher)

### iOS
```bash
flutter run -d ios
```
Watch for:
1. Splash screen with your logo
2. Your logo on home screen

## Update Logo Later

### Step 1: Replace Images
```
assets/logo/
├── logo.png (1024x1024px) - For app icon
└── logo_splash.png (1152x1152px) - For splash
```

### Step 2: Regenerate
```bash
dart run flutter_native_splash:create
dart run flutter_launcher_icons
flutter clean
flutter run
```

## Image Requirements

### App Icon (`logo.png`)
- **Size**: 1024x1024px minimum
- **Format**: PNG
- **Shape**: Square
- **Background**: Can be transparent (Android) or solid (iOS)

### Splash Logo (`logo_splash.png`)
- **Size**: 1152x1152px recommended
- **Format**: PNG with transparency
- **Safe Area**: Keep important content in center 512x512px
- **Background**: Transparent (white background added automatically)

## Pro Tips 💡

1. **Keep It Simple**: Logo should be clear at small sizes
2. **Center Focus**: Important elements in center
3. **High Contrast**: Visible on white background
4. **Test Both**: Check on light and dark devices
5. **Brand Consistency**: Match your app's color scheme

## Troubleshooting

### Splash Not Showing?
```bash
flutter clean
dart run flutter_native_splash:create
flutter run
```

### Icon Not Updating?
```bash
# Uninstall app first
adb uninstall app.guardiancare.guardiancare
# Then run again
flutter run
```

### Still Issues?
1. Check image files exist in `assets/logo/`
2. Verify image sizes (1024x1024 and 1152x1152)
3. Ensure images are PNG format
4. Run `flutter pub get`
5. Try `flutter clean`

## Files Generated

### Android
- ✅ Splash screens (all densities)
- ✅ App icons (all densities)
- ✅ Adaptive icons
- ✅ Android 12+ support
- ✅ Dark mode variants

### iOS
- ✅ Splash screen
- ✅ App icons (all sizes)
- ✅ Launch storyboard
- ✅ Info.plist updated

## Status: ✅ READY TO USE

Your app now has:
- ✅ Professional splash screen
- ✅ Custom app icon
- ✅ Multi-platform support
- ✅ Best practices followed

**No more Flutter default logo!** 🎉
