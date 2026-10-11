import 'dart:js_interop';

@JS('Intl.DateTimeFormat')
extension type _DateTimeFormat._(JSObject _) implements JSObject {
  external factory _DateTimeFormat();
  external _Options resolvedOptions();
}

extension type _Options._(JSObject _) implements JSObject {
  external String? get timeZone;
}

/// IANA zone name from the browser, or `UTC` on any failure.
String browserTimeZone() {
  try {
    final zone = _DateTimeFormat().resolvedOptions().timeZone;
    return (zone == null || zone.isEmpty) ? 'UTC' : zone;
  } catch (_) {
    return 'UTC';
  }
}
