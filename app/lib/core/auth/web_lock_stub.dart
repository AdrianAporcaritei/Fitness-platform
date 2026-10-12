import 'web_lock.dart';

CrossTabLock createPlatformLock() => InProcessLock();

/// Process-local mutex: actions with the same name run one after another, in
/// call order. Used off the web and as the fallback when `navigator.locks` is
/// unavailable.
class InProcessLock implements CrossTabLock {
  final _tails = <String, Future<void>>{};

  @override
  Future<T> run<T>(String name, Future<T> Function() action) {
    final previous = _tails[name] ?? Future<void>.value();
    final result = previous.then((_) => action());
    // The tail never fails, so one failed action does not poison the queue.
    final tail = result.then<void>((_) {}, onError: (Object _) {});
    _tails[name] = tail;
    tail.then((_) {
      if (identical(_tails[name], tail)) _tails.remove(name);
    });
    return result;
  }
}
