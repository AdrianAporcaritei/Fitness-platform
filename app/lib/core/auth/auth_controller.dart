import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/generated/export.dart';
import '../errors/api_error.dart';
import '../locale/locale_controller.dart';
import '../time.dart';
import 'auth_state.dart';
import 'session.dart';
import 'token_store.dart';

export 'auth_state.dart';
export 'session.dart';

/// Owns the session: the [AuthState] the router listens to, plus the
/// in-memory [Session] (access token) beside it. Every API failure surfaces
/// as an [ApiError].
class AuthController extends Notifier<AuthState> {
  static const refreshThreshold = Duration(seconds: 60);

  Session? _session;

  Session? get session => _session;

  @override
  AuthState build() => const AuthUnknown();

  OpenapiClient get _api => ref.read(apiProvider).openapi;
  TokenStore get _store => ref.read(tokenStoreProvider);
  DateTime _now() => ref.read(nowProvider)().toUtc();

  /// Resolves the start-up state from the stored refresh token. A network or
  /// server failure keeps the token and yields `AuthUnknown(unreachable)`;
  /// call again to retry.
  Future<void> start() async {
    if (_session != null) return;
    final stored = await _store.read();
    if (stored == null) {
      state = const SignedOut();
      return;
    }
    if (!stored.expiresAt.isAfter(_now())) {
      await _store.clear();
      state = const SignedOut();
      return;
    }
    final TokenResponse response;
    try {
      response = await ref
          .read(refreshCoordinatorProvider)
          .refresh(stored.token);
    } on ApiError catch (e) {
      final reason = _terminalReason(e);
      if (reason == null) {
        state = const AuthUnknown(unreachable: true);
        return;
      }
      await _store.clear();
      state = SignedOut(
        reason: reason == SignedOutReason.suspended ? reason : null,
      );
      return;
    } catch (_) {
      // Unparseable response or similar: never sign out on it.
      state = const AuthUnknown(unreachable: true);
      return;
    }
    _install(response); // the coordinator already persisted it
  }

  /// Leaves the state unchanged on failure (pages show the error).
  Future<void> login(String email, String password) async {
    final response = await apiCall(
      () => _api.login(
        body: LoginRequest(email: email, password: password),
      ),
    );
    await applySession(response);
  }

  Future<void> registerCoach(RegisterCoachRequest request) async {
    await applySession(await apiCall(() => _api.registerCoach(body: request)));
  }

  Future<void> registerClient(RegisterClientRequest request) async {
    await applySession(await apiCall(() => _api.registerClient(body: request)));
  }

  Future<void> confirmPasswordReset(String token, String newPassword) async {
    final response = await apiCall(
      () => _api.confirmPasswordReset(
        body: PasswordResetConfirmRequest(
          token: token,
          newPassword: newPassword,
        ),
      ),
    );
    await applySession(response);
  }

  /// Access token in memory, refresh token persisted, user locale applied,
  /// `SignedIn(user)`.
  Future<void> applySession(TokenResponse response) async {
    _install(response);
    try {
      await _store.write(response.refreshToken, response.refreshTokenExpiresAt);
    } catch (_) {
      // Unwritable storage: the session still works in this tab; a reload
      // will ask for sign-in again.
    }
  }

  void _install(TokenResponse response) {
    _session = Session.from(response);
    final locale = response.user.locale.json;
    if (locale != null) {
      ref.read(localeControllerProvider.notifier).applyUserLocale(locale);
    }
    state = SignedIn(response.user);
  }

  /// The access token to send, refreshed first when it expires within
  /// [refreshThreshold]. `null` when signed out (or the refresh was rejected,
  /// which signs out). Throws [ApiError] (e.g. `NETWORK`) with the session
  /// kept.
  Future<String?> validAccessToken() async {
    final current = _session;
    if (current == null) return null;
    final remaining = current.accessTokenExpiresAt.difference(_now());
    if (remaining > refreshThreshold) return current.accessToken;
    return _refresh(current);
  }

  /// After a 401 for [rejectedAccessToken]: the current token if another
  /// call already replaced it, else a refreshed one. `null` → signed out.
  Future<String?> refreshAfterUnauthorized(String rejectedAccessToken) async {
    final current = _session;
    if (current == null) return null;
    if (current.accessToken != rejectedAccessToken) return current.accessToken;
    return _refresh(current);
  }

  Future<String?> _refresh(Session used) async {
    final TokenResponse response;
    try {
      response = await ref
          .read(refreshCoordinatorProvider)
          .refresh(used.refreshToken);
    } on ApiError catch (e) {
      final reason = _terminalReason(e);
      if (reason == null) rethrow;
      // Only end the session this refresh belonged to (several callers may
      // share one failed refresh; a newer login must survive it).
      if (identical(_session, used)) await _endLocally(reason);
      return _session?.accessToken;
    }

    final current = _session;
    if (identical(current, used)) {
      _install(response);
      return response.accessToken;
    }
    // Another caller sharing this refresh already installed it.
    if (current != null && current.refreshToken == response.refreshToken) {
      return current.accessToken;
    }
    // Signed out or replaced while refreshing: the coordinator persisted a
    // token that no longer matches memory, so put the store back in line.
    if (current == null) {
      await _store.clear();
    } else {
      await _store.write(current.refreshToken, current.refreshTokenExpiresAt);
    }
    return current?.accessToken;
  }

  /// `GET /me` and replace the user (e.g. after email verification).
  Future<void> reloadUser() async {
    final user = await apiCall(() => _api.getMe());
    final current = _session;
    if (current == null) return;
    _session = current.withUser(user);
    state = SignedIn(user);
  }

  /// Signs out locally (memory, store, state), then revokes the refresh
  /// token on the server best-effort. Never throws.
  Future<void> logout({SignedOutReason? reason}) async {
    final token = _session?.refreshToken ?? (await _store.read())?.token;
    await _endLocally(reason);
    if (token == null) return;
    try {
      await apiCall(
        () => _api.logout(body: LogoutRequest(refreshToken: token)),
      );
    } catch (_) {
      // Best effort: the local sign-out already happened.
    }
  }

  Future<void> _endLocally(SignedOutReason? reason) async {
    _session = null;
    await _store.clear();
    state = SignedOut(reason: reason);
  }

  /// `null` → transient (network/server), keep the session.
  static SignedOutReason? _terminalReason(ApiError e) {
    switch (e.code) {
      case 'ACCOUNT_SUSPENDED':
        return SignedOutReason.suspended;
      case 'INVALID_REFRESH_TOKEN':
      case 'REFRESH_TOKEN_REUSED':
        return SignedOutReason.sessionEnded;
    }
    if (e.status == 401 || e.status == 403) return SignedOutReason.sessionEnded;
    return null;
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
