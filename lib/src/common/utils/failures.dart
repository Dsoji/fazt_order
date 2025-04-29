abstract class Failure {
  Failure(this.message);
  final String message;
}

class ApiFailure extends Failure {
  ApiFailure({String message = ''}) : super(message);

  @override
  String toString() => message;
}

class CacheFailure extends Failure {
  CacheFailure({String message = ''}) : super(message);

  @override
  String toString() => message;
}

class FailureHandler implements Exception {
  final String message;
  final int? code;
  final Object? exception;
  final StackTrace stackTrace;

  FailureHandler({
    required this.message,
    required this.stackTrace,
    this.code,
    this.exception,
  });

  @override
  String toString() {
    return 'FailureHandler(message: $message, code: $code, exception: $exception, stackTrace: $stackTrace)';
  }
}
