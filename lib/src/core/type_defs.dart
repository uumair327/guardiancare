import 'package:fpdart/fpdart.dart';
import 'package:guardiancare/src/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
