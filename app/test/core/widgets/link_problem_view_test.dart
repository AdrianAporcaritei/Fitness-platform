import 'package:ana_fit_lab/core/widgets/link_problem_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/widget_harness.dart';

void main() {
  testWidgets('renders icon, title and text; no action without a label', (
    t,
  ) async {
    await pumpWidgetInApp(
      t,
      const LinkProblemView(
        icon: Icons.link_off,
        title: 'Title here',
        text: 'Explanation here',
      ),
    );
    expect(find.byIcon(Icons.link_off), findsOneWidget);
    expect(find.text('Title here'), findsOneWidget);
    expect(find.text('Explanation here'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('action button calls onAction', (t) async {
    var taps = 0;
    await pumpWidgetInApp(
      t,
      LinkProblemView(
        icon: Icons.link_off,
        title: 'Title',
        text: 'Text',
        actionLabel: 'Go to login',
        onAction: () => taps++,
      ),
    );
    await t.tap(find.text('Go to login'));
    expect(taps, 1);
  });
}
