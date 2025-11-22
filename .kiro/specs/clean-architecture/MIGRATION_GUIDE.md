# 🔄 Feature Migration Guide

This guide provides a step-by-step process for migrating existing features to Clean Architecture.

---

## 📋 Pre-Migration Checklist

Before starting migration:
- [ ] Review authentication and forum features as reference
- [ ] Understand the current feature implementation
- [ ] Identify all data sources (Firebase, API, local storage)
- [ ] List all business operations (use cases)
- [ ] Map out UI components and state management

---

## 🎯 Migration Steps

### Step 1: Analyze Current Feature

**Questions to Answer:**
1. What data does this feature work with?
2. What operations can users perform?
3. Where does the data come from? (Firebase, API, local)
4. What state management is currently used?
5. What are the main UI components?

**Create Analysis Document:**
```markdown
# [Feature Name] Analysis

## Current Implementation
- Data sources: [List]
- Operations: [List]
- State management: [Current approach]
- UI components: [List]

## Migration Plan
- Entities needed: [List]
- Use cases needed: [List]
- Data sources needed: [List]
```

---

### Step 2: Create Domain Layer

#### 2.1 Define Entities

**Location:** `lib/features/[feature]/domain/entities/`

**Template:**
```dart
import 'package:equatable/equatable.dart';

class [Entity]Entity extends Equatable {
  final String id;
  final String name;
  // Add other fields
  
  const [Entity]Entity({
    required this.id,
    required this.name,
    // Add other fields
  });

  @override
  List<Object?> get props => [id, name /* other fields */];
}
```

**Example:**
```dart
// lib/features/profile/domain/entities/profile_entity.dart
class ProfileEntity extends Equatable {
  final String userId;
  final String displayName;
  final String email;
  final String? photoURL;
  final String role;
  
  const ProfileEntity({
    required this.userId,
    required this.displayName,
    required this.email,
    this.photoURL,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, displayName, email, photoURL, role];
}
```

#### 2.2 Define Repository Interface

**Location:** `lib/features/[feature]/domain/repositories/`

**Template:**
```dart
import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/[feature]/domain/entities/[entity]_entity.dart';

abstract class [Feature]Repository {
  // Define methods for each operation
  Future<Either<Failure, [Entity]Entity>> get[Entity](String id);
  Future<Either<Failure, void>> update[Entity]([Entity]Entity entity);
  // Add more methods as needed
}
```

#### 2.3 Create Use Cases

**Location:** `lib/features/[feature]/domain/usecases/`

**Template:**
```dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/[feature]/domain/entities/[entity]_entity.dart';
import 'package:guardiancare/features/[feature]/domain/repositories/[feature]_repository.dart';

class [UseCaseName] extends UseCase<[ReturnType], [ParamsType]> {
  final [Feature]Repository repository;

  [UseCaseName](this.repository);

  @override
  Future<Either<Failure, [ReturnType]>> call([ParamsType] params) async {
    return await repository.[methodName](params.[field]);
  }
}

class [ParamsType] extends Equatable {
  final String [field];

  const [ParamsType]({required this.[field]});

  @override
  List<Object> get props => [[field]];
}
```

---

### Step 3: Create Data Layer

#### 3.1 Create Models

**Location:** `lib/features/[feature]/data/models/`

**Template:**
```dart
import 'package:guardiancare/features/[feature]/domain/entities/[entity]_entity.dart';

class [Entity]Model extends [Entity]Entity {
  const [Entity]Model({
    required super.id,
    required super.name,
    // Add other fields
  });

  factory [Entity]Model.fromJson(Map<String, dynamic> json) {
    return [Entity]Model(
      id: json['id'] as String,
      name: json['name'] as String,
      // Map other fields
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // Add other fields
    };
  }

  [Entity]Model copyWith({
    String? id,
    String? name,
    // Add other fields
  }) {
    return [Entity]Model(
      id: id ?? this.id,
      name: name ?? this.name,
      // Add other fields
    );
  }
}
```

#### 3.2 Create Data Sources

**Location:** `lib/features/[feature]/data/datasources/`

**Template:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/[feature]/data/models/[entity]_model.dart';

abstract class [Feature]RemoteDataSource {
  Future<[Entity]Model> get[Entity](String id);
  Future<void> update[Entity]([Entity]Model model);
  // Add more methods
}

class [Feature]RemoteDataSourceImpl implements [Feature]RemoteDataSource {
  final FirebaseFirestore firestore;

  [Feature]RemoteDataSourceImpl({required this.firestore});

  @override
  Future<[Entity]Model> get[Entity](String id) async {
    try {
      final doc = await firestore.collection('[collection]').doc(id).get();
      
      if (!doc.exists) {
        throw NotFoundException('[Entity] not found');
      }

      return [Entity]Model.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException('Failed to get [entity]: ${e.toString()}');
    }
  }

  @override
  Future<void> update[Entity]([Entity]Model model) async {
    try {
      await firestore
          .collection('[collection]')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw ServerException('Failed to update [entity]: ${e.toString()}');
    }
  }
}
```

#### 3.3 Implement Repository

**Location:** `lib/features/[feature]/data/repositories/`

**Template:**
```dart
import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/network/network_info.dart';
import 'package:guardiancare/features/[feature]/data/datasources/[feature]_remote_datasource.dart';
import 'package:guardiancare/features/[feature]/domain/entities/[entity]_entity.dart';
import 'package:guardiancare/features/[feature]/domain/repositories/[feature]_repository.dart';

class [Feature]RepositoryImpl implements [Feature]Repository {
  final [Feature]RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  [Feature]RepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, [Entity]Entity>> get[Entity](String id) async {
    if (await networkInfo.isConnected) {
      try {
        final entity = await remoteDataSource.get[Entity](id);
        return Right(entity);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  // Implement other methods
}
```

---

### Step 4: Create Presentation Layer

#### 4.1 Define Events

**Location:** `lib/features/[feature]/presentation/bloc/[feature]_event.dart`

**Template:**
```dart
import 'package:equatable/equatable.dart';

abstract class [Feature]Event extends Equatable {
  const [Feature]Event();

  @override
  List<Object?> get props => [];
}

class Load[Entity] extends [Feature]Event {
  final String id;

  const Load[Entity](this.id);

  @override
  List<Object> get props => [id];
}

class Update[Entity] extends [Feature]Event {
  final String id;
  final Map<String, dynamic> data;

  const Update[Entity]({required this.id, required this.data});

  @override
  List<Object> get props => [id, data];
}
```

#### 4.2 Define States

**Location:** `lib/features/[feature]/presentation/bloc/[feature]_state.dart`

**Template:**
```dart
import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/[feature]/domain/entities/[entity]_entity.dart';

abstract class [Feature]State extends Equatable {
  const [Feature]State();

  @override
  List<Object?> get props => [];
}

class [Feature]Initial extends [Feature]State {
  const [Feature]Initial();
}

class [Feature]Loading extends [Feature]State {
  const [Feature]Loading();
}

class [Feature]Loaded extends [Feature]State {
  final [Entity]Entity entity;

  const [Feature]Loaded(this.entity);

  @override
  List<Object> get props => [entity];
}

class [Feature]Error extends [Feature]State {
  final String message;
  final String? code;

  const [Feature]Error(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}
```

#### 4.3 Create BLoC

**Location:** `lib/features/[feature]/presentation/bloc/[feature]_bloc.dart`

**Template:**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/[feature]/domain/usecases/[usecase].dart';
import 'package:guardiancare/features/[feature]/presentation/bloc/[feature]_event.dart';
import 'package:guardiancare/features/[feature]/presentation/bloc/[feature]_state.dart';

class [Feature]Bloc extends Bloc<[Feature]Event, [Feature]State> {
  final [UseCase] [useCaseInstance];

  [Feature]Bloc({
    required this.[useCaseInstance],
  }) : super(const [Feature]Initial()) {
    on<Load[Entity]>(_onLoad[Entity]);
    // Add more event handlers
  }

  Future<void> _onLoad[Entity](
    Load[Entity] event,
    Emitter<[Feature]State> emit,
  ) async {
    emit(const [Feature]Loading());

    final result = await [useCaseInstance](
      [Params](id: event.id),
    );

    result.fold(
      (failure) => emit([Feature]Error(failure.message, code: failure.code)),
      (entity) => emit([Feature]Loaded(entity)),
    );
  }
}
```

---

### Step 5: Register Dependencies

**Location:** `lib/core/di/injection_container.dart`

**Add to imports:**
```dart
import 'package:guardiancare/features/[feature]/data/datasources/[feature]_remote_datasource.dart';
import 'package:guardiancare/features/[feature]/data/repositories/[feature]_repository_impl.dart';
import 'package:guardiancare/features/[feature]/domain/repositories/[feature]_repository.dart';
import 'package:guardiancare/features/[feature]/domain/usecases/[usecase].dart';
import 'package:guardiancare/features/[feature]/presentation/bloc/[feature]_bloc.dart';
```

**Add initialization function:**
```dart
void _init[Feature]Feature() {
  // Data sources
  sl.registerLazySingleton<[Feature]RemoteDataSource>(
    () => [Feature]RemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<[Feature]Repository>(
    () => [Feature]RepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => [UseCase](sl()));

  // BLoC
  sl.registerFactory(
    () => [Feature]Bloc([useCaseInstance]: sl()),
  );
}
```

**Call in init():**
```dart
Future<void> init() async {
  // ... existing code
  _init[Feature]Feature();
}
```

---

### Step 6: Update UI

**Use BLoC in pages:**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/di/injection_container.dart' as di;

class [Feature]Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<[Feature]Bloc>()..add(Load[Entity]('id')),
      child: BlocConsumer<[Feature]Bloc, [Feature]State>(
        listener: (context, state) {
          if (state is [Feature]Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is [Feature]Loading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is [Feature]Loaded) {
            return [Feature]Content(entity: state.entity);
          }
          
          return Container();
        },
      ),
    );
  }
}
```

---

### Step 7: Write Tests

**Create test file:**
```dart
// test/features/[feature]/domain/usecases/[usecase]_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([[Feature]Repository])
void main() {
  late [UseCase] useCase;
  late Mock[Feature]Repository mockRepository;

  setUp(() {
    mockRepository = Mock[Feature]Repository();
    useCase = [UseCase](mockRepository);
  });

  test('should return [Entity] when successful', () async {
    // Arrange
    final t[Entity] = [Entity]Entity(/* ... */);
    when(mockRepository.[method](any))
        .thenAnswer((_) async => Right(t[Entity]));

    // Act
    final result = await useCase([Params](/* ... */));

    // Assert
    expect(result, Right(t[Entity]));
    verify(mockRepository.[method](any));
  });
}
```

**Generate mocks:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ✅ Migration Checklist

For each feature:

### Domain Layer
- [ ] Create entities
- [ ] Define repository interface
- [ ] Create use cases
- [ ] Write use case tests

### Data Layer
- [ ] Create models
- [ ] Create data sources
- [ ] Implement repository
- [ ] Write repository tests

### Presentation Layer
- [ ] Define events
- [ ] Define states
- [ ] Create BLoC
- [ ] Write BLoC tests
- [ ] Update UI pages
- [ ] Write widget tests

### Integration
- [ ] Register dependencies in DI
- [ ] Test feature end-to-end
- [ ] Update documentation

---

## 🎯 Best Practices

1. **Start Small**: Migrate one feature at a time
2. **Follow Patterns**: Use authentication/forum as reference
3. **Test As You Go**: Write tests while implementing
4. **Keep It Clean**: Maintain separation of concerns
5. **Document Changes**: Update docs as you migrate
6. **Review Code**: Check for consistency with existing features

---

## 📚 Reference Examples

- **Authentication**: Complete reference implementation
- **Forum**: Stream-based architecture example
- **Testing**: See `test/features/authentication/`

---

## 🆘 Common Issues

### Issue: Circular dependencies
**Solution**: Check dependency order in DI container

### Issue: Stream not updating
**Solution**: Ensure proper stream subscription management in BLoC

### Issue: Tests failing
**Solution**: Verify mock setup and use `thenAnswer` for async methods

### Issue: State not updating
**Solution**: Check that events are being dispatched and BLoC is listening

---

**Next**: Start migrating your next feature using this guide!
