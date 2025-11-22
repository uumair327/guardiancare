# Remaining Features Migration Roadmap

**Date**: November 22, 2024  
**Current Progress**: 3/10 Features Complete (30%)  
**Remaining**: 7 Features (70%)

---

## 📊 Overview

This document provides a detailed roadmap for migrating the remaining 7 features to Clean Architecture. Each feature follows the proven patterns established in Authentication, Forum, and Home features.

---

## 🎯 Completed Features (3/10)

| Feature | Status | Complexity | Time Spent |
|---------|--------|------------|------------|
| **Authentication** | ✅ 100% | Medium | ~2 hours |
| **Forum** | ✅ 100% | Medium | ~2 hours |
| **Home** | ✅ 100% | Low | ~1.5 hours |

**Total Time**: ~5.5 hours  
**Average per Feature**: ~1.8 hours

---

## 📋 Remaining Features (7/10)

### Priority 4: Profile Feature

**Current Implementation**:
- Single page: `account.dart`
- Displays user information from Firestore
- Settings: Emergency Contact, Logout, Delete Account
- Uses direct Firestore calls

**Complexity**: ⭐ Low (Simplest remaining feature)

**Required Entities**:
```dart
class UserProfileEntity {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final String role;
  final DateTime createdAt;
}
```

**Required Use Cases**:
1. `GetUserProfile` - Fetch user profile
2. `UpdateUserProfile` - Update profile info
3. `DeleteUserAccount` - Delete account

**Estimated Time**: 2-3 hours

**Migration Steps**:
1. Create ProfileEntity (15 min)
2. Create ProfileRepository interface (10 min)
3. Create use cases (30 min)
4. Create ProfileModel (15 min)
5. Create ProfileRemoteDataSource (30 min)
6. Create ProfileRepositoryImpl (20 min)
7. Create ProfileBloc (30 min)
8. Migrate account.dart (30 min)
9. Register dependencies (10 min)
10. Test (20 min)

---

### Priority 5: Learn Feature

**Current Implementation**:
- Already has BLoC: `LearnBloc`
- Has repository: `LearnRepository`
- Displays video categories and videos
- Uses YouTube API

**Complexity**: ⭐⭐ Low-Medium (Already has BLoC, needs refactoring)

**Current Structure**:
```
lib/src/features/learn/
├── bloc/
│   ├── learn_bloc.dart
│   ├── learn_event.dart
│   └── learn_state.dart
├── models/
│   ├── category.dart
│   └── video.dart
├── repository/
│   └── learn_repository.dart
└── screens/
    └── video_page.dart
```

**Required Changes**:
1. Move to Clean Architecture structure
2. Create proper domain entities
3. Separate repository interface from implementation
4. Create use cases
5. Update BLoC to use use cases

**Estimated Time**: 2-3 hours

**Migration Steps**:
1. Create domain entities (20 min)
2. Create repository interface (15 min)
3. Create use cases (30 min)
4. Move existing models to data layer (20 min)
5. Refactor repository to implementation (30 min)
6. Update BLoC to use use cases (30 min)
7. Update UI if needed (20 min)
8. Register dependencies (15 min)
9. Test (20 min)

---

### Priority 6: Quiz Feature

**Current Implementation**:
- Already has BLoC: `QuizBloc`
- Displays quiz questions
- Tracks scores
- Uses Firestore

**Complexity**: ⭐⭐ Low-Medium (Already has BLoC, needs refactoring)

**Current Structure**:
```
lib/src/features/quiz/
├── bloc/
│   ├── quiz_bloc.dart
│   ├── quiz_event.dart
│   └── quiz_state.dart
├── models/
│   ├── question.dart
│   └── quiz.dart
└── screens/
    └── quiz_page.dart
```

**Required Entities**:
```dart
class QuizEntity {
  final String id;
  final String title;
  final List<QuestionEntity> questions;
}

class QuestionEntity {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
}
```

**Required Use Cases**:
1. `GetQuiz` - Fetch quiz
2. `SubmitAnswer` - Submit answer
3. `CalculateScore` - Calculate final score

**Estimated Time**: 2-3 hours

---

### Priority 7: Emergency Feature

**Current Implementation**:
- Single page: `emergency_contact_page.dart`
- Manages emergency contacts
- Call functionality
- Uses Firestore

**Complexity**: ⭐ Low

**Required Entities**:
```dart
class EmergencyContactEntity {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool isPrimary;
}
```

**Required Use Cases**:
1. `GetEmergencyContacts` - Fetch contacts
2. `AddEmergencyContact` - Add contact
3. `UpdateEmergencyContact` - Update contact
4. `DeleteEmergencyContact` - Delete contact
5. `CallEmergencyContact` - Initiate call

**Estimated Time**: 2-3 hours

---

### Priority 8: Report Feature

**Current Implementation**:
- Already has BLoC: `ReportBloc`
- Report incident functionality
- Uses Firestore

**Complexity**: ⭐⭐ Low-Medium (Already has BLoC, needs refactoring)

**Current Structure**:
```
lib/src/features/report/
├── bloc/
│   ├── report_bloc.dart
│   ├── report_event.dart
│   └── report_state.dart
└── screens/
    └── report_page.dart
```

**Required Entities**:
```dart
class ReportEntity {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final String status;
}
```

**Required Use Cases**:
1. `SubmitReport` - Submit incident report
2. `GetReports` - Fetch user reports
3. `GetReportDetails` - Get report details

**Estimated Time**: 2-3 hours

---

### Priority 9: Explore Feature

**Current Implementation**:
- Has controller: `ExploreController`
- Displays educational resources
- Uses Firestore

**Complexity**: ⭐⭐ Medium

**Required Entities**:
```dart
class ResourceEntity {
  final String id;
  final String title;
  final String description;
  final String type; // 'article', 'video', 'pdf'
  final String url;
  final String category;
}
```

**Required Use Cases**:
1. `GetResources` - Fetch resources
2. `GetResourcesByCategory` - Filter by category
3. `SearchResources` - Search functionality

**Estimated Time**: 3-4 hours

---

### Priority 10: Consent Feature

**Current Implementation**:
- Already has BLoC: `ConsentBloc`
- Parental consent verification
- Parental key management
- Uses SharedPreferences

**Complexity**: ⭐⭐ Low-Medium (Already has BLoC, needs refactoring)

**Current Structure**:
```
lib/src/features/consent/
├── bloc/
│   ├── consent_bloc.dart
│   ├── consent_event.dart
│   └── consent_state.dart
├── controllers/
│   └── consent_controller.dart
└── screens/
    └── consent_page.dart
```

**Required Entities**:
```dart
class ConsentEntity {
  final String userId;
  final bool hasParentalConsent;
  final String parentalKey;
  final DateTime consentDate;
}
```

**Required Use Cases**:
1. `VerifyParentalKey` - Verify key
2. `SetParentalKey` - Set new key
3. `CheckConsent` - Check consent status

**Estimated Time**: 2-3 hours

---

## 📊 Time Estimates Summary

| Feature | Complexity | Estimated Time | Notes |
|---------|------------|----------------|-------|
| Profile | ⭐ Low | 2-3 hours | Simplest |
| Learn | ⭐⭐ Low-Medium | 2-3 hours | Has BLoC |
| Quiz | ⭐⭐ Low-Medium | 2-3 hours | Has BLoC |
| Emergency | ⭐ Low | 2-3 hours | Simple CRUD |
| Report | ⭐⭐ Low-Medium | 2-3 hours | Has BLoC |
| Explore | ⭐⭐ Medium | 3-4 hours | More complex |
| Consent | ⭐⭐ Low-Medium | 2-3 hours | Has BLoC |

**Total Estimated Time**: 16-22 hours  
**Average per Feature**: 2.3-3.1 hours

---

## 🎯 Migration Strategy

### Recommended Order

1. **Profile** (Easiest, builds confidence)
2. **Emergency** (Simple CRUD operations)
3. **Learn** (Refactor existing BLoC)
4. **Quiz** (Refactor existing BLoC)
5. **Report** (Refactor existing BLoC)
6. **Consent** (Refactor existing BLoC)
7. **Explore** (Most complex, do last)

### Session Planning

**Session 1** (3-4 hours):
- Profile Feature
- Emergency Feature

**Session 2** (3-4 hours):
- Learn Feature
- Quiz Feature

**Session 3** (3-4 hours):
- Report Feature
- Consent Feature

**Session 4** (3-4 hours):
- Explore Feature
- Code cleanup
- Final testing

**Total**: 4 sessions, 12-16 hours

---

## 📝 Standard Migration Checklist

For each feature, follow this checklist:

### Domain Layer
- [ ] Create entities
- [ ] Create repository interface
- [ ] Create use cases
- [ ] Verify no external dependencies

### Data Layer
- [ ] Create models extending entities
- [ ] Create remote data source interface
- [ ] Create remote data source implementation
- [ ] Create repository implementation
- [ ] Handle errors with Either pattern

### Presentation Layer
- [ ] Create events
- [ ] Create states
- [ ] Create BLoC
- [ ] Manage stream subscriptions (if applicable)
- [ ] Handle cleanup

### UI Migration
- [ ] Create/update pages
- [ ] Create/update widgets
- [ ] Add BlocProvider
- [ ] Add BlocConsumer/BlocBuilder
- [ ] Handle loading states
- [ ] Handle error states
- [ ] Handle empty states

### Integration
- [ ] Register dependencies in DI container
- [ ] Update routes (if needed)
- [ ] Test compilation
- [ ] Manual testing

### Documentation
- [ ] Create feature analysis document
- [ ] Create completion document
- [ ] Update progress tracking

---

## 🔧 Common Patterns Reference

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
  Stream<Either<Failure, List<Entity>>> getEntities();
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

---

## 🎯 Success Criteria

For each feature to be considered complete:

### Technical
- ✅ Zero compilation errors
- ✅ Zero warnings
- ✅ Zero diagnostics issues
- ✅ Clean Architecture compliant
- ✅ BLoC pattern implemented
- ✅ Proper error handling
- ✅ Loading states
- ✅ Dependencies registered

### Functional
- ✅ All existing functionality preserved
- ✅ UI works as expected
- ✅ Navigation works
- ✅ Error scenarios handled
- ✅ Loading states shown
- ✅ Empty states shown (if applicable)

### Documentation
- ✅ Feature analysis document
- ✅ Completion document
- ✅ Progress tracking updated

---

## 📊 Expected Final Results

### After All Migrations

**Features Complete**: 10/10 (100%)

**Total Files Created/Modified**: ~80-100 files

**Architecture**:
- Domain Layer: 100%
- Data Layer: 100%
- Presentation Layer: 100%
- UI Migration: 100%

**Code Quality**:
- Compilation Errors: 0
- Warnings: 0
- Architecture Compliance: 100%

**Benefits**:
- Fully testable codebase
- Maintainable architecture
- Scalable structure
- Professional quality
- Production-ready

---

## 🚀 Next Steps

### Immediate
1. Start with Profile feature (simplest)
2. Follow established patterns
3. Maintain zero-error standard

### Short Term
- Complete all 7 remaining features
- Write comprehensive tests
- Code cleanup and optimization

### Long Term
- Performance optimization
- Security review
- Production deployment

---

**Generated**: November 22, 2024  
**Current Progress**: 30% (3/10 features)  
**Estimated Completion**: 4-6 sessions (12-16 hours)  
**Next Feature**: Profile (Priority 4)
