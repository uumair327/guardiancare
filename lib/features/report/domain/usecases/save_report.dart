import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/report/domain/entities/report_entity.dart';
import 'package:guardiancare/features/report/domain/repositories/report_repository.dart';

/// Use case for saving a report
class SaveReport implements UseCase<void, ReportEntity> {

  SaveReport(this.repository);
  final ReportRepository repository;

  @override
  Future<Either<Failure, void>> call(ReportEntity report) async {
    return repository.saveReport(report);
  }
}
