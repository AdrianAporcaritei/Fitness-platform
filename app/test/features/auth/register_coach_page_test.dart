import 'package:ana_fit_lab/core/locale/browser_time_zone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_container.dart';
import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

Future<void> _fill(
  WidgetTester t, {
  String first = 'Ana',
  String last = 'Pop',
  String email = 'ana@example.ro',
  String password = 'secret-password',
}) async {
  await t.enterText(find.byType(TextFormField).at(0), first);
  await t.enterText(find.byType(TextFormField).at(1), last);
  await t.enterText(find.byType(TextFormField).at(2), email);
  await t.enterText(find.byType(TextFormField).at(3), password);
}

Future<void> _submit(WidgetTester t) async {
  await t.tap(find.widgetWithText(FilledButton, 'Create account'));
  await t.pumpAndSettle();
}

FakeApi _apiOk() {
  final api = FakeApi();
  api.on(
    'POST',
    '/auth/register/coach',
    (_) => FakeResponse.json(
      201,
      tokenJson(
        now: testNow,
        user: userJson(role: 'COACH'),
      ),
    ),
  );
  // A new coach lands on the (empty) client list.
  api.on(
    'GET',
    '/coach/clients',
    (_) => FakeResponse.json(200, clientPageJson()),
  );
  return api;
}

void main() {
  testWidgets('shows fields, hint and sign-in link', (t) async {
    await pumpApp(t, initialLocation: '/register');
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('10–64 characters'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
  });

  testWidgets('short password fails client-side, no request', (t) async {
    final api = FakeApi();
    await pumpApp(t, api: api, initialLocation: '/register');
    await _fill(t, password: 'short');
    await _submit(t);
    expect(find.text('Use 10–64 characters'), findsOneWidget);
    expect(api.count('POST', '/auth/register/coach'), 0);
  });

  testWidgets('sends trimmed values with RO locale and time zone', (t) async {
    final api = _apiOk();
    await pumpApp(t, api: api, initialLocation: '/register');
    await t.tap(find.text('RO'));
    await t.pumpAndSettle();
    await _fill(t, first: ' Ana ', last: ' Pop ', email: '  ana@example.ro ');
    await t.tap(find.byType(FilledButton));
    await t.pumpAndSettle();
    final body =
        api.requests
                .firstWhere((r) => r.path.endsWith('/auth/register/coach'))
                .data
            as Map;
    expect(body, {
      'email': 'ana@example.ro',
      'password': 'secret-password',
      'firstName': 'Ana',
      'lastName': 'Pop',
      'locale': 'ro',
      'timezone': browserTimeZone(),
    });
  });

  testWidgets('field errors go under fields, others to the banner', (t) async {
    final api = FakeApi();
    api.on(
      'POST',
      '/auth/register/coach',
      (_) => FakeResponse.problem(
        400,
        'VALIDATION_FAILED',
        errors: [
          {'field': 'firstName', 'code': 'TOO_LONG'},
          {'field': 'timezone', 'code': 'INVALID_TIMEZONE'},
        ],
      ),
    );
    await pumpApp(t, api: api, initialLocation: '/register');
    await _fill(t);
    await _submit(t);
    expect(find.text('Too long'), findsOneWidget);
    expect(find.text('This time zone is not supported.'), findsOneWidget);
  });

  testWidgets('server field error clears on edit; banner clears on resubmit', (
    t,
  ) async {
    final api = FakeApi();
    api.on(
      'POST',
      '/auth/register/coach',
      (_) => FakeResponse.problem(
        400,
        'VALIDATION_FAILED',
        errors: [
          {'field': 'firstName', 'code': 'TOO_LONG'},
          {'field': 'timezone', 'code': 'INVALID_TIMEZONE'},
        ],
      ),
    );
    await pumpApp(t, api: api, initialLocation: '/register');
    await _fill(t);
    await _submit(t);
    await t.enterText(find.byType(TextFormField).at(0), 'Anna');
    await t.pump();
    expect(find.text('Too long'), findsNothing);
    // Stale banner must not survive a failed client validation.
    await t.enterText(find.byType(TextFormField).at(3), 'short');
    await _submit(t);
    expect(find.text('This time zone is not supported.'), findsNothing);
    expect(find.text('Use 10–64 characters'), findsOneWidget);
  });

  testWidgets('409 EMAIL_TAKEN shows under the email field', (t) async {
    final api = FakeApi();
    api.on(
      'POST',
      '/auth/register/coach',
      (_) => FakeResponse.problem(409, 'EMAIL_TAKEN'),
    );
    await pumpApp(t, api: api, initialLocation: '/register');
    await _fill(t);
    await _submit(t);
    expect(
      find.text('An account with this email already exists.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'success with a PENDING coach lands on the client list with banner',
    (t) async {
      await pumpApp(t, api: _apiOk(), initialLocation: '/register');
      await _fill(t);
      await _submit(t);
      expect(currentLocation(t), '/coach/clients');
      expect(find.text('No clients yet'), findsOneWidget);
      expect(
        find.text('Confirm your email – we sent a link to ana@example.ro'),
        findsOneWidget,
      );
    },
  );
}
