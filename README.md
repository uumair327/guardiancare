# 🏥 GuardianCare - Flutter Application

A comprehensive educational and support application for guardians and children, built with **Clean Architecture** principles.

---

## 📋 Project Overview

GuardianCare is a Flutter application designed to provide educational resources, community support, and safety features for guardians and children. The application has been refactored to follow Clean Architecture principles, ensuring maintainability, testability, and scalability.

---

## 🏗️ Architecture

This project follows **Clean Architecture** with three distinct layers:

```
┌─────────────────────────────────────────┐
│       PRESENTATION LAYER                │
│  (UI, BLoC, Pages, Widgets)            │
└─────────────────┬───────────────────────┘
                  │ depends on
┌─────────────────┴───────────────────────┐
│         DOMAIN LAYER                    │
│  (Entities, Use Cases, Repositories)    │
└─────────────────┬───────────────────────┘
                  │ implemented by
┌─────────────────┴───────────────────────┐
│          DATA LAYER                     │
│  (Models, Data Sources, Repositories)   │
└─────────────────────────────────────────┘
```

### Key Principles
- **Dependency Rule**: Dependencies point inward
- **Single Responsibility**: Each class has one job
- **Dependency Inversion**: Depend on abstractions
- **Testability**: Each layer independently testable

---

## ✨ Features

### ✅ Implemented (Production Ready)

#### 1. Authentication
- Email/password authentication
- Google OAuth integration
- Password reset functionality
- User profile management
- Real-time auth state management

#### 2. Forum
- Real-time forum updates
- Comment system with streams
- Category support (Parent/Children)
- User details integration
- CRUD operations

### ⏳ In Progress

- Home Dashboard
- User Profile
- Learning Resources
- Interactive Quizzes
- Emergency Contacts
- Reporting System
- Content Exploration
- Consent Management

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.4.0 <4.0.0)
- Dart SDK
- Firebase account
- Android Studio / VS Code

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd guardiancare
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
- Add your `google-services.json` to `android/app/`
- Add your `GoogleService-Info.plist` to `ios/Runner/`
- Update `firebase_options.dart` with your configuration

4. **Run the app**
```bash
flutter run
```

---

## 📚 Documentation

### Quick Links

| Document | Description |
|----------|-------------|
| [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) | Main navigation hub |
| [CLEAN_ARCHITECTURE_IMPLEMENTATION.md](CLEAN_ARCHITECTURE_IMPLEMENTATION.md) | Architecture overview |
| [.kiro/specs/clean-architecture/MIGRATION_GUIDE.md](.kiro/specs/clean-architecture/MIGRATION_GUIDE.md) | Feature migration guide |
| [.kiro/specs/clean-architecture/TESTING_GUIDE.md](.kiro/specs/clean-architecture/TESTING_GUIDE.md) | Testing guide |
| [.kiro/specs/clean-architecture/FINAL_STATUS.md](.kiro/specs/clean-architecture/FINAL_STATUS.md) | Current status |

### Full Documentation

All documentation is located in `.kiro/specs/clean-architecture/`:
- Architecture guides
- Implementation guides
- Testing guides
- Migration guides
- Progress reports

---

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/features/authentication/domain/usecases/sign_in_with_email_test.dart

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Generate Mocks

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📂 Project Structure

```
lib/
├── core/                       # Core functionality
│   ├── error/                  # Error handling
│   ├── usecases/               # Base use case
│   ├── network/                # Network utilities
│   └── di/                     # Dependency injection
│
├── features/                   # Feature modules
│   ├── authentication/         # ✅ Complete
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── forum/                  # ✅ Complete
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │
│   └── [other features]/       # ⏳ In progress
│
└── main.dart                   # App entry point
```

---

## 🛠️ Tech Stack

### Core
- **Flutter** - UI framework
- **Dart** - Programming language
- **Clean Architecture** - Architecture pattern

### State Management
- **flutter_bloc** - BLoC pattern implementation
- **equatable** - Value equality

### Functional Programming
- **dartz** - Either type for error handling

### Dependency Injection
- **get_it** - Service locator
- **injectable** - Code generation

### Backend
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Database
- **Firebase Crashlytics** - Crash reporting
- **Firebase Analytics** - Analytics

### UI/UX
- **google_fonts** - Custom fonts
- **cached_network_image** - Image caching
- **shimmer** - Loading effects

### Testing
- **mockito** - Mocking framework
- **bloc_test** - BLoC testing
- **fake_cloud_firestore** - Firestore mocking

---

## 🎯 Development Guidelines

### Adding a New Feature

1. **Follow the Migration Guide**
   - See `.kiro/specs/clean-architecture/MIGRATION_GUIDE.md`

2. **Create Domain Layer**
   - Define entities
   - Create repository interface
   - Create use cases

3. **Create Data Layer**
   - Create models
   - Create data sources
   - Implement repository

4. **Create Presentation Layer**
   - Create BLoC
   - Define events and states
   - Update UI

5. **Register Dependencies**
   - Add to `lib/core/di/injection_container.dart`

6. **Write Tests**
   - Use case tests
   - Repository tests
   - BLoC tests

---

## 📝 String Constants Usage Guidelines

All hardcoded strings in the application are centralized into organized constant classes following Clean Architecture principles. This ensures consistency, maintainability, and easier localization support.

### String Constant Classes

| Class | Purpose | Location |
|-------|---------|----------|
| `AppStrings` | Core app info, URLs, storage keys, route names | `lib/core/constants/app_strings.dart` |
| `ErrorStrings` | Error messages (network, auth, cache, server) | `lib/core/constants/error_strings.dart` |
| `ValidationStrings` | Input validation messages | `lib/core/constants/validation_strings.dart` |
| `UIStrings` | UI text (buttons, labels, titles, placeholders) | `lib/core/constants/ui_strings.dart` |
| `FeedbackStrings` | SnackBar/toast messages (success, error, warning) | `lib/core/constants/feedback_strings.dart` |
| `FirebaseStrings` | Firebase collection/document names | `lib/core/constants/firebase_strings.dart` |
| `ApiStrings` | API URLs, endpoints, headers | `lib/core/constants/api_strings.dart` |

### Feature-Specific Strings

For strings used only within a single feature, create a feature-specific strings file:

```
lib/features/{feature}/presentation/constants/strings.dart
```

Examples:
- `ForumStrings` - Forum feature strings
- `VideoPlayerStrings` - Video player feature strings

### Usage Examples

#### Single Import (Recommended)
```dart
// Import all constants with a single import
import 'package:guardiancare/core/constants/constants.dart';

// Usage
Text(UIStrings.signIn);
Text(ErrorStrings.network);
Text(FeedbackStrings.saveSuccess);
```

#### Error Messages
```dart
// Use ErrorStrings for technical/system errors
throw ServerException(ErrorStrings.server);
return Left(Failure(ErrorStrings.networkError));

// Template methods for dynamic errors
ErrorStrings.failedTo('load data'); // "Failed to load data."
ErrorStrings.failedToWithReason('save', 'disk full'); // "Failed to save: disk full"
```

#### Validation Messages
```dart
// Use ValidationStrings for form validation
if (email.isEmpty) return ValidationStrings.emailRequired;
if (!isValidEmail(email)) return ValidationStrings.emailInvalid;

// Template methods for dynamic validation
ValidationStrings.minLength(6); // "Must be at least 6 characters."
ValidationStrings.maxLength(100); // "Must be at most 100 characters."
```

#### UI Text
```dart
// Use UIStrings for buttons, labels, titles
ElevatedButton(
  onPressed: onSubmit,
  child: Text(UIStrings.submit),
);

// Time-based greetings
Text(UIStrings.goodMorning);

// Template methods for dynamic text
UIStrings.minutesAgo(5); // "5m ago"
UIStrings.itemCount(3, 'item'); // "3 items"
```

#### Feedback Messages
```dart
// Use FeedbackStrings for SnackBars and toasts
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(FeedbackStrings.saveSuccess)),
);

// Template methods for dynamic feedback
FeedbackStrings.itemSaved('Profile'); // "Profile saved successfully!"
FeedbackStrings.confirmAction('delete'); // "Are you sure you want to delete?"
```

#### Firebase Constants
```dart
// Use FirebaseStrings for collection/document names
final collection = FirebaseFirestore.instance.collection(FirebaseStrings.users);
final data = {
  FirebaseStrings.fieldName: name,
  FirebaseStrings.fieldEmail: email,
  FirebaseStrings.fieldCreatedAt: FieldValue.serverTimestamp(),
};
```

### When to Use Constants vs. AppLocalizations

| Use Case | Use This |
|----------|----------|
| User-facing text that needs translation | `AppLocalizations` (l10n) |
| Technical identifiers (collection names, API endpoints) | String Constants |
| Error codes and technical messages | `ErrorStrings` |
| Asset paths and URLs | `AppStrings` |
| Strings that are the same in all languages | String Constants |
| Button labels, titles (if not localized) | `UIStrings` |

### Adding New String Constants

1. **Identify the category** - Determine which string class the constant belongs to
2. **Add to appropriate file** - Add the constant to the correct file
3. **Use descriptive names** - Use clear, descriptive constant names
4. **Group related constants** - Keep related constants together with section comments
5. **Add template methods** - For dynamic strings, add template methods

Example:
```dart
// In error_strings.dart
class ErrorStrings {
  // ==================== New Category ====================
  static const String newError = 'New error message.';
  
  // Template method for dynamic errors
  static String customError(String detail) => 'Error: $detail';
}
```

### Best Practices

1. **Never hardcode strings** - Always use constants or localization
2. **Single import** - Use `import 'package:guardiancare/core/constants/constants.dart';`
3. **Feature isolation** - Keep feature-specific strings in feature folders
4. **Consistent naming** - Follow existing naming conventions
5. **Document new categories** - Add section comments for new constant groups

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` before committing
- Write tests for new features
- Document complex logic
- Keep functions small and focused

---

## 📊 Project Status

| Metric | Status |
|--------|--------|
| **Features Complete** | 2 of 10 (20%) |
| **Production Files** | 38 |
| **Documentation Files** | 18+ |
| **Code Quality** | ⭐⭐⭐⭐⭐ |
| **Test Coverage** | In Progress |
| **Production Ready** | ✅ Yes (2 features) |

---

<!-- SCREENSHOTS -->
## Screenshots of Application [APK]

### Home and Explore Pages
| Home Page | Explore Page |
|:---------:|:------------:|
|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FhomePage.jpg?alt=media&token=8fbcd6eb-69dd-4907-8f68-557f3b20da07" alt="Home Page" width="240"/>|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FexplorePage.jpg?alt=media&token=4bef8770-a96b-4e84-9104-071a68fb6367" alt="Explore Page" width="240"/>|

### Forum Page
| Forum Page 1 | Forum Page 2 | Forum Page 3 |
|:------------:|:------------:|:------------:|
|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FforumPage.jpg?alt=media&token=088b74dd-97d0-4928-af77-10447ed33b24" alt="Forum Page" width="240"/>|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FforumPage2.jpg?alt=media&token=bb99b3bb-2cea-4aea-ab3f-a85ab2c96a16" alt="Forum Page 2" width="240"/>|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FforumPage3.jpg?alt=media&token=1155cf11-c328-408f-a0b7-4c15619a2747" alt="Forum Page 3" width="240"/>|

### Learn Page
| Learn Page 1 | Learn Page 2 | Learn Page 3 |
|:------------:|:------------:|:------------:|
|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FlearnPage.jpg?alt=media&token=48e1f85e-04e7-45bb-a2f2-cbc13a86f1cc" alt="Learn Page" width="240"/>|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FlearnPage2.jpg?alt=media&token=2f749f94-a9e4-48c9-b299-975ff5b479b3" alt="Learn Page 2" width="240"/>|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FlearnPage3.jpg?alt=media&token=c8ed5821-c1bf-4b5d-83e3-d5b1a03b55cf" alt="Learn Page 3" width="240"/>|

### Quiz Page
| Quiz Page 1 | Quiz Page 2 |
|:-----------:|:-----------:|
|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FquizPage.jpg?alt=media&token=354061bd-7c48-4de6-beb9-11ddaacbc85e" alt="Quiz Page" width="240"/>|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FquizPage2.jpg?alt=media&token=7f46c41f-8373-4196-be1c-00c79a58d60b" alt="Quiz Page 2" width="240"/>|

### Emergency Page
| Emergency Page |
|:--------------:|
|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FemergencyPage.jpg?alt=media&token=bc2f536c-fedd-4416-a058-19b3e349dd84" alt="Emergency Page" width="240"/>|

### Profile Page
| Profile Page |
|:------------:|
|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FprofilePage.jpg?alt=media&token=4f1d2e28-5af5-4a5e-a3c4-a1d2ec04a176" alt="Profile Page" width="240"/>|

### Web View
| Web View |
|:--------:|
|<img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FwebPage.jpg?alt=media&token=6a9e63c1-fe94-4625-98c6-fe613e59aad1" alt="Web View" width="240"/>|

## Testing and Feedback 

We value your input and strive to make our app the best it can be. If you're interested in helping us test new features and provide feedback, we invite you to join our list of testers.

By becoming a tester, you'll get the opportunity to experience beta testing and try out upcoming features before they're released to the public. Meanwhile, stable releases can be found in the [Releases section](https://github.com/uumair327/guardiancare/releases/tag/Stable) . You can also contribute by building the app locally and testing specific functionalities to help us find and fix bugs. Alternatively, you can join our testing app group to access beta releases and provide [feedback directly](https://github.com/uumair327/guardiancare/issues).

To join our testing program, click [here](https://appdistribution.firebase.dev/i/2dc0d93759150b3f) and become a part of shaping the future of our app!

## 🤝 Contributing

### Development Workflow

1. Create a feature branch
2. Follow Clean Architecture patterns
3. Write tests
4. Update documentation
5. Submit pull request

### Code Review Checklist

- [ ] Follows Clean Architecture
- [ ] All layers implemented
- [ ] Tests written
- [ ] Documentation updated
- [ ] No compilation errors
- [ ] No diagnostic issues

---

## 📝 License

[Add your license here]

---

## 👥 Team

[Add team members here]

---

## 📞 Support

For questions or issues:
1. Check the documentation in `.kiro/specs/clean-architecture/`
2. Review code examples in `lib/features/authentication/` and `lib/features/forum/`
3. Follow the migration guide for new features

---

## 🎉 Acknowledgments

- Clean Architecture by Robert C. Martin
- Flutter team for the amazing framework
- Firebase for backend services
- All contributors to this project

---

## 📈 Roadmap

### Phase 1: Foundation ✅
- [x] Core infrastructure
- [x] Authentication feature
- [x] Forum feature
- [x] Documentation
- [x] Testing infrastructure

### Phase 2: Core Features ⏳
- [ ] Home dashboard
- [ ] User profile
- [ ] Learning resources
- [ ] Interactive quizzes

### Phase 3: Advanced Features ⏳
- [ ] Emergency contacts
- [ ] Reporting system
- [ ] Content exploration
- [ ] Consent management

### Phase 4: Polish & Launch 📅
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] UI/UX refinement
- [ ] Production deployment

---

**Built with ❤️ using Flutter and Clean Architecture**

---

**Last Updated**: November 22, 2025  
**Version**: 1.0.0+16  
**Status**: Active Development
