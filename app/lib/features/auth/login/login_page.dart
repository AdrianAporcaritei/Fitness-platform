import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/auth_scaffold.dart';

/// Placeholder until the real page lands (Task 9). [from]: where to go after
/// sign-in (validated by the router's `safeFrom`).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.from});

  final String? from;

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: AppLocalizations.of(context).loginTitle,
    child: const Text('login'),
  );
}
