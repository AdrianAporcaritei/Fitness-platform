import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'web_lock_stub.dart'
    if (dart.library.js_interop) 'web_lock_web.dart'
    as platform;

export 'web_lock_stub.dart' show InProcessLock;

/// A named mutex. On web it spans every tab of the origin (Web Locks API);
/// elsewhere it is process-local.
abstract interface class CrossTabLock {
  Future<T> run<T>(String name, Future<T> Function() action);
}

CrossTabLock createCrossTabLock() => platform.createPlatformLock();

final crossTabLockProvider = Provider<CrossTabLock>(
  (_) => createCrossTabLock(),
);
