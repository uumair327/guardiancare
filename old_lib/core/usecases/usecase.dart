import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';

/// Base class for all use cases
/// 
/// [Type] is the return type
/// [Params] is the parameter type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for stream-based use cases (for real-time updates)
/// 
/// [Type] is the return type
/// [Params] is the parameter type
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Use case for operations that don't require parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
