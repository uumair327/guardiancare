import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/report/domain/entities/report_entity.dart';
import 'package:guardiancare/features/report/domain/repositories/report_repository.dart';

/// Use case for loading a saved report
class LoadReport implements UseCase<ReportEntity, String> {

  LoadReport(this.repository);
  final ReportRepository repository;

  @override
  Future<Either<Failure, ReportEntity>> call(String caseName) async {
    return repository.loadReport(caseName);
  }
}
