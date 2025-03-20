// api_response.dart
class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final int? statusCode;
  final Exception? exception;
  final StackTrace? stackTrace;
  final bool isSuccess;

  ApiResponse._({
    this.data,
    this.errorMessage,
    this.statusCode,
    this.exception,
    this.stackTrace,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data, [int? statusCode]) => ApiResponse<T>._(
    data: data,
    isSuccess: true,
    statusCode: statusCode,
  );

  factory ApiResponse.failure({
    String? errorMessage,
    int? statusCode,
    Exception? exception,
    StackTrace? stackTrace,
  }) =>
      ApiResponse<T>._(
        errorMessage: errorMessage ?? exception?.toString(),
        statusCode: statusCode,
        exception: exception,
        stackTrace: stackTrace,
        isSuccess: false,
      );

  bool get hasData => data != null;
  bool get hasError => !isSuccess;

  @override
  String toString() => 'ApiResponse('
      'isSuccess: $isSuccess, '
      'statusCode: $statusCode, '
      'data: $data, '
      'error: $errorMessage)';
}