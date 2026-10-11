import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_container.dart';
import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

Future<FakeApi> _pumpHome(WidgetTester t, Map<String, dynamic> user) async {
  final api = FakeApi();
  final store = MemoryTokenStore();
  await store.write('r1', testNow.add(const Duration(days: 10)));
  api.on(
    'POST',
    '/auth/refresh',
    (_) => FakeResponse.json(200, tokenJson(now: testNow, user: user)),
  );
  await pumpApp(t, api: api, store: store, initialLocation: '/home');
  return api;
}

void main() {
  testWidgets('active coach: greeting, role, no banner', (t) async {
    await _pumpHome(t, userJson(role: 'COACH', status: 'ACTIVE'));
    expect(find.text('Hello, Ana'), findsOneWidget);
    expect(find.text('Coach'), findsOneWidget);
    expect(find.text('Resend'), findsNothing);
  });

  testWidgets('pending client: banner with the email', (t) async {
    await _pumpHome(t, userJson(role: 'CLIENT', status: 'PENDING'));
    expect(find.text('Client'), findsOneWidget);
    expect(
      find.text('Confirm your email – we sent a link to ana@example.ro'),
      findsOneWidget,
    );
  });

  testWidgets('resend sends the bearer token and shows Sent', (t) async {
    final api = await _pumpHome(t, userJson(status: 'PENDING'));
    api.on('POST', '/auth/verify-email/resend', (_) => FakeResponse.empty(204));
    await t.tap(find.widgetWithText(TextButton, 'Resend'));
    await t.pumpAndSettle();
    final req = api.requests.last;
    expect(req.path, endsWith('/auth/verify-email/resend'));
    expect(req.headers['Authorization'], 'Bearer access-1');
    final sent = find.widgetWithText(TextButton, 'Sent');
    expect(sent, findsOneWidget);
    expect(t.widget<TextButton>(sent).onPressed, isNull);
  });

  testWidgets('resend rate limited shows the wait text', (t) async {
    final api = await _pumpHome(t, userJson(status: 'PENDING'));
    api.on(
      'POST',
      '/auth/verify-email/resend',
      (_) => FakeResponse.problem(429, 'RATE_LIMITED', retryAfterSeconds: 600),
    );
    await t.tap(find.widgetWithText(TextButton, 'Resend'));
    await t.pumpAndSettle();
    expect(
      find.text('Too many attempts. Try again in 10 min.'),
      findsOneWidget,
    );
  });

  testWidgets('sign out goes to login and revokes the token', (t) async {
    final api = await _pumpHome(t, userJson(status: 'ACTIVE'));
    api.on('POST', '/auth/logout', (_) => FakeResponse.empty(204));
    await t.tap(find.widgetWithText(OutlinedButton, 'Sign out'));
    await t.pumpAndSettle();
    expect(currentLocation(t), startsWith('/login'));
    expect(api.count('POST', '/auth/logout'), 1);
  });
}
