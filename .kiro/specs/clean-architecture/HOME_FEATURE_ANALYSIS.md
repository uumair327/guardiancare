# Home Feature Analysis

**Date**: November 22, 2024  
**Status**: Analysis Complete ✅

---

## Current Implementation Overview

The Home feature is a dashboard that displays:
1. **Carousel** - Dynamic content from Firestore (images, videos, custom content)
2. **Quick Actions** - 6 circular buttons for navigation to other features

---

## Directory Structure

```
lib/src/features/home/
├── controllers/
│   └── home_controller.dart
├── screens/
│   └── home_page.dart
└── widgets/
    ├── circular_button.dart
    └── home_carousel.dart
```

---

## Current Components Analysis

### 1. HomeController
**File**: `lib/src/features/home/controllers/home_controller.dart`

**Functionality**:
- Fetches carousel data from Firestore collection `carousel_items`
- Returns list of carousel items with type, imageUrl, link, thumbnailUrl, content

**Data Source**:
- Firebase Firestore collection: `carousel_items`

**Data Structure**:
```dart
{
  'type': String,        // 'image', 'video', or 'custom'
  'imageUrl': String,    // URL of the image
  'link': String,        // Link to open
  'thumbnailUrl': String, // Thumbnail for videos
  'content': Map,        // Custom content data
}
```

---

### 2. HomePage
**File**: `lib/src/features/home/screens/home_page.dart`

**Functionality**:
- Displays carousel at the top
- Shows 6 quick action buttons in a card:
  - Quiz
  - Learn
  - Emergency
  - Profile (with parental consent check)
  - Website
  - Mail Us (with parental consent check)

**Dependencies**:
- `HomeController` - for carousel data
- `ConsentController` - for parental consent verification
- `FirebaseAuth` - for current user

**Navigation Targets**:
1. Quiz → `QuizPage`
2. Learn → `VideoPage`
3. Emergency → `EmergencyContactPage`
4. Profile → `Account`
5. Website → `WebViewPage` (childrenofindia.in)
6. Mail Us → Email launcher (hello@childrenofindia.in)

---

### 3. CircularButton Widget
**File**: `lib/src/features/home/widgets/circular_button.dart`

**Functionality**:
- Reusable circular button with icon and label
- Takes iconData, label, and onPressed callback

**Properties**:
- Simple, stateless widget
- Already well-structured
- No changes needed

---

### 4. HomeCarousel Widget
**File**: `lib/src/features/home/widgets/home_carousel.dart`

**Functionality**:
- Displays carousel slider with auto-play
- Supports image, video, and custom content types
- Uses cached network images
- Shows shimmer loading effect
- Handles tap to navigate to content

**Features**:
- Auto-play with 3-second interval
- Infinite scroll
- Center page enlargement
- Loading placeholders (shimmer)
- Error handling
- Video play icon overlay

---

## Required Entities

### 1. CarouselItemEntity
```dart
class CarouselItemEntity {
  final String id;
  final String type;          // 'image', 'video', 'custom'
  final String imageUrl;
  final String link;
  final String thumbnailUrl;
  final Map<String, dynamic> content;
  final int order;            // For sorting
  final bool isActive;        // For enabling/disabling
}
```

### 2. QuickActionEntity (Optional)
```dart
class QuickActionEntity {
  final String id;
  final String label;
  final String iconName;
  final String route;
  final bool requiresConsent;
  final int order;
  final bool isActive;
}
```

**Note**: Quick actions are currently hardcoded in the UI. We can keep them hardcoded or make them dynamic from Firestore.

---

## Required Use Cases

### 1. GetCarouselItems
- **Input**: None (or optional filters)
- **Output**: `Stream<List<CarouselItemEntity>>` or `Future<List<CarouselItemEntity>>`
- **Purpose**: Fetch carousel items from Firestore
- **Real-time**: Yes (Stream preferred for real-time updates)

### 2. GetQuickActions (Optional)
- **Input**: None
- **Output**: `List<QuickActionEntity>`
- **Purpose**: Get quick action buttons configuration
- **Note**: Can be hardcoded initially, made dynamic later

---

## Repository Interface

### HomeRepository
```dart
abstract class HomeRepository {
  // Carousel
  Stream<Either<Failure, List<CarouselItemEntity>>> getCarouselItems();
  
  // Quick Actions (optional - can be hardcoded)
  Future<Either<Failure, List<QuickActionEntity>>> getQuickActions();
}
```

---

## Data Layer Requirements

### 1. CarouselItemModel
- Extends `CarouselItemEntity`
- Implements `fromJson` and `toJson`
- Maps Firestore document to entity

### 2. HomeRemoteDataSource
- Interface and implementation
- Fetches data from Firestore
- Returns streams for real-time updates

### 3. HomeRepositoryImpl
- Implements `HomeRepository`
- Uses `HomeRemoteDataSource`
- Handles errors and converts to Failures

---

## Presentation Layer Requirements

### 1. HomeBloc
**Events**:
- `LoadCarouselItems` - Load carousel data
- `RefreshCarouselItems` - Refresh carousel
- `CarouselItemTapped` - Handle carousel item tap (optional)

**States**:
- `HomeInitial` - Initial state
- `HomeLoading` - Loading data
- `CarouselItemsLoaded` - Carousel items loaded
- `HomeError` - Error occurred

### 2. HomePage Migration
- Replace `HomeController` with `HomeBloc`
- Add `BlocProvider` and `BlocConsumer`
- Handle loading, success, and error states
- Keep existing navigation logic
- Keep consent verification logic

### 3. Widgets
- `CircularButton` - No changes needed (already good)
- `HomeCarousel` - Minor updates to use entities instead of maps

---

## Dependencies

### External Packages (Already in use)
- `carousel_slider` - For carousel functionality
- `cached_network_image` - For image caching
- `shimmer` - For loading effect
- `url_launcher` - For email launcher

### Internal Dependencies
- `ConsentController` - For parental consent (keep as is for now)
- Navigation to other features

---

## Migration Strategy

### Phase 1: Domain Layer
1. Create `CarouselItemEntity`
2. Create `HomeRepository` interface
3. Create `GetCarouselItems` use case

### Phase 2: Data Layer
1. Create `CarouselItemModel`
2. Create `HomeRemoteDataSource` interface and implementation
3. Create `HomeRepositoryImpl`

### Phase 3: Presentation Layer
1. Create `HomeBloc` with events and states
2. Migrate `HomePage` to use `HomeBloc`
3. Update `HomeCarousel` to use entities
4. Keep `CircularButton` as is

### Phase 4: Dependency Injection
1. Register dependencies in DI container
2. Test the implementation

---

## Complexity Assessment

### Low Complexity ✅
- Simple data structure (carousel items)
- Single Firestore collection
- No complex business logic
- Widgets are already well-structured

### Estimated Time
- Domain Layer: 30 minutes
- Data Layer: 45 minutes
- Presentation Layer: 1 hour
- Testing: 30 minutes
- **Total**: ~2.5 hours

---

## Notes

### Keep As Is
- `CircularButton` widget (already perfect)
- Navigation logic (works well)
- Consent verification (handled by ConsentController)
- Quick actions (can remain hardcoded)

### Migrate
- `HomeController` → `HomeBloc`
- Direct Firestore calls → Repository pattern
- Map data structure → Entity/Model pattern
- `HomeCarousel` → Use entities

### Optional Enhancements (Future)
- Make quick actions dynamic from Firestore
- Add analytics for carousel item taps
- Add caching for carousel items
- Add pull-to-refresh

---

## Firestore Collection Structure

### Collection: `carousel_items`
```json
{
  "type": "image",
  "imageUrl": "https://...",
  "link": "https://...",
  "thumbnailUrl": "",
  "content": {},
  "order": 1,
  "isActive": true
}
```

---

## Success Criteria

### Functional
- ✅ Carousel loads from Firestore
- ✅ Carousel auto-plays
- ✅ Carousel items are tappable
- ✅ Quick actions navigate correctly
- ✅ Loading states shown
- ✅ Error handling works

### Technical
- ✅ Clean Architecture compliant
- ✅ BLoC pattern implemented
- ✅ Stream-based real-time updates
- ✅ Proper error handling
- ✅ Zero compilation errors

---

## Conclusion

The Home feature is relatively simple and straightforward to migrate. The main work involves:
1. Creating entities and models for carousel items
2. Implementing repository pattern for Firestore access
3. Creating HomeBloc for state management
4. Updating HomePage to use BLoC

The widgets are already well-structured and require minimal changes.

---

**Generated**: November 22, 2024  
**Status**: Analysis Complete ✅  
**Next**: Start Domain Layer Implementation
