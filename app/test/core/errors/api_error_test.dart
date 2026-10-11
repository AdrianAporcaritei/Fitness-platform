import 'dart:async';

import 'package:ana_fit_lab/core/errors/api_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';

Dio _dio(FakeApi api, {Duration? receiveTimeout}) => Dio(
  BaseOptions(
    baseUrl: 'http://localhost:8080/api/v1',
    receiveTimeout: receiveTimeout,
  ),
)..httpClientAdapter = api;

Future<DioException> _catch(Dio dio, String path) async {
  try {
    await dio.get<dynamic>(path);
  } on DioException catch (e) {
    return e;
  }
  throw StateError('expected DioException');
}

void main() {
  test('400 validation problem exposes field errors', () async {
    final api = FakeApi()
      ..on(
        'GET',
        '/x',
        (_) => FakeResponse.problem(
          400,
          'VALIDATION_FAILED',
          errors: [
            {'field': 'email', 'code': 'INVALID_EMAIL'},
          ],
        ),
      );
    final err = ApiError.fromDio(await _catch(_dio(api), '/x'));
    expect(err.status, 400);
    expect(err.code, 'VALIDATION_FAILED');
    expect(err.fieldCode('email'), 'INVALID_EMAIL');
    expect(err.fieldCode('other'), isNull);
  });

  test('429 reads Retry-After seconds', () async {
    final api = FakeApi()
      ..on(
        'GET',
        '/x',
        (_) =>
            FakeResponse.problem(429, 'RATE_LIMITED', retryAfterSeconds: 120),
      );
    final err = ApiError.fromDio(await _catch(_dio(api), '/x'));
    expect(err.code, 'RATE_LIMITED');
    expect(err.retryAfter, const Duration(seconds: 120));
  });

  test('connection error maps to NETWORK', () async {
    final api = FakeApi()..on('GET', '/x', (_) => FakeResponse.networkError());
    final err = ApiError.fromDio(await _catch(_dio(api), '/x'));
    expect(err.code, 'NETWORK');
    expect(err.status, isNull);
  });

  test('receive timeout maps to NETWORK', () async {
    final api = FakeApi()
      ..on('GET', '/x', (_) => Completer<FakeResponse>().future);
    final dio = _dio(api, receiveTimeout: const Duration(milliseconds: 20));
    final err = ApiError.fromDio(await _catch(dio, '/x'));
    expect(err.code, 'NETWORK');
    expect(err.status, isNull);
  });

  test('non-problem 500 maps to INTERNAL_ERROR', () async {
    final api = FakeApi()
      ..on('GET', '/x', (_) => FakeResponse.html(500, '<h1>oops</h1>'));
    final err = ApiError.fromDio(await _catch(_dio(api), '/x'));
    expect(err.code, 'INTERNAL_ERROR');
    expect(err.status, 500);
  });

  test('returns an existing ApiError unchanged', () {
    const original = ApiError(code: 'INVALID_REFRESH_TOKEN');
    final e = DioException(
      requestOptions: RequestOptions(path: '/x'),
      error: original,
    );
    expect(identical(ApiError.fromDio(e), original), isTrue);
  });

  test('unmatched request fails with method and path', () async {
    final dio = _dio(FakeApi());
    expect(
      () => dio.get<dynamic>('/nope'),
      throwsA(predicate((e) => e.toString().contains('GET /nope'))),
    );
  });

  test('toString includes code and status', () {
    expect(
      const ApiError(status: 400, code: 'X').toString(),
      allOf(contains('X'), contains('400')),
    );
  });
}
