import '../api/generated/export.dart';

/// The signed-in session. Only [refreshToken] and its expiry are persisted
/// (by the token store); the access token lives in memory.
class Session {
  const Session({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  factory Session.from(TokenResponse t) => Session(
    accessToken: t.accessToken,
    accessTokenExpiresAt: t.accessTokenExpiresAt.toUtc(),
    refreshToken: t.refreshToken,
    refreshTokenExpiresAt: t.refreshTokenExpiresAt.toUtc(),
    user: t.user,
  );

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final UserResponse user;

  Session withUser(UserResponse user) => Session(
    accessToken: accessToken,
    accessTokenExpiresAt: accessTokenExpiresAt,
    refreshToken: refreshToken,
    refreshTokenExpiresAt: refreshTokenExpiresAt,
    user: user,
  );
}
