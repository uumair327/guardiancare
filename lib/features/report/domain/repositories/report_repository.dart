import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/report/domain/entities/report_entity.dart';

/// Report repository interface defining report operations
abstract class ReportRepository {
  /// Create a new report
  Future<Either<Failure, ReportEntity>> createReport({
    required String caseName,
    required List<String> questions,
  });

  /// Load a saved report
  Future<Either<Failure, ReportEntity>> loadReport(String caseName);

  /// Save a report
  Future<Either<Failure, void>> saveReport(ReportEntity report);

  /// Delete a report
  Future<Either<Failure, void>> deleteReport(String caseName);

  /// Get all saved report names
  Future<Either<Failure, List<String>>> getSavedReports();

  /// Check if a report exists
  Future<Either<Failure, bool>> reportExists(String caseName);
}
