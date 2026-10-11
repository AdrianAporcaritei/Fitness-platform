// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'openapi/openapi_client.dart';

/// Ana Fit Lab API `v0.1.0`.
///
/// Hand-written contract; each endpoint is added here before it is implemented. Errors follow RFC 9457 (application/problem+json) with a stable machine-readable `code`.
///
class ApiClient {
  ApiClient(
    Dio dio, {
    String? baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.1.0';

  OpenapiClient? _openapi;

  OpenapiClient get openapi => _openapi ??= OpenapiClient(_dio, baseUrl: _baseUrl);
}
