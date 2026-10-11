import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredRefreshToken {
  const StoredRefreshToken(this.token, this.expiresAt);

  final String token;
  final DateTime expiresAt;
}

/// Persists only the refresh token and its expiry; the access token stays in
/// memory (spec F3).
abstract interface class TokenStore {
  Future<StoredRefreshToken?> read();
  Future<void> write(String token, DateTime expiresAt);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const tokenKey = 'refresh_token';
  static const expiresAtKey = 'refresh_token_expires_at';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredRefreshToken?> read() async {
    try {
      final token = await _storage.read(key: tokenKey);
      final rawExpiry = await _storage.read(key: expiresAtKey);
      if (token == null || token.isEmpty || rawExpiry == null) return null;
      final expiresAt = DateTime.tryParse(rawExpiry);
      if (expiresAt == null) return null;
      return StoredRefreshToken(token, expiresAt.toUtc());
    } catch (_) {
      // Corrupted storage or a decryption failure (web) reads as "no token".
      return null;
    }
  }

  @override
  Future<void> write(String token, DateTime expiresAt) async {
    await _storage.write(key: tokenKey, value: token);
    await _storage.write(
      key: expiresAtKey,
      value: expiresAt.toUtc().toIso8601String(),
    );
  }

  /// Never throws: it runs on every sign-out path, which must complete. Each
  /// key is attempted even if the other fails.
  @override
  Future<void> clear() async {
    await _deleteQuietly(tokenKey);
    await _deleteQuietly(expiresAtKey);
  }

  Future<void> _deleteQuietly(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Unreadable storage is already treated as "no token" by read().
    }
  }
}

class MemoryTokenStore implements TokenStore {
  StoredRefreshToken? _value;

  @override
  Future<StoredRefreshToken?> read() async => _value;

  @override
  Future<void> write(String token, DateTime expiresAt) async {
    _value = StoredRefreshToken(token, expiresAt);
  }

  @override
  Future<void> clear() async {
    _value = null;
  }
}

final tokenStoreProvider = Provider<TokenStore>((_) => SecureTokenStore());
