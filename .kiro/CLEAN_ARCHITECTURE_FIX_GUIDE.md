# Clean Architecture Fix Guide

## Quick Reference: How to Fix Violations

### ❌ WRONG: Direct Firebase Access in Presentation Layer

```dart
// DON'T DO THIS in presentation layer
class MyPage extends StatelessWidget {
  Future<void> fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    final data = await FirebaseFirestore.instance
        .collection('items')
        .get();
  }
}
```

### ✅ CORRECT: Use BLoC Pattern

```dart
// DO THIS instead

// 1. In presentation layer - trigger event
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBloc, MyState>(
      builder: (context, state) {
        if (state is MyInitial) {
          context.read<MyBloc>().add(LoadDataRequested());
        }
        // Handle states
      },
    );
  }
}

// 2. In BLoC - handle event
class MyBloc extends Bloc<MyEvent, MyState> {
  final GetData getData;
  
  MyBloc({required this.getData}) : super(MyInitial()) {
    on<LoadDataRequested>(_onLoadData);
  }
  
  Future<void> _onLoadData(event, emit) async {
    emit(MyLoading());
    final result = await getData(NoParams());
    result.fold(
      (failure) => emit(MyError(failure.message)),
      (data) => emit(MyLoaded(data)),
    );
  }
}

// 3. In domain layer - use case
class GetData {
  final MyRepository repository;
  
  GetData(this.repository);
  
  Future<Either<Failure, List<MyEntity>>> call(NoParams params) {
    return repository.getData();
  }
}

// 4. In data layer - repository
class MyRepositoryImpl implements MyRepository {
  final MyRemoteDataSource remoteDataSource;
  
  MyRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, List<MyEntity>>> getData() async {
    try {
      final models = await remoteDataSource.getData();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

// 5. In data layer - data source
class MyRemoteDataSourceImpl implements MyRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  
  MyRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });
  
  @override
  Future<List<MyModel>> getData() async {
    final user = auth.currentUser;
    if (user == null) throw UnauthorizedException();
    
    final snapshot = await firestore.collection('items').get();
    return snapshot.docs.map((doc) => MyModel.fromJson(doc.data())).toList();
  }
}

// 6. In DI container - register all
void _initMyFeature() {
  // Data sources
  sl.registerLazySingleton<MyRemoteDataSource>(
    () => MyRemoteDataSourceImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<MyRepository>(
    () => MyRepositoryImpl(remoteDataSource: sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => GetData(sl()));
  
  // BLoC
  sl.registerFactory(() => MyBloc(getData: sl()));
}
```

## Specific Fixes Needed

### 1. Quiz Feature

**Files to Update**:
- `lib/features/quiz/presentation/pages/quiz_questions_page.dart`
- `lib/features/quiz/presentation/pages/quiz_page.dart`

**Steps**:
1. Create `SaveQuizResult` use case in domain layer
2. Create `GetQuizQuestions` use case in domain layer
3. Update `QuizBloc` to handle these events
4. Remove direct Firebase calls from pages
5. Use BLoC events instead

**Example**:
```dart
// Instead of:
await FirebaseFirestore.instance.collection('quiz_results').add(data);

// Do:
context.read<QuizBloc>().add(SaveQuizResultRequested(result));
```

### 2. Learn Feature

**Files to Update**:
- `lib/features/learn/presentation/pages/video_page.dart`

**Steps**:
1. Use existing `LearnBloc`
2. Remove direct Firebase calls
3. Use `GetCategories` and `GetVideosByCategory` use cases

**Example**:
```dart
// Instead of:
final snapshot = await FirebaseFirestore.instance.collection('learn').get();

// Do:
context.read<LearnBloc>().add(CategoriesRequested());
// Then use BlocBuilder to display data
```

### 3. Home Feature

**Files to Update**:
- `lib/features/home/presentation/pages/home_page.dart`

**Steps**:
1. Use existing `HomeBloc`
2. Remove direct Firebase calls
3. Use `GetCarouselItems` use case

**Example**:
```dart
// Instead of:
final snapshot = await FirebaseFirestore.instance
    .collection('carousel_items')
    .get();

// Do:
context.read<HomeBloc>().add(LoadCarouselRequested());
```

### 4. Explore Feature

**Files to Update**:
- `lib/features/explore/presentation/pages/explore_page.dart`

**Steps**:
1. Use existing `ExploreBloc`
2. Remove direct Firebase calls
3. Use existing use cases

### 5. Consent Feature

**Files to Update**:
- `lib/features/consent/presentation/pages/consent_form_page.dart`
- `lib/features/consent/presentation/widgets/forgot_parental_key_dialog.dart`
- `lib/features/consent/presentation/pages/enhanced_consent_form_page.dart`

**Steps**:
1. Create `ConsentLocalDataSource` for SharedPreferences
2. Update `ConsentBloc` to handle parental key operations
3. Remove direct SharedPreferences and Firebase calls
4. Use BLoC events

## Testing After Fixes

### Unit Tests Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockMyRepository extends Mock implements MyRepository {}

void main() {
  late GetData useCase;
  late MockMyRepository mockRepository;

  setUp(() {
    mockRepository = MockMyRepository();
    useCase = GetData(mockRepository);
  });

  test('should get data from repository', () async {
    // Arrange
    final testData = [MyEntity(id: '1', name: 'Test')];
    when(mockRepository.getData())
        .thenAnswer((_) async => Right(testData));

    // Act
    final result = await useCase(NoParams());

    // Assert
    expect(result, Right(testData));
    verify(mockRepository.getData());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### Widget Tests Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

class MockMyBloc extends Mock implements MyBloc {}

void main() {
  late MockMyBloc mockBloc;

  setUp(() {
    mockBloc = MockMyBloc();
  });

  testWidgets('should display data when loaded', (tester) async {
    // Arrange
    when(mockBloc.state).thenReturn(MyLoaded(testData));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(MyLoaded(testData)));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MyBloc>.value(
          value: mockBloc,
          child: MyPage(),
        ),
      ),
    );

    // Assert
    expect(find.text('Test Data'), findsOneWidget);
  });
}
```

## Checklist for Each Feature

- [ ] Remove all `FirebaseAuth.instance` from presentation layer
- [ ] Remove all `FirebaseFirestore.instance` from presentation layer
- [ ] Remove all `SharedPreferences.getInstance()` from presentation layer
- [ ] Create necessary use cases in domain layer
- [ ] Create necessary data sources in data layer
- [ ] Update BLoC to handle new events
- [ ] Update UI to use BLoC events/states
- [ ] Register all dependencies in DI container
- [ ] Add unit tests for use cases
- [ ] Add widget tests for UI
- [ ] Verify no direct service access in presentation layer

## Benefits After Fixes

1. **Testability**: Can mock repositories and test business logic
2. **Flexibility**: Easy to swap Firebase for another backend
3. **Maintainability**: Clear separation of concerns
4. **Scalability**: Easy to add new features
5. **Team Collaboration**: Clear architecture everyone understands
6. **Industry Standard**: Follows best practices

## Quick Verification

Run this command to check for violations:

```bash
# Check for Firebase in presentation layer
grep -r "FirebaseAuth.instance\|FirebaseFirestore.instance" lib/features/*/presentation/

# Check for SharedPreferences in presentation layer
grep -r "SharedPreferences.getInstance" lib/features/*/presentation/

# Should return no results after fixes
```

## Need Help?

Refer to these working examples in the codebase:
- ✅ Authentication feature (properly uses BLoC)
- ✅ Profile feature (properly uses BLoC)
- ✅ Forum feature (properly uses BLoC)
- ✅ Report feature (properly uses BLoC)

These features demonstrate the correct Clean Architecture pattern!

---

**Remember**: Presentation layer should ONLY:
- Display UI
- Handle user input
- Trigger BLoC events
- React to BLoC states

**Never**:
- Access Firebase directly
- Access SharedPreferences directly
- Contain business logic
- Fetch data directly
