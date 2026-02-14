import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/core/backend/backend.dart';

/// Tests for [BackendResult] type-safe result wrapper.
///
/// These tests verify the BackendResult sealed class works correctly
/// for handling success and failure states.
void main() {
  group('BackendResult', () {
    group('success', () {
      test('can create success with value', () {
        const result = BackendResult.success('test data');
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('can create success with null', () {
        const result = BackendResult<String?>.success(null);
        expect(result.isSuccess, isTrue);
      });

      test('can create success with void', () {
        const result = BackendResult<void>.success(null);
        expect(result.isSuccess, isTrue);
      });

      test('dataOrNull returns value on success', () {
        const result = BackendResult.success(42);
        expect(result.dataOrNull, equals(42));
      });

      test('errorOrNull is null on success', () {
        const result = BackendResult.success('data');
        expect(result.errorOrNull, isNull);
      });
    });

    group('failure', () {
      test('can create failure with error', () {
        const error = BackendError(
          message: 'Test error',
          code: BackendErrorCode.unknown,
        );
        const result = BackendResult<String>.failure(error);
        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('dataOrNull is null on failure', () {
        const error = BackendError(
          message: 'Test error',
          code: BackendErrorCode.unknown,
        );
        const result = BackendResult<String>.failure(error);
        expect(result.dataOrNull, isNull);
      });

      test('errorOrNull returns error on failure', () {
        const error = BackendError(
          message: 'Test error',
          code: BackendErrorCode.notFound,
        );
        const result = BackendResult<String>.failure(error);
        expect(result.errorOrNull, equals(error));
        expect(result.errorOrNull?.code, equals(BackendErrorCode.notFound));
      });
    });

    group('when', () {
      test('calls success callback on success', () {
        const result = BackendResult.success(10);
        var successCalled = false;
        var failureCalled = false;

        result.when(
          success: (data) {
            successCalled = true;
            expect(data, equals(10));
          },
          failure: (_) => failureCalled = true,
        );

        expect(successCalled, isTrue);
        expect(failureCalled, isFalse);
      });

      test('calls failure callback on failure', () {
        const error = BackendError(
          message: 'Error',
          code: BackendErrorCode.permissionDenied,
        );
        const result = BackendResult<int>.failure(error);
        var successCalled = false;
        var failureCalled = false;

        result.when(
          success: (_) => successCalled = true,
          failure: (e) {
            failureCalled = true;
            expect(e.code, equals(BackendErrorCode.permissionDenied));
          },
        );

        expect(successCalled, isFalse);
        expect(failureCalled, isTrue);
      });
    });

    group('map', () {
      test('transforms success value', () {
        const result = BackendResult.success(5);
        final mapped = result.map((data) => data * 2);

        expect(mapped.isSuccess, isTrue);
        expect(mapped.dataOrNull, equals(10));
      });

      test('preserves error on failure', () {
        const error = BackendError(
          message: 'Error',
          code: BackendErrorCode.timeout,
        );
        const result = BackendResult<int>.failure(error);
        final mapped = result.map((data) => data * 2);

        expect(mapped.isFailure, isTrue);
        expect(mapped.errorOrNull?.code, equals(BackendErrorCode.timeout));
      });
    });

    group('getOrThrow', () {
      test('returns data on success', () {
        const result = BackendResult.success('value');
        expect(result.getOrThrow(), equals('value'));
      });

      test('throws on failure', () {
        const error = BackendError(
          message: 'Error',
          code: BackendErrorCode.unknown,
        );
        const result = BackendResult<String>.failure(error);

        expect(() => result.getOrThrow(), throwsA(isA<Exception>()));
      });
    });

    group('getOrElse', () {
      test('returns data on success', () {
        const result = BackendResult.success('value');
        expect(result.getOrElse('default'), equals('value'));
      });

      test('returns default on failure', () {
        const error = BackendError(
          message: 'Error',
          code: BackendErrorCode.unknown,
        );
        const result = BackendResult<String>.failure(error);

        expect(result.getOrElse('default'), equals('default'));
      });
    });
  });

  group('BackendError', () {
    test('has message and code', () {
      const error = BackendError(
        message: 'Test message',
        code: BackendErrorCode.networkError,
      );

      expect(error.message, equals('Test message'));
      expect(error.code, equals(BackendErrorCode.networkError));
    });

    test('can have details', () {
      const error = BackendError(
        message: 'Test',
        code: BackendErrorCode.unknown,
        details: {'key': 'value'},
      );

      expect(error.details, isNotNull);
      expect(error.details?['key'], equals('value'));
    });

    test('can have stack trace', () {
      final stackTrace = StackTrace.current;
      final error = BackendError(
        message: 'Test',
        code: BackendErrorCode.unknown,
        stackTrace: stackTrace,
      );

      expect(error.stackTrace, equals(stackTrace));
    });

    test('toString includes message and code', () {
      const error = BackendError(
        message: 'Test message',
        code: BackendErrorCode.permissionDenied,
      );

      final str = error.toString();
      expect(str, contains('Test message'));
      expect(str, contains('permissionDenied'));
    });
  });

  group('BackendErrorCode', () {
    test('has expected auth codes', () {
      const codes = BackendErrorCode.values;
      expect(codes, contains(BackendErrorCode.authError));
      expect(codes, contains(BackendErrorCode.invalidCredentials));
      expect(codes, contains(BackendErrorCode.userNotFound));
      expect(codes, contains(BackendErrorCode.emailAlreadyInUse));
      expect(codes, contains(BackendErrorCode.weakPassword));
      expect(codes, contains(BackendErrorCode.tokenExpired));
      expect(codes, contains(BackendErrorCode.invalidEmail));
      expect(codes, contains(BackendErrorCode.unauthorized));
    });

    test('has expected data codes', () {
      const codes = BackendErrorCode.values;
      expect(codes, contains(BackendErrorCode.notFound));
      expect(codes, contains(BackendErrorCode.alreadyExists));
      expect(codes, contains(BackendErrorCode.permissionDenied));
      expect(codes, contains(BackendErrorCode.invalidData));
    });

    test('has expected network codes', () {
      const codes = BackendErrorCode.values;
      expect(codes, contains(BackendErrorCode.networkError));
      expect(codes, contains(BackendErrorCode.timeout));
      expect(codes, contains(BackendErrorCode.serverError));
      expect(codes, contains(BackendErrorCode.serviceUnavailable));
    });

    test('has expected operation codes', () {
      const codes = BackendErrorCode.values;
      expect(codes, contains(BackendErrorCode.operationNotAllowed));
      expect(codes, contains(BackendErrorCode.rateLimited));
      expect(codes, contains(BackendErrorCode.unknown));
    });

    test('has expected storage codes', () {
      const codes = BackendErrorCode.values;
      expect(codes, contains(BackendErrorCode.storageFull));
      expect(codes, contains(BackendErrorCode.fileTooLarge));
      expect(codes, contains(BackendErrorCode.invalidFileType));
    });
  });
}
