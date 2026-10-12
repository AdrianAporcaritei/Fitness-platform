import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Storage whose every read and delete fails, as corrupted or undecryptable
/// browser storage can.
class _ThrowingStorage extends FlutterSecureStorage {
  final deleteAttempts = <String>[];

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw StateError('corrupted');

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    deleteAttempts.add(key);
    throw StateError('corrupted');
  }
}

void main() {
  test('MemoryTokenStore write/read/clear round-trip', () async {
    final store = MemoryTokenStore();
    expect(await store.read(), isNull);

    final expiry = DateTime.utc(2026, 11, 10, 12);
    await store.write('r1', expiry);
    final stored = await store.read();
    expect(stored!.token, 'r1');
    expect(stored.expiresAt, expiry);

    await store.write('r2', expiry.add(const Duration(days: 1)));
    expect((await store.read())!.token, 'r2');

    await store.clear();
    expect(await store.read(), isNull);
    await store.clear(); // clearing an empty store does not throw
  });

  group('SecureTokenStore with failing storage', () {
    test('read() returns null', () async {
      expect(await SecureTokenStore(_ThrowingStorage()).read(), isNull);
    });

    test('clear() completes and attempts both keys', () async {
      final storage = _ThrowingStorage();
      await SecureTokenStore(storage).clear();
      expect(storage.deleteAttempts, [
        'refresh_token',
        'refresh_token_expires_at',
      ]);
    });
  });
}
