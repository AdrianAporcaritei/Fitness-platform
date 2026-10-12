import 'package:dio/dio.dart';

import '../auth/auth_controller.dart';
import '../errors/api_error.dart';

/// Adds `Accept-Language` to every call and the bearer token to
/// authenticated ones; refreshes proactively (through [AuthController]) and
/// retries a 401 once after a refresh. Errors leave as a [DioException] whose
/// `error` is an [ApiError] (unwrap with [apiCall]).
///
/// Not a `QueuedInterceptor`: requests run in parallel, and the single-flight
/// guarantee lives in the refresh coordinator.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._dio,
    required this._auth,
    required this._languageCode,
  });

  final Dio _dio;

  /// Read lazily at request time: the controller is not built (and the
  /// provider graph has no cycle) until a request needs it.
  final AuthController Function() _auth;
  final String Function() _languageCode;

  static const retriedKey = 'retried';
  static const _authorization = 'Authorization';

  /// Exact public endpoints; `/auth/logout-all` and `/auth/verify-email/resend`
  /// are authenticated.
  static const _publicExact = {
    '/auth/login',
    '/auth/refresh',
    '/auth/logout',
    '/auth/verify-email',
  };
  static const _publicPrefixes = [
    '/auth/register/',
    '/auth/password-reset/',
    '/invites/',
  ];

  static bool isPublicPath(String path) =>
      _publicExact.contains(path) || _publicPrefixes.any(path.startsWith);

  /// Request path relative to the base URL (`/me`, not `/api/v1/me`).
  static String _relativePath(RequestOptions options) {
    final path = options.uri.path;
    final basePath = Uri.parse(options.baseUrl).path;
    if (basePath.isNotEmpty && basePath != '/' && path.startsWith(basePath)) {
      return path.substring(basePath.length);
    }
    return path;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Every exit of _onRequest calls the handler; a throw before that
    // (e.g. reading the locale) must still fail the request, not hang it.
    _onRequest(options, handler).catchError(
      (Object e) => handler.reject(
        DioException(requestOptions: options, error: _asApiError(e)),
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept-Language'] = _languageCode();
    options.headers.remove(_authorization);
    if (isPublicPath(_relativePath(options))) return handler.next(options);

    final String? token;
    try {
      token = await _auth().validAccessToken();
    } catch (e) {
      return handler.reject(
        DioException(requestOptions: options, error: _asApiError(e)),
      );
    }
    if (token != null) options.headers[_authorization] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _onError(err, handler).catchError(
      (Object e) => handler.next(err.copyWith(error: _asApiError(e))),
    );
  }

  static ApiError _asApiError(Object e) =>
      e is ApiError ? e : const ApiError(code: 'INTERNAL_ERROR');

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final apiError = ApiError.fromDio(err);
    final wrapped = err.copyWith(error: apiError);
    final options = err.requestOptions;
    final sentToken = _bearer(options);

    if (apiError.status != 401 ||
        sentToken == null ||
        isPublicPath(_relativePath(options))) {
      return handler.next(wrapped);
    }

    if (options.extra[retriedKey] == true) {
      // Rejected even with a freshly refreshed token.
      await _auth().logout(reason: SignedOutReason.sessionEnded);
      return handler.next(wrapped);
    }

    final String? newToken;
    try {
      newToken = await _auth().refreshAfterUnauthorized(sentToken);
    } catch (e) {
      return handler.next(err.copyWith(error: _asApiError(e)));
    }
    // The controller already signed out.
    if (newToken == null) return handler.next(wrapped);

    try {
      // onRequest attaches the current (new) token again.
      final retry = options.copyWith(
        extra: {...options.extra, retriedKey: true},
      );
      handler.resolve(await _dio.fetch<dynamic>(retry));
    } on DioException catch (e) {
      // Already converted by this interceptor's onError for the retry.
      handler.next(e);
    }
  }

  static String? _bearer(RequestOptions options) {
    final value = options.headers[_authorization];
    if (value is String && value.startsWith('Bearer ')) {
      return value.substring('Bearer '.length);
    }
    return null;
  }
}
