import 'dart:async';

import '../api/generated/export.dart';
import '../errors/api_error.dart';
import 'token_store.dart';
import 'web_lock.dart';

const refreshLockName = 'anafitlab-refresh';

/// Guarantees at most one refresh in flight: per tab through a shared
/// [Future], across tabs through [CrossTabLock] plus re-reading the store
/// inside the lock (the backend revokes the session if a rotated refresh
/// token is presented again).
class RefreshCoordinator {
  RefreshCoordinator({
    required this._store,
    required this._lock,
    required this._callRefresh,
  });

  final TokenStore _store;
  final CrossTabLock _lock;
  final Future<TokenResponse> Function(String refreshToken) _callRefresh;

  Future<TokenResponse>? _inFlight;

  /// Refreshes the session that was using [usedRefreshToken] (the token sent
  /// is always the one re-read from the store inside the lock). Throws
  /// [ApiError] on failure; nothing is written to the store then.
  Future<TokenResponse> refresh(String usedRefreshToken) {
    // Check and set happen synchronously: no await between them.
    final existing = _inFlight;
    if (existing != null) return existing;

    final future = _lock.run(refreshLockName, _refreshLocked);
    _inFlight = future;
    future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    }).ignore();
    return future;
  }

  Future<TokenResponse> _refreshLocked() async {
    final stored = await _store.read();
    // Another tab signed out (or storage is unreadable).
    if (stored == null) throw const ApiError(code: 'INVALID_REFRESH_TOKEN');
    // Always present the stored token: if it differs from the one this tab
    // used, another tab already rotated it, and presenting the old one would
    // revoke the whole session family.
    final response = await _callRefresh(stored.token);
    await _store.write(response.refreshToken, response.refreshTokenExpiresAt);
    return response;
  }
}
