import 'dart:async';

import 'package:ana_fit_lab/core/api/generated/export.dart';
import 'package:ana_fit_lab/core/auth/refresh_coordinator.dart';
import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:ana_fit_lab/core/auth/web_lock_stub.dart';
import 'package:ana_fit_lab/core/errors/api_error.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';

final _now = DateTime.utc(2026, 10, 11, 12);
final _expiry = DateTime.utc(2026, 11, 10, 12);

TokenResponse _token(String refresh, {String access = 'access'}) =>
    TokenResponse.fromJson(
      tokenJson(refresh: refresh, access: access, now: _now),
    );

void main() {
  late MemoryTokenStore store;
  late InProcessLock lock;

  setUp(() {
    store = MemoryTokenStore();
    lock = InProcessLock();
  });

  test('concurrent callers share one refresh', () async {
    await store.write('r1', _expiry);
    final calls = <String>[];
    final completer = Completer<TokenResponse>();
    final coordinator = RefreshCoordinator(
      store: store,
      lock: lock,
      callRefresh: (t) {
        calls.add(t);
        return completer.future;
      },
    );

    final a = coordinator.refresh('r1');
    final b = coordinator.refresh('r1');
    final c = coordinator.refresh('r1');
    expect(identical(a, b) && identical(b, c), isTrue);

    final response = _token('r2');
    // Let the coordinator reach callRefresh before completing it.
    await pumpEventQueue();
    completer.complete(response);

    final results = await Future.wait([a, b, c]);
    expect(calls, ['r1']);
    expect(results.every((r) => identical(r, response)), isTrue);
    expect((await store.read())!.token, 'r2');
    expect((await store.read())!.expiresAt, response.refreshTokenExpiresAt);
  });

  test(
    'second caller after another tab rotated uses the stored token',
    () async {
      await store.write('r2', _expiry); // another tab already rotated r1 -> r2
      final calls = <String>[];
      final coordinator = RefreshCoordinator(
        store: store,
        lock: lock,
        callRefresh: (t) async {
          calls.add(t);
          return _token('r3');
        },
      );

      await coordinator.refresh('r1');

      expect(calls, ['r2']);
      expect((await store.read())!.token, 'r3');
    },
  );

  test('two coordinators sharing a store and a lock never send the same '
      'token twice', () async {
    await store.write('r1', _expiry);
    final calls = <String>[];
    Future<TokenResponse> callRefresh(String t) async {
      calls.add(t);
      await pumpEventQueue(); // a real network round-trip
      final n = int.parse(t.substring(1)) + 1;
      return _token('r$n');
    }

    final tabA = RefreshCoordinator(
      store: store,
      lock: lock,
      callRefresh: callRefresh,
    );
    final tabB = RefreshCoordinator(
      store: store,
      lock: lock,
      callRefresh: callRefresh,
    );

    final results = await Future.wait([tabA.refresh('r1'), tabB.refresh('r1')]);

    expect(calls, ['r1', 'r2']);
    expect(results.map((r) => r.refreshToken), ['r2', 'r3']);
    expect((await store.read())!.token, 'r3');
  });

  test('failure propagates and the next call retries', () async {
    await store.write('r1', _expiry);
    var calls = 0;
    var fail = true;
    final coordinator = RefreshCoordinator(
      store: store,
      lock: lock,
      callRefresh: (t) async {
        calls++;
        if (fail) throw const ApiError(code: 'REFRESH_TOKEN_REUSED');
        return _token('r2');
      },
    );

    await expectLater(
      coordinator.refresh('r1'),
      throwsA(
        isA<ApiError>().having((e) => e.code, 'code', 'REFRESH_TOKEN_REUSED'),
      ),
    );
    expect(calls, 1);
    expect((await store.read())!.token, 'r1'); // nothing written on failure

    fail = false;
    final response = await coordinator.refresh('r1');
    expect(calls, 2);
    expect(response.refreshToken, 'r2');
    expect((await store.read())!.token, 'r2');
  });

  test('store empty inside the lock throws INVALID_REFRESH_TOKEN', () async {
    var calls = 0;
    final coordinator = RefreshCoordinator(
      store: store,
      lock: lock,
      callRefresh: (t) async {
        calls++;
        return _token('r2');
      },
    );

    await expectLater(
      coordinator.refresh('r1'),
      throwsA(
        isA<ApiError>().having((e) => e.code, 'code', 'INVALID_REFRESH_TOKEN'),
      ),
    );
    expect(calls, 0);
  });

  test('InProcessLock serialises actions and propagates errors', () async {
    final order = <String>[];
    final first = lock.run('l', () async {
      order.add('a-start');
      await pumpEventQueue();
      order.add('a-end');
      throw StateError('boom');
    });
    final second = lock.run('l', () async {
      order.add('b');
      return 2;
    });

    await expectLater(first, throwsA(isA<StateError>()));
    expect(await second, 2);
    expect(order, ['a-start', 'a-end', 'b']);
  });
}
