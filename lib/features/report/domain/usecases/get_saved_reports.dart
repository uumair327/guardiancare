import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/report/domain/repositories/report_repository.dart';

/// Use case for getting all saved reports
class GetSavedReports implements UseCase<List<String>, NoParams> {
  final ReportRepository repository;

  GetSavedReports(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getSavedReports();
  }
}
