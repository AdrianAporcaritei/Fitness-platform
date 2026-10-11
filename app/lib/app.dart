import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Temporary: the router replaces `home` in Task 8.
    return MaterialApp(theme: buildAppTheme(), home: const SizedBox());
  }
}
