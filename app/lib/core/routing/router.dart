import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/join/join_page.dart';
import '../../features/auth/login/login_page.dart';
import '../../features/auth/password_reset/forgot_password_page.dart';
import '../../features/auth/password_reset/reset_password_page.dart';
import '../../features/auth/register_coach/register_coach_page.dart';
import '../../features/auth/verify_email/verify_email_page.dart';
import '../../features/home/home_page.dart';
import '../auth/auth_controller.dart';
import 'splash_page.dart';

abstract final class Routes {
  static const root = '/';
  static const loading = '/loading';
  static const login = '/login';
  static const register = '/register';
  static const join = '/join';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const home = '/home';

  /// `/login?from=<location>`, the target after sign-in.
  static String loginFrom(String from) =>
      Uri(path: login, queryParameters: {'from': from}).toString();
}

const _signedOutOnly = {Routes.login, Routes.register, Routes.forgotPassword};
const _signedInOnly = {Routes.home};
const _known = {
  Routes.root,
  Routes.loading,
  Routes.login,
  Routes.register,
  Routes.verifyEmail,
  Routes.forgotPassword,
  Routes.resetPassword,
  Routes.home,
};
final _joinPath = RegExp(r'^/join/[^/]+$');

/// [from] when it is an in-app location (a single leading `/`, no scheme,
/// no backslash); otherwise `null`. The only place a `from`/`to` target is
/// validated (no open redirect).
String? safeFrom(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  // Browsers treat `\` like `/`, so `/\evil.com` is protocol-relative.
  if (from.contains(r'\')) return null;
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  return from;
}

/// The single guard (spec §6). `null` keeps [uri]; go_router re-applies it
/// to every location it returns, so targets pass through the guards too.
@visibleForTesting
String? authRedirect(AuthState auth, Uri uri) {
  final path = uri.path;
  if (!_known.contains(path) && !_joinPath.hasMatch(path)) return Routes.root;

  if (auth is AuthUnknown) {
    if (path == Routes.loading) return null;
    return Uri(
      path: Routes.loading,
      queryParameters: {'to': uri.toString()},
    ).toString();
  }

  final signedIn = auth is SignedIn;
  switch (path) {
    case Routes.loading:
      final to = safeFrom(uri.queryParameters['to']);
      if (to == null || Uri.parse(to).path == Routes.loading) {
        return Routes.root;
      }
      return to;
    case Routes.root:
      return signedIn ? Routes.home : Routes.login;
    case Routes.login when signedIn:
      return safeFrom(uri.queryParameters['from']) ?? Routes.home;
  }
  if (signedIn && _signedOutOnly.contains(path)) return Routes.home;
  if (!signedIn && _signedInOnly.contains(path)) {
    return Routes.loginFrom(uri.toString());
  }
  return null;
}

/// Notifies the router whenever the auth state changes.
class _AuthRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Created once; auth changes re-run the redirect via `refreshListenable`.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh();
  ref.listen(authControllerProvider, (_, _) => refresh.notify());

  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (_, state) =>
        authRedirect(ref.read(authControllerProvider), state.uri),
    routes: [
      // Never shown: the guard always sends `/` elsewhere.
      GoRoute(path: Routes.root, builder: (_, _) => const SplashPage()),
      GoRoute(path: Routes.loading, builder: (_, _) => const SplashPage()),
      GoRoute(
        path: Routes.login,
        builder: (_, s) => LoginPage(from: s.uri.queryParameters['from']),
      ),
      GoRoute(
        path: Routes.register,
        builder: (_, _) => const RegisterCoachPage(),
      ),
      GoRoute(
        path: '${Routes.join}/:code',
        builder: (_, s) => JoinPage(code: s.pathParameters['code']!),
      ),
      GoRoute(
        path: Routes.verifyEmail,
        builder: (_, s) =>
            VerifyEmailPage(token: s.uri.queryParameters['token']),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, s) =>
            ResetPasswordPage(token: s.uri.queryParameters['token']),
      ),
      GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
