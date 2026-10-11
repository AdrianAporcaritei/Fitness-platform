import 'package:ana_fit_lab/core/theme/tokens.dart';
import 'package:ana_fit_lab/core/widgets/app_text_field.dart';
import 'package:ana_fit_lab/core/widgets/auth_scaffold.dart';
import 'package:ana_fit_lab/core/widgets/form_error_banner.dart';
import 'package:ana_fit_lab/core/widgets/language_switch.dart';
import 'package:ana_fit_lab/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/widget_harness.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('full width, and lays out inside a Row', (t) async {
      await pumpWidgetInApp(
        t,
        Column(
          children: [
            PrimaryButton(label: 'Go', onPressed: () {}),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(label: 'A', onPressed: () {}),
                ),
              ],
            ),
          ],
        ),
      );
      expect(t.takeException(), isNull);
      expect(t.getSize(find.byType(FilledButton).first).width, 1280);
    });

    testWidgets('loading: spinner, disabled, no label', (t) async {
      var taps = 0;
      await pumpWidgetInApp(
        t,
        PrimaryButton(label: 'Go', onPressed: () => taps++, loading: true),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Go'), findsNothing);
      expect(
        t.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await t.tap(find.byType(FilledButton));
      expect(taps, 0);
    });

    testWidgets('tap calls onPressed', (t) async {
      var taps = 0;
      await pumpWidgetInApp(
        t,
        PrimaryButton(label: 'Go', onPressed: () => taps++),
      );
      await t.tap(find.text('Go'));
      expect(taps, 1);
    });
  });

  group('AppTextField', () {
    testWidgets('validator codes are shown as localized messages', (t) async {
      final key = GlobalKey<FormState>();
      await pumpWidgetInApp(
        t,
        Form(
          key: key,
          child: AppTextField(label: 'Email', validator: (_) => 'REQUIRED'),
        ),
      );
      expect(key.currentState!.validate(), isFalse);
      await t.pump();
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('shows the hint under the field', (t) async {
      await pumpWidgetInApp(
        t,
        const AppTextField(label: 'Password', hint: '10–64 characters'),
      );
      expect(find.text('10–64 characters'), findsOneWidget);
    });

    testWidgets('shows errorText', (t) async {
      await pumpWidgetInApp(
        t,
        const AppTextField(
          label: 'Password',
          hint: '10–64 characters',
          errorText: 'Server says no',
        ),
      );
      expect(find.text('Server says no'), findsOneWidget);
    });

    testWidgets('obscure has a show/hide toggle', (t) async {
      await pumpWidgetInApp(
        t,
        const AppTextField(label: 'Password', obscure: true),
      );
      EditableText field() => t.widget(find.byType(EditableText));
      expect(field().obscureText, isTrue);
      await t.tap(find.byTooltip('Show password'));
      await t.pump();
      expect(field().obscureText, isFalse);
      await t.tap(find.byTooltip('Hide password'));
      await t.pump();
      expect(field().obscureText, isTrue);
    });

    testWidgets('no toggle when not obscure', (t) async {
      await pumpWidgetInApp(t, const AppTextField(label: 'Email'));
      expect(find.byType(IconButton), findsNothing);
    });
  });

  testWidgets('FormErrorBanner uses the error tokens', (t) async {
    await pumpWidgetInApp(t, const FormErrorBanner('Bad things'));
    final text = t.widget<Text>(find.text('Bad things'));
    expect(text.style?.color, AppTokens.errorText);
    final box = t.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text('Bad things'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, AppTokens.errorSurface);
    expect((decoration.border! as Border).top.color, AppTokens.errorBorder);
  });

  group('AuthScaffold', () {
    testWidgets('logo, app name, title, language switch, child', (t) async {
      await pumpWidgetInApp(
        t,
        const AuthScaffold(
          title: 'Sign in',
          header: Text('header'),
          child: Text('body'),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Ana Fit Lab'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('header'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      expect(find.byType(LanguageSwitch), findsOneWidget);
    });

    testWidgets('card is at most 420 wide on desktop', (t) async {
      await pumpWidgetInApp(
        t,
        const AuthScaffold(title: 'T', child: Text('body')),
      );
      expect(t.getSize(find.byKey(AuthScaffold.cardKey)).width, 420);
    });

    testWidgets('16 px side padding on a phone, scrollable', (t) async {
      await pumpWidgetInApp(
        t,
        AuthScaffold(
          title: 'T',
          child: Column(
            children: [for (var i = 0; i < 40; i++) Text('line $i')],
          ),
        ),
        size: const Size(360, 640),
      );
      expect(t.takeException(), isNull);
      final card = t.getRect(find.byKey(AuthScaffold.cardKey));
      expect(card.left, 16);
      expect(card.width, 360 - 32);
      expect(find.byType(Scrollable), findsWidgets);
      await t.scrollUntilVisible(find.text('line 39'), 200);
      expect(find.text('line 39'), findsOneWidget);
    });
  });
}
