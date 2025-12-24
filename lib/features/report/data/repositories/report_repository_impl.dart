import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/error.dart';
import 'package:guardiancare/features/report/data/datasources/report_local_datasource.dart';
import 'package:guardiancare/features/report/data/models/report_model.dart';
import 'package:guardiancare/features/report/domain/entities/report_entity.dart';
import 'package:guardiancare/features/report/domain/repositories/report_repository.dart';

/// Implementation of ReportRepository
class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource localDataSource;

  ReportRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ReportEntity>> createReport({
    required String caseName,
    required List<String> questions,
  }) async {
    try {
      // Initialize all answers to false
      final answers = <int, bool>{};
      for (int i = 0; i < questions.length; i++) {
        answers[i] = false;
      }

      final report = ReportModel(
        caseName: caseName,
        questions: questions,
        answers: answers,
        isDirty: false,
      );

      return Right(report);
    } catch (e) {
      return Left(CacheFailure('Failed to create report: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> loadReport(String caseName) async {
    try {
      // Note: Questions need to be provided separately as they're not stored
      // This is a limitation of the current implementation
      // In a real app, questions would be stored or fetched from a service
      final report = await localDataSource.loadReport(caseName, []);
      return Right(report);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to load report: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveReport(ReportEntity report) async {
    try {
      final reportModel = ReportModel.fromEntity(report);
      await localDataSource.saveReport(reportModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to save report: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReport(String caseName) async {
    try {
      await localDataSource.deleteReport(caseName);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to delete report: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSavedReports() async {
    try {
      final reports = await localDataSource.getSavedReportNames();
      return Right(reports);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get saved reports: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> reportExists(String caseName) async {
    try {
      final exists = await localDataSource.reportExists(caseName);
      return Right(exists);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
          CacheFailure('Failed to check report existence: ${e.toString()}'));
    }
  }
}
