import 'package:dio/dio.dart';

class FieldError {
  const FieldError(this.field, this.code);

  final String field;
  final String code;

  @override
  String toString() => '$field:$code';
}

/// Normalised API failure. Codes `NETWORK` and `INTERNAL_ERROR` are produced
/// locally; every other code comes from the server's problem response.
class ApiError implements Exception {
  const ApiError({
    this.status,
    required this.code,
    this.fieldErrors = const [],
    this.retryAfter,
  });

  final int? status;
  final String code;
  final List<FieldError> fieldErrors;
  final Duration? retryAfter;

  factory ApiError.fromDio(DioException e) {
    final wrapped = e.error;
    if (wrapped is ApiError) return wrapped;

    final response = e.response;
    if (response == null) return const ApiError(code: 'NETWORK');

    final status = response.statusCode;
    final body = response.data;
    if (body is Map && body['code'] is String) {
      final errors = body['errors'];
      final fieldErrors = <FieldError>[];
      if (errors is List) {
        for (final item in errors) {
          if (item is Map &&
              item['field'] is String &&
              item['code'] is String) {
            fieldErrors.add(
              FieldError(item['field'] as String, item['code'] as String),
            );
          }
        }
      }
      final seconds = int.tryParse(response.headers.value('retry-after') ?? '');
      return ApiError(
        status: status,
        code: body['code'] as String,
        fieldErrors: fieldErrors,
        retryAfter: seconds == null ? null : Duration(seconds: seconds),
      );
    }
    return ApiError(status: status, code: 'INTERNAL_ERROR');
  }

  String? fieldCode(String field) {
    for (final f in fieldErrors) {
      if (f.field == field) return f.code;
    }
    return null;
  }

  @override
  String toString() => 'ApiError(code: $code, status: $status)';
}
