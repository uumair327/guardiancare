import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';

class SendPasswordResetEmail extends UseCase<void, PasswordResetParams> {
  final AuthRepository repository;

  SendPasswordResetEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(PasswordResetParams params) async {
    return await repository.sendPasswordResetEmail(params.email);
  }
}

class PasswordResetParams extends Equatable {
  final String email;

  const PasswordResetParams({required this.email});

  @override
  List<Object> get props => [email];
}
