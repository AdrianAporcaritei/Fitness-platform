import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/refresh_coordinator.dart';
import '../auth/token_store.dart';
import '../auth/web_lock.dart';
import '../config.dart';
import '../errors/api_error.dart';
import '../locale/locale_controller.dart';
import 'auth_interceptor.dart';
import 'generated/export.dart';

export 'generated/api_client.dart' show ApiClient;

/// Test seam: tests override it with a `FakeApi`; `null` keeps Dio's default.
final httpAdapterProvider = Provider<HttpClientAdapter?>((_) => null);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  final adapter = ref.watch(httpAdapterProvider);
  if (adapter != null) dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      // Lazy: read at request time, never while building this provider.
      auth: () => ref.read(authControllerProvider.notifier),
      languageCode: () => ref.read(localeControllerProvider).languageCode,
    ),
  );
  return dio;
});

final apiProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);

/// `/auth/refresh` is a public path, so the interceptor neither adds a token
/// to this call nor tries to refresh when it fails: no recursion.
final refreshCoordinatorProvider = Provider<RefreshCoordinator>((ref) {
  final api = ref.watch(apiProvider);
  return RefreshCoordinator(
    store: ref.watch(tokenStoreProvider),
    lock: ref.watch(crossTabLockProvider),
    callRefresh: (token) => apiCall(
      () => api.openapi.refresh(body: RefreshRequest(refreshToken: token)),
    ),
  );
});
