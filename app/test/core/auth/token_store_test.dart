import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
