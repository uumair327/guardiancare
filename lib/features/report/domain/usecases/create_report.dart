import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/report/domain/entities/report_entity.dart';
import 'package:guardiancare/features/report/domain/repositories/report_repository.dart';

/// Parameters for creating a report
class CreateReportParams extends Equatable {

  const CreateReportParams({
    required this.caseName,
    required this.questions,
  });
  final String caseName;
  final List<String> questions;

  @override
  List<Object> get props => [caseName, questions];
}

/// Use case for creating a new report
class CreateReport implements UseCase<ReportEntity, CreateReportParams> {

  CreateReport(this.repository);
  final ReportRepository repository;

  @override
  Future<Either<Failure, ReportEntity>> call(CreateReportParams params) async {
    return repository.createReport(
      caseName: params.caseName,
      questions: params.questions,
    );
  }
}
