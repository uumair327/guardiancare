import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/report/domain/repositories/report_repository.dart';

/// Use case for deleting a report
class DeleteReport implements UseCase<void, String> {
  final ReportRepository repository;

  DeleteReport(this.repository);

  @override
  Future<Either<Failure, void>> call(String caseName) async {
    return await repository.deleteReport(caseName);
  }
}
