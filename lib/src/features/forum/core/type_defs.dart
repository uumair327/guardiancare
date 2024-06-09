import 'package:fpdart/fpdart.dart';
import 'package:guardiancare/src/features/forum/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
