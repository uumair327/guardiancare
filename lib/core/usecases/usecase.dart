import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';

/// Base class for all use cases
///
/// [Result] is the return type
/// [Params] is the parameter type
// ignore: one_member_abstracts
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

/// Base class for stream-based use cases (for real-time updates)
///
/// [Result] is the return type
/// [Params] is the parameter type
// ignore: one_member_abstracts
abstract class StreamUseCase<Result, Params> {
  Stream<Either<Failure, Result>> call(Params params);
}

/// Use case for operations that don't require parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
