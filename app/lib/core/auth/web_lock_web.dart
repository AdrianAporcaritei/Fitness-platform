import 'dart:js_interop';

import 'web_lock.dart';

extension type _LockManager(JSObject _) implements JSObject {
  external JSPromise<JSAny?> request(String name, JSFunction callback);
}

/// `undefined` in insecure contexts (other than localhost) and old browsers.
@JS('navigator.locks')
external _LockManager? get _locks;

CrossTabLock createPlatformLock() =>
    _locks == null ? InProcessLock() : _WebLock();

/// Web Locks API: the lock is held until the promise returned by the
/// callback settles, across every tab of the origin.
class _WebLock implements CrossTabLock {
  @override
  Future<T> run<T>(String name, Future<T> Function() action) async {
    late T value;
    Object? error;
    StackTrace? stackTrace;

    // The JS promise only controls the lock's lifetime; it always resolves,
    // and the action's outcome is carried back in Dart variables so the
    // caller sees the original Dart error.
    JSPromise<JSAny?> callback(JSAny? lock) => () async {
      try {
        value = await action();
      } catch (e, s) {
        error = e;
        stackTrace = s;
      }
      return null;
    }().toJS;

    await _locks!.request(name, callback.toJS).toDart;
    if (error != null) Error.throwWithStackTrace(error!, stackTrace!);
    return value;
  }
}
