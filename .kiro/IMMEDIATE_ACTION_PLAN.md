# Immediate Action Plan - Clean Architecture Compliance
**Priority:** 🔴 CRITICAL  
**Timeline:** 2-3 weeks for Phase 1  
**Goal:** Fix critical violations and establish industry-level code standards

---

## 🎯 PHASE 1: QUIZ FEATURE REFACTORING (Week 1)

### Day 1-2: Domain Layer Setup

#### 1. Create Domain Entities
```dart
// lib/features/quiz/domain/entities/quiz.dart
class Quiz {
  final String id;
  final String name;
  final String thumbnail;
  final bool isActive;
  
  Quiz({required this.id, required this.name, required this.thumbnail, required this.isActive});
}

// lib/features/quiz/domain/entities/question.dart
class Question {
  final String id;
  final String quizName;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  
  Question({...});
}

// lib/features/quiz/domain/entities/quiz_result.dart
class QuizResult {
  final String userId;
  final String quizName;
  final int score;
  final int totalQuestions;
  final List<String> categories;
  final DateTime timestamp;
  
  QuizResult({...});
}
```

#### 2. Create Repository Interface
```dart
// lib/features/quiz/domain/repositories/quiz_repository.dart
abstract class QuizRepository {
  Future<Either<Failure, List<Quiz>>> getQuizzes();
  Future<Either<Failure, List<Question>>> getQuestions(String quizName);
  Future<Either<Failure, void>> saveQuizResult(QuizResult result);
  Future<Either<Failure, void>> generateRecommendations(List<String> categories);
}
```

#### 3. Create Use Cases
```dart
// lib/features/quiz/domain/usecases/get_quizzes.dart
class GetQuizzes implements UseCase<List<Quiz>, NoParams> {
  final QuizRepository repository;
  GetQuizzes(this.repository);
  
  @override
  Future<Either<Failure, List<Quiz>>> call(NoParams params) async {
    return await repository.getQuizzes();
  }
}

// lib/features/quiz/domain/usecases/get_questions.dart
class GetQuestions implements UseCase<List<Question>, String> {
  final QuizRepository repository;
  GetQuestions(this.repository);
  
  @override
  Future<Either<Failure, List<Question>>> call(String quizName) async {
    return await repository.getQuestions(quizName);
  }
}

// lib/features/quiz/domain/usecases/save_quiz_result.dart
class SaveQuizResult implements UseCase<void, QuizResult> {
  final QuizRepository repository;
  SaveQuizResult(this.repository);
  
  @override
  Future<Either<Failure, void>> call(QuizResult result) async {
    return await repository.saveQuizResult(result);
  }
}

// lib/features/quiz/domain/usecases/process_quiz_completion.dart
class ProcessQuizCompletion implements UseCase<void, ProcessQuizParams> {
  final QuizRepository repository;
  ProcessQuizCompletion(this.repository);
  
  @override
  Future<Either<Failure, void>> call(ProcessQuizParams params) async {
    // Save quiz result
    await repository.saveQuizResult(params.result);
    // Generate recommendations
    return await repository.generateRecommendations(params.categories);
  }
}
```

### Day 3-4: Data Layer Implementation

#### 1. Create Models
```dart
// lib/features/quiz/data/models/quiz_model.dart
class QuizModel extends Quiz {
  QuizModel({...}) : super(...);
  
  factory QuizModel.fromFirestore(DocumentSnapshot doc) {...}
  Map<String, dynamic> toFirestore() {...}
}

// Similar for QuestionModel and QuizResultModel
```

#### 2. Create Remote Data Source
```dart
// lib/features/quiz/data/datasources/quiz_remote_datasource.dart
abstract class QuizRemoteDataSource {
  Future<List<QuizModel>> getQuizzes();
  Future<List<QuestionModel>> getQuestions(String quizName);
  Future<void> saveQuizResult(QuizResultModel result);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  
  QuizRemoteDataSourceImpl({required this.firestore, required this.auth});
  
  @override
  Future<List<QuizModel>> getQuizzes() async {
    final snapshot = await firestore.collection('quizes').get();
    return snapshot.docs
        .map((doc) => QuizModel.fromFirestore(doc))
        .where((quiz) => quiz.isActive)
        .toList();
  }
  
  // Implement other methods...
}
```

#### 3. Create Repository Implementation
```dart
// lib/features/quiz/data/repositories/quiz_repository_impl.dart
class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  QuizRepositoryImpl({required this.remoteDataSource, required this.networkInfo});
  
  @override
  Future<Either<Failure, List<Quiz>>> getQuizzes() async {
    if (await networkInfo.isConnected) {
      try {
        final quizzes = await remoteDataSource.getQuizzes();
        return Right(quizzes);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
  
  // Implement other methods...
}
```

### Day 5-6: Presentation Layer with BLoC

#### 1. Create BLoC Events
```dart
// lib/features/quiz/presentation/bloc/quiz_event.dart
abstract class QuizEvent extends Equatable {}

class LoadQuizzesEvent extends QuizEvent {
  @override
  List<Object> get props => [];
}

class LoadQuestionsEvent extends QuizEvent {
  final String quizName;
  LoadQuestionsEvent(this.quizName);
  @override
  List<Object> get props => [quizName];
}

class SubmitAnswerEvent extends QuizEvent {
  final int questionIndex;
  final int selectedOption;
  SubmitAnswerEvent(this.questionIndex, this.selectedOption);
  @override
  List<Object> get props => [questionIndex, selectedOption];
}

class CompleteQuizEvent extends QuizEvent {
  @override
  List<Object> get props => [];
}
```

#### 2. Create BLoC States
```dart
// lib/features/quiz/presentation/bloc/quiz_state.dart
abstract class QuizState extends Equatable {}

class QuizInitial extends QuizState {
  @override
  List<Object> get props => [];
}

class QuizLoading extends QuizState {
  @override
  List<Object> get props => [];
}

class QuizzesLoaded extends QuizState {
  final List<Quiz> quizzes;
  QuizzesLoaded(this.quizzes);
  @override
  List<Object> get props => [quizzes];
}

class QuestionsLoaded extends QuizState {
  final List<Question> questions;
  final int currentIndex;
  final int correctAnswers;
  final bool showFeedback;
  
  QuestionsLoaded({...});
  @override
  List<Object> get props => [questions, currentIndex, correctAnswers, showFeedback];
}

class QuizCompleted extends QuizState {
  final int score;
  final int totalQuestions;
  QuizCompleted(this.score, this.totalQuestions);
  @override
  List<Object> get props => [score, totalQuestions];
}

class QuizError extends QuizState {
  final String message;
  QuizError(this.message);
  @override
  List<Object> get props => [message];
}
```

#### 3. Create BLoC
```dart
// lib/features/quiz/presentation/bloc/quiz_bloc.dart
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetQuizzes getQuizzes;
  final GetQuestions getQuestions;
  final ProcessQuizCompletion processQuizCompletion;
  
  QuizBloc({
    required this.getQuizzes,
    required this.getQuestions,
    required this.processQuizCompletion,
  }) : super(QuizInitial()) {
    on<LoadQuizzesEvent>(_onLoadQuizzes);
    on<LoadQuestionsEvent>(_onLoadQuestions);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<CompleteQuizEvent>(_onCompleteQuiz);
  }
  
  Future<void> _onLoadQuizzes(LoadQuizzesEvent event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    final result = await getQuizzes(NoParams());
    result.fold(
      (failure) => emit(QuizError(_mapFailureToMessage(failure))),
      (quizzes) => emit(QuizzesLoaded(quizzes)),
    );
  }
  
  // Implement other event handlers...
}
```

#### 4. Refactor UI Pages
```dart
// lib/features/quiz/presentation/pages/quiz_page.dart
class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<QuizBloc>()..add(LoadQuizzesEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: BlocBuilder<QuizBloc, QuizState>(
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QuizzesLoaded) {
              return _buildQuizList(context, state.quizzes);
            } else if (state is QuizError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
  
  Widget _buildQuizList(BuildContext context, List<Quiz> quizzes) {
    return ListView.builder(
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return QuizTile(
          quiz: quiz,
          onTap: () {
            context.read<QuizBloc>().add(LoadQuestionsEvent(quiz.name));
            context.push('/quiz-questions');
          },
        );
      },
    );
  }
}
```

### Day 7: Dependency Injection & Testing

#### 1. Update DI Container
```dart
// lib/core/di/injection_container.dart
void init() {
  // BLoC
  sl.registerFactory(() => QuizBloc(
    getQuizzes: sl(),
    getQuestions: sl(),
    processQuizCompletion: sl(),
  ));
  
  // Use Cases
  sl.registerLazySingleton(() => GetQuizzes(sl()));
  sl.registerLazySingleton(() => GetQuestions(sl()));
  sl.registerLazySingleton(() => SaveQuizResult(sl()));
  sl.registerLazySingleton(() => ProcessQuizCompletion(sl()));
  
  // Repository
  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Data Source
  sl.registerLazySingleton<QuizRemoteDataSource>(
    () => QuizRemoteDataSourceImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );
}
```

#### 2. Write Unit Tests
```dart
// test/features/quiz/domain/usecases/get_quizzes_test.dart
void main() {
  late GetQuizzes usecase;
  late MockQuizRepository mockRepository;
  
  setUp(() {
    mockRepository = MockQuizRepository();
    usecase = GetQuizzes(mockRepository);
  });
  
  test('should get quizzes from repository', () async {
    // arrange
    final tQuizzes = [Quiz(...)];
    when(mockRepository.getQuizzes())
        .thenAnswer((_) async => Right(tQuizzes));
    
    // act
    final result = await usecase(NoParams());
    
    // assert
    expect(result, Right(tQuizzes));
    verify(mockRepository.getQuizzes());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

---

## 🎯 PHASE 2: CONSENT FEATURE REFACTORING (Week 2)

### Similar structure as Quiz feature:
1. Create domain entities (Consent, ParentalKey)
2. Create repository interface
3. Create use cases (SaveConsent, VerifyKey, ResetKey)
4. Implement data layer
5. Create BLoC for state management
6. Refactor UI pages
7. Write tests

---

## 🎯 PHASE 3: REMAINING FEATURES (Week 3)

### Priority Order:
1. **Learn Feature** (Video browsing)
2. **Explore Feature** (Recommendations)
3. **Home Feature** (Carousel)

---

## 📋 CHECKLIST FOR EACH FEATURE

- [ ] Domain entities created
- [ ] Repository interface defined
- [ ] Use cases implemented
- [ ] Data models created
- [ ] Remote data source implemented
- [ ] Repository implementation completed
- [ ] BLoC events defined
- [ ] BLoC states defined
- [ ] BLoC implemented
- [ ] UI refactored to use BLoC
- [ ] Dependency injection configured
- [ ] Unit tests written
- [ ] Widget tests written
- [ ] Integration tests written
- [ ] Documentation updated

---

## 🛠️ REQUIRED DEPENDENCIES

Add to `pubspec.yaml`:
```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Functional Programming
  dartz: ^0.10.1
  
dev_dependencies:
  # Testing
  mockito: ^5.4.2
  bloc_test: ^9.1.4
  build_runner: ^2.4.6
```

---

## 📊 SUCCESS METRICS

### Before Refactoring
- ❌ 7 files with direct Firebase access
- ❌ 0% test coverage
- ❌ No state management
- ❌ Business logic in UI

### After Refactoring
- ✅ 0 files with direct Firebase access
- ✅ 80%+ test coverage
- ✅ BLoC state management
- ✅ Clean separation of concerns

---

## 🚀 GETTING STARTED

### Step 1: Create Branch
```bash
git checkout -b feature/clean-architecture-refactor
```

### Step 2: Install Dependencies
```bash
flutter pub add flutter_bloc equatable dartz
flutter pub add --dev mockito bloc_test build_runner
```

### Step 3: Start with Quiz Feature
Follow the Day 1-7 plan above

### Step 4: Test Thoroughly
```bash
flutter test
flutter test --coverage
```

### Step 5: Review & Merge
- Code review with team
- Verify all tests pass
- Merge to main branch

---

## 💡 TIPS FOR SUCCESS

1. **One feature at a time** - Don't try to refactor everything at once
2. **Test as you go** - Write tests immediately after implementing
3. **Keep UI working** - Ensure app remains functional during refactoring
4. **Document changes** - Update documentation as you refactor
5. **Pair programming** - Work with another developer for complex parts
6. **Regular commits** - Commit after each completed step
7. **Ask for help** - Don't hesitate to ask questions

---

## 📞 SUPPORT

If you need help with any step:
1. Review Clean Architecture documentation
2. Check BLoC pattern examples
3. Consult with senior developers
4. Use Kiro AI for code generation assistance

---

**Created:** November 23, 2025  
**Status:** Ready to Execute  
**Priority:** CRITICAL
