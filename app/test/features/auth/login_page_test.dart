import 'dart:async';

import 'package:ana_fit_lab/core/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_container.dart';
import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

Future<void> _fillAndSubmit(
  WidgetTester t, {
  String email = 'ana@example.ro',
}) async {
  await t.enterText(find.byType(TextFormField).at(0), email);
  await t.enterText(find.byType(TextFormField).at(1), 'secret-password');
  await t.tap(find.widgetWithText(FilledButton, 'Sign in'));
}

FakeApi _apiWithLogin() {
  final api = FakeApi();
  api.on(
    'POST',
    '/auth/login',
    (_) => FakeResponse.json(
      200,
      tokenJson(
        now: testNow,
        user: userJson(status: 'ACTIVE'),
      ),
    ),
  );
  return api;
}

void main() {
  testWidgets('shows the fields and links', (t) async {
    await pumpApp(t, initialLocation: '/login');
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('empty submit shows two required errors and sends nothing', (
    t,
  ) async {
    final api = FakeApi();
    await pumpApp(t, api: api, initialLocation: '/login');
    await t.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await t.pumpAndSettle();
    expect(find.text(_required), findsNWidgets(2));
    expect(api.count('POST', '/auth/login'), 0);
  });

  testWidgets('whitespace-only email fails client-side', (t) async {
    final api = FakeApi();
    await pumpApp(t, api: api, initialLocation: '/login');
    await _fillAndSubmit(t, email: '   ');
    await t.pumpAndSettle();
    expect(find.text(_required), findsOneWidget);
    expect(api.count('POST', '/auth/login'), 0);
  });

  testWidgets('sends the trimmed email', (t) async {
    final api = _apiWithLogin();
    await pumpApp(t, api: api, initialLocation: '/login');
    await _fillAndSubmit(t, email: '  ana@example.ro ');
    await t.pumpAndSettle();
    final body = api.requests.last.data as Map;
    expect(body['email'], 'ana@example.ro');
  });

  testWidgets('INVALID_CREDENTIALS shows the single message', (t) async {
    final api = FakeApi();
    api.on(
      'POST',
      '/auth/login',
      (_) => FakeResponse.problem(401, 'INVALID_CREDENTIALS'),
    );
    await pumpApp(t, api: api, initialLocation: '/login');
    await _fillAndSubmit(t);
    await t.pumpAndSettle();
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
  });

  testWidgets('429 shows the wait time', (t) async {
    final api = FakeApi();
    api.on(
      'POST',
      '/auth/login',
      (_) => FakeResponse.problem(429, 'RATE_LIMITED', retryAfterSeconds: 900),
    );
    await pumpApp(t, api: api, initialLocation: '/login');
    await _fillAndSubmit(t);
    await t.pumpAndSettle();
    expect(
      find.text('Too many attempts. Try again in 15 min.'),
      findsOneWidget,
    );
  });

  testWidgets('Enter in the password field submits', (t) async {
    final api = _apiWithLogin();
    await pumpApp(t, api: api, initialLocation: '/login');
    await t.enterText(find.byType(TextFormField).at(0), 'ana@example.ro');
    await t.enterText(find.byType(TextFormField).at(1), 'secret-password');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
    expect(api.count('POST', '/auth/login'), 1);
  });

  testWidgets('success lands on home', (t) async {
    await pumpApp(t, api: _apiWithLogin(), initialLocation: '/login');
    await _fillAndSubmit(t);
    await t.pumpAndSettle();
    expect(currentLocation(t), '/home');
    expect(find.text('Hello, Ana'), findsOneWidget);
  });

  testWidgets('from=/home is honoured', (t) async {
    await pumpApp(
      t,
      api: _apiWithLogin(),
      initialLocation: '/login?from=%2Fhome',
    );
    await _fillAndSubmit(t);
    await t.pumpAndSettle();
    expect(currentLocation(t), '/home');
  });

  testWidgets('login ignores external from', (t) async {
    await pumpApp(
      t,
      api: _apiWithLogin(),
      initialLocation: '/login?from=//evil.com',
    );
    await _fillAndSubmit(t);
    await t.pumpAndSettle();
    expect(currentLocation(t), '/home');
  });

  testWidgets('shows the session-ended notice', (t) async {
    await pumpApp(t, initialLocation: '/login');
    expect(
      find.text('Your session ended. Please sign in again.'),
      findsNothing,
    );
    await appContainer(t)
        .read(authControllerProvider.notifier)
        .logout(reason: SignedOutReason.sessionEnded);
    await t.pumpAndSettle();
    expect(
      find.text('Your session ended. Please sign in again.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the suspended notice', (t) async {
    await pumpApp(t, initialLocation: '/login');
    await appContainer(t)
        .read(authControllerProvider.notifier)
        .logout(reason: SignedOutReason.suspended);
    await t.pumpAndSettle();
    expect(find.text('Your account is suspended.'), findsOneWidget);
  });

  testWidgets('button shows a spinner while the request is pending', (t) async {
    final gate = Completer<FakeResponse>();
    final api = FakeApi();
    api.on('POST', '/auth/login', (_) => gate.future);
    await pumpApp(t, api: api, initialLocation: '/login');
    await _fillAndSubmit(t);
    await t.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    gate.complete(FakeResponse.problem(401, 'INVALID_CREDENTIALS'));
    await t.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

const _required = 'Required';
