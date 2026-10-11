import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

typedef FakeHandler = FutureOr<FakeResponse> Function(RequestOptions r);

class FakeResponse {
  FakeResponse._(
    this.status,
    this.body,
    this.contentType, {
    this.headers = const {},
    this.isNetworkError = false,
  });

  factory FakeResponse.json(int status, Object? body) =>
      FakeResponse._(status, jsonEncode(body), 'application/json');

  factory FakeResponse.empty(int status) => FakeResponse._(status, '', null);

  factory FakeResponse.html(int status, String body) =>
      FakeResponse._(status, body, 'text/html');

  factory FakeResponse.problem(
    int status,
    String code, {
    List<Map<String, String>> errors = const [],
    int? retryAfterSeconds,
  }) => FakeResponse._(
    status,
    jsonEncode({
      'status': status,
      'code': code,
      if (errors.isNotEmpty) 'errors': errors,
    }),
    'application/problem+json',
    headers: {
      if (retryAfterSeconds != null) 'retry-after': ['$retryAfterSeconds'],
    },
  );

  factory FakeResponse.networkError() =>
      FakeResponse._(0, '', null, isNetworkError: true);

  final int status;
  final String body;
  final String? contentType;
  final Map<String, List<String>> headers;
  final bool isNetworkError;
}

/// Dio adapter for tests. Paths are matched with the `/api/v1` prefix removed.
class FakeApi implements HttpClientAdapter {
  final Map<String, FakeHandler> _handlers = {};
  final List<RequestOptions> requests = [];

  static String _key(String method, String path) =>
      '${method.toUpperCase()} $path';

  void on(String method, String path, FakeHandler handler) {
    _handlers[_key(method, path)] = handler;
  }

  int count(String method, String path) {
    final key = _key(method, path);
    return requests
        .where((r) => _key(r.method, _strip(r.uri.path)) == key)
        .length;
  }

  static String _strip(String path) =>
      path.startsWith('/api/v1') ? path.substring('/api/v1'.length) : path;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final path = _strip(options.uri.path);
    final handler = _handlers[_key(options.method, path)];
    if (handler == null) {
      throw TestFailure('FakeApi: no handler for ${options.method} $path');
    }

    final timeout = options.receiveTimeout;
    var pending = Future<FakeResponse>.value(handler(options));
    if (timeout != null && timeout > Duration.zero) {
      pending = pending.timeout(
        timeout,
        onTimeout: () => throw DioException.receiveTimeout(
          timeout: timeout,
          requestOptions: options,
        ),
      );
    }
    final res = await pending;

    if (res.isNetworkError) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'FakeApi network error',
      );
    }
    return ResponseBody.fromString(
      res.body,
      res.status,
      headers: {
        ...res.headers,
        if (res.contentType != null) 'content-type': [res.contentType!],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
