# Clean Architecture Migration - Quick Reference

**Last Updated**: November 22, 2024

---

## 📊 Current Status

### Progress: 30% Complete (3/10 Features)

| Feature | Status | Files | Notes |
|---------|--------|-------|-------|
| **Authentication** | ✅ 100% | 4 | Login, Signup, Password Reset |
| **Forum** | ✅ 100% | 6 | Forums, Comments, Real-time |
| **Home** | ✅ 100% | 13 | Carousel, Quick Actions |
| Profile | ⏳ 0% | - | Next priority |
| Learn | ⏳ 0% | - | Has BLoC, needs refactor |
| Quiz | ⏳ 0% | - | Has BLoC, needs refactor |
| Emergency | ⏳ 0% | - | - |
| Report | ⏳ 0% | - | Has BLoC, needs refactor |
| Explore | ⏳ 0% | - | - |
| Consent | ⏳ 0% | - | Has BLoC, needs refactor |

---

## 📁 File Locations

### Completed Features

#### Authentication
```
lib/features/authentication/
├── domain/ (already existed)
├── data/ (already existed)
└── presentation/
    ├── bloc/ (already existed)
    └── pages/ ✅ NEW
        ├── login_page.dart
        ├── signup_page.dart
        └── password_reset_page.dart
```

#### Forum
```
lib/features/forum/
├── domain/ (already existed)
├── data/ (already existed)
└── presentation/
    ├── bloc/ (already existed)
    ├── pages/ ✅ NEW
    │   ├── forum_page.dart
    │   └── forum_detail_page.dart
    └── widgets/ ✅ NEW
        ├── forum_list_item.dart
        ├── comment_item.dart
        ├── user_details_widget.dart
        └── comment_input_widget.dart
```

#### Home
```
lib/features/home/
├── domain/ ✅ NEW
│   ├── entities/
│   │   └── carousel_item_entity.dart
│   ├── repositories/
│   │   └── home_repository.dart
│   └── usecases/
│       └── get_carousel_items.dart
├── data/ ✅ NEW
│   ├── models/
│   │   └── carousel_item_model.dart
│   ├── datasources/
│   │   └── home_remote_datasource.dart
│   └── repositories/
│       └── home_repository_impl.dart
└── presentation/ ✅ NEW
    ├── bloc/
    │   ├── home_event.dart
    │   ├── home_state.dart
    │   └── home_bloc.dart
    ├── pages/
    │   └── home_page.dart
    └── widgets/
        └── home_carousel_widget.dart
```

---

## 🎯 Quick Commands

### Check Diagnostics
```bash
# Check specific files
flutter analyze lib/features/[feature]/

# Check all files
flutter analyze
```

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/features/[feature]/
```

### Format Code
```bash
# Format all files
dart format .

# Format specific directory
dart format lib/features/[feature]/
```

---

## 📝 Common Patterns

### 1. Create Entity
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

### 2. Create Repository Interface
```dart
import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';

abstract class FeatureRepository {
  Future<Either<Failure, Entity>> getEntity();
  Stream<Either<Failure, List<Entity>>> getEntities();
}
```

### 3. Create Use Case
```dart
import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';

class GetEntity extends UseCase<Entity, NoParams> {
  final FeatureRepository repository;
  
  GetEntity(this.repository);
  
  @override
  Future<Either<Failure, Entity>> call(NoParams params) async {
    return await repository.getEntity();
  }
}
```

### 4. Create Model
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

### 5. Create BLoC
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

### 6. Create Page
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/di/injection_container.dart' as di;

class FeaturePage extends StatelessWidget {
  const FeaturePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<FeatureBloc>()..add(const LoadEntity()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Feature')),
        body: BlocConsumer<FeatureBloc, FeatureState>(
          listener: (context, state) {
            if (state is FeatureError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is FeatureLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is EntityLoaded) {
              return Center(child: Text(state.entity.name));
            }
            
            return const Center(child: Text('No data'));
          },
        ),
      ),
    );
  }
}
```

---

## 🔧 Dependency Injection Template

```dart
void _initFeatureFeature() {
  // Data sources
  sl.registerLazySingleton<FeatureRemoteDataSource>(
    () => FeatureRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<FeatureRepository>(
    () => FeatureRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetEntity(sl()));

  // BLoC
  sl.registerFactory(
    () => FeatureBloc(getEntity: sl()),
  );
}
```

---

## 📚 Documentation Links

### Feature Documentation
- [Authentication Migration](./AUTH_UI_MIGRATION_COMPLETE.md)
- [Forum Migration](./FORUM_UI_MIGRATION_COMPLETE.md)
- [Home Migration](./HOME_MIGRATION_COMPLETE.md)

### Session Documentation
- [Session Progress](./SESSION_PROGRESS_SUMMARY.md)
- [Final Summary](./FINAL_SESSION_SUMMARY.md)

### Architecture Documentation
- [Architecture Diagram](./ARCHITECTURE_DIAGRAM.md)
- [Implementation Summary](./IMPLEMENTATION_SUMMARY.md)
- [Quick Start Guide](./QUICK_START.md)

---

## 🎯 Next Steps

### Immediate
1. Test completed features
2. Start Profile feature migration
3. Continue with Learn feature

### Short Term
- Complete remaining 7 features
- Write comprehensive tests
- Code cleanup and optimization

### Long Term
- Final documentation
- Performance optimization
- Production deployment

---

## 📞 Quick Help

### Common Issues

**Issue**: Compilation errors after creating files
**Solution**: Run `flutter pub get` and restart IDE

**Issue**: BLoC not found in DI container
**Solution**: Check if feature is registered in `injection_container.dart`

**Issue**: Stream not updating UI
**Solution**: Ensure BlocBuilder/BlocConsumer is used, not just BlocListener

**Issue**: Navigation not working
**Solution**: Check if routes are registered in `main.dart`

---

**Last Updated**: November 22, 2024  
**Status**: 3/10 Features Complete (30%)  
**Next**: Profile Feature Migration
