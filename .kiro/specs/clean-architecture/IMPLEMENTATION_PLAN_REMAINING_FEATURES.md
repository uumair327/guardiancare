# Implementation Plan - Remaining 7 Features

**Date**: November 22, 2024  
**Status**: Ready to Implement  
**Target**: 100% Clean Architecture Migration

---

## 🎯 Goal

Complete Clean Architecture migration for all 7 remaining features following the proven patterns from Authentication, Forum, and Home features.

---

## 📋 Features to Implement

### Priority Order (Recommended)
1. **Profile** - Simplest, builds confidence
2. **Emergency** - Simple CRUD operations  
3. **Learn** - Refactor existing BLoC
4. **Quiz** - Refactor existing BLoC
5. **Report** - Refactor existing BLoC
6. **Consent** - Refactor existing BLoC
7. **Explore** - Most complex, do last

---

## 🔧 Standard Implementation Template

For each feature, follow this proven pattern:

### Step 1: Domain Layer (30-45 min)
```dart
// 1. Create Entity
lib/features/[feature]/domain/entities/[feature]_entity.dart

// 2. Create Repository Interface
lib/features/[feature]/domain/repositories/[feature]_repository.dart

// 3. Create Use Cases
lib/features/[feature]/domain/usecases/
  - get_[entity].dart
  - create_[entity].dart
  - update_[entity].dart
  - delete_[entity].dart
```

### Step 2: Data Layer (45-60 min)
```dart
// 1. Create Model
lib/features/[feature]/data/models/[feature]_model.dart

// 2. Create Data Source
lib/features/[feature]/data/datasources/[feature]_remote_datasource.dart

// 3. Create Repository Implementation
lib/features/[feature]/data/repositories/[feature]_repository_impl.dart
```

### Step 3: Presentation Layer (60-90 min)
```dart
// 1. Create Events & States
lib/features/[feature]/presentation/bloc/
  - [feature]_event.dart
  - [feature]_state.dart
  - [feature]_bloc.dart

// 2. Create/Update Pages
lib/features/[feature]/presentation/pages/
  - [feature]_page.dart

// 3. Create Widgets (if needed)
lib/features/[feature]/presentation/widgets/
```

### Step 4: Integration (15-20 min)
```dart
// 1. Register in DI Container
lib/core/di/injection_container.dart

// 2. Test Compilation
flutter analyze

// 3. Manual Testing
```

---

## 📝 Feature-Specific Details

### 1. Profile Feature

**Complexity**: ⭐ Low  
**Time**: 2-3 hours  
**Current**: Single page with Firestore calls

**Entity**:
```dart
class UserProfileEntity extends Equatable {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final String role;
  final DateTime createdAt;
}
```

**Use Cases**:
- GetUserProfile
- UpdateUserProfile  
- DeleteUserAccount

**Key Changes**:
- Replace direct Firestore calls with repository
- Add BLoC for state management
- Keep existing UI structure
- Maintain logout and delete functionality

---

### 2. Emergency Feature

**Complexity**: ⭐ Low  
**Time**: 2-3 hours  
**Current**: Single page with Firestore calls

**Entity**:
```dart
class EmergencyContactEntity extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool isPrimary;
}
```

**Use Cases**:
- GetEmergencyContacts
- AddEmergencyContact
- UpdateEmergencyContact
- DeleteEmergencyContact
- CallEmergencyContact

**Key Changes**:
- Replace direct Firestore calls
- Add BLoC for CRUD operations
- Keep call functionality
- Add loading/error states

---

### 3. Learn Feature

**Complexity**: ⭐⭐ Low-Medium  
**Time**: 2-3 hours  
**Current**: Has BLoC, needs refactoring

**Entities**:
```dart
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final int order;
}

class VideoEntity extends Equatable {
  final String id;
  final String title;
  final String videoId;
  final String categoryId;
  final String thumbnailUrl;
}
```

**Use Cases**:
- GetCategories
- GetVideos
- GetVideosByCategory

**Key Changes**:
- Move to Clean Architecture structure
- Create proper domain entities
- Separate repository interface from implementation
- Update BLoC to use use cases
- Keep existing UI

---

### 4. Quiz Feature

**Complexity**: ⭐⭐ Low-Medium  
**Time**: 2-3 hours  
**Current**: Has BLoC, needs refactoring

**Entities**:
```dart
class QuizEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<QuestionEntity> questions;
}

class QuestionEntity extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final int points;
}
```

**Use Cases**:
- GetQuiz
- SubmitAnswer
- CalculateScore
- SaveQuizResult

**Key Changes**:
- Refactor to Clean Architecture
- Create domain entities
- Separate repository
- Update BLoC
- Keep scoring logic

---

### 5. Report Feature

**Complexity**: ⭐⭐ Low-Medium  
**Time**: 2-3 hours  
**Current**: Has BLoC, needs refactoring

**Entity**:
```dart
class ReportEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final String status;
  final List<String> attachments;
}
```

**Use Cases**:
- SubmitReport
- GetUserReports
- GetReportDetails
- UpdateReportStatus

**Key Changes**:
- Refactor to Clean Architecture
- Create domain layer
- Separate repository
- Update BLoC
- Keep submission flow

---

### 6. Consent Feature

**Complexity**: ⭐⭐ Low-Medium  
**Time**: 2-3 hours  
**Current**: Has BLoC, needs refactoring

**Entity**:
```dart
class ConsentEntity extends Equatable {
  final String userId;
  final bool hasParentalConsent;
  final String parentalKey;
  final DateTime consentDate;
  final DateTime lastVerified;
}
```

**Use Cases**:
- VerifyParentalKey
- SetParentalKey
- CheckConsentStatus
- UpdateConsent

**Key Changes**:
- Refactor to Clean Architecture
- Create domain layer
- Use SharedPreferences via data source
- Update BLoC
- Keep verification logic

---

### 7. Explore Feature

**Complexity**: ⭐⭐ Medium  
**Time**: 3-4 hours  
**Current**: Has controller, needs full migration

**Entity**:
```dart
class ResourceEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // 'article', 'video', 'pdf'
  final String url;
  final String category;
  final String thumbnailUrl;
  final DateTime publishedAt;
}
```

**Use Cases**:
- GetResources
- GetResourcesByCategory
- SearchResources
- GetResourceDetails

**Key Changes**:
- Complete Clean Architecture implementation
- Create all layers
- Add search functionality
- Category filtering
- Keep existing UI structure

---

## 🎯 Success Criteria

For each feature:

### Technical
- ✅ Zero compilation errors
- ✅ Zero warnings
- ✅ Clean Architecture compliant
- ✅ BLoC pattern implemented
- ✅ Proper error handling
- ✅ Dependencies registered

### Functional
- ✅ All existing functionality preserved
- ✅ UI works as expected
- ✅ Loading states shown
- ✅ Error handling works
- ✅ Navigation works

---

## 📊 Estimated Timeline

### Session 1 (Current) - 3-4 hours
- ✅ Authentication (Complete)
- ✅ Forum (Complete)
- ✅ Home (Complete)

### Session 2 - 3-4 hours
- Profile Feature
- Emergency Feature

### Session 3 - 3-4 hours
- Learn Feature
- Quiz Feature

### Session 4 - 3-4 hours
- Report Feature
- Consent Feature

### Session 5 - 3-4 hours
- Explore Feature
- Final testing
- Documentation

**Total**: 5 sessions, 15-20 hours

---

## 🚀 Implementation Strategy

### Batch Processing
Group features by complexity and implement in batches:

**Batch 1: Simple Features**
- Profile
- Emergency

**Batch 2: BLoC Refactoring**
- Learn
- Quiz
- Report
- Consent

**Batch 3: Complex Feature**
- Explore

### Quality Checkpoints
After each feature:
1. Run `flutter analyze`
2. Check for compilation errors
3. Verify all imports
4. Test basic functionality
5. Update documentation

---

## 📝 Code Templates

### Entity Template
```dart
import 'package:equatable/equatable.dart';

class FeatureEntity extends Equatable {
  final String id;
  final String name;
  
  const FeatureEntity({
    required this.id,
    required this.name,
  });
  
  @override
  List<Object?> get props => [id, name];
}
```

### Repository Interface Template
```dart
import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';

abstract class FeatureRepository {
  Future<Either<Failure, Entity>> getEntity(String id);
  Future<Either<Failure, List<Entity>>> getEntities();
  Future<Either<Failure, void>> createEntity(Entity entity);
  Future<Either<Failure, void>> updateEntity(Entity entity);
  Future<Either<Failure, void>> deleteEntity(String id);
}
```

### Use Case Template
```dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';

class GetEntity extends UseCase<Entity, GetEntityParams> {
  final FeatureRepository repository;
  
  GetEntity(this.repository);
  
  @override
  Future<Either<Failure, Entity>> call(GetEntityParams params) async {
    return await repository.getEntity(params.id);
  }
}

class GetEntityParams extends Equatable {
  final String id;
  
  const GetEntityParams({required this.id});
  
  @override
  List<Object> get props => [id];
}
```

### Model Template
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FeatureModel extends FeatureEntity {
  const FeatureModel({
    required super.id,
    required super.name,
  });
  
  factory FeatureModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeatureModel(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}
```

### BLoC Template
```dart
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final GetEntity getEntity;
  
  FeatureBloc({required this.getEntity}) : super(const FeatureInitial()) {
    on<LoadEntity>(_onLoadEntity);
  }
  
  Future<void> _onLoadEntity(
    LoadEntity event,
    Emitter<FeatureState> emit,
  ) async {
    emit(const FeatureLoading());
    
    final result = await getEntity(NoParams());
    
    result.fold(
      (failure) => emit(FeatureError(failure.message)),
      (entity) => emit(EntityLoaded(entity)),
    );
  }
}
```

---

## 🎉 Expected Final Result

### After All Implementations

**Features**: 10/10 (100%)  
**Files**: ~80-100 total  
**Architecture**: 100% Clean Architecture  
**Quality**: Production-ready  

### Benefits
- ✅ Fully testable codebase
- ✅ Maintainable architecture
- ✅ Scalable structure
- ✅ Professional quality
- ✅ Zero technical debt

---

**Generated**: November 22, 2024  
**Status**: Ready to Implement  
**Next**: Profile Feature  
**Target**: 100% Clean Architecture
