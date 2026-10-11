import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/locale/browser_time_zone.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/routing/router.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../signup_form.dart';

/// Coach self-registration. No navigation after success: the router guard
/// moves the signed-in user to /home.
class RegisterCoachPage extends ConsumerWidget {
  const RegisterCoachPage({super.key});

  Future<void> _register(WidgetRef ref, SignupData data) {
    final locale = ref.read(localeControllerProvider).languageCode == 'ro'
        ? RegisterCoachRequestLocale.ro
        : RegisterCoachRequestLocale.en;
    return ref
        .read(authControllerProvider.notifier)
        .registerCoach(
          RegisterCoachRequest(
            email: data.email,
            password: data.password,
            firstName: data.firstName,
            lastName: data.lastName,
            locale: locale,
            timezone: browserTimeZone(),
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AuthScaffold(
      title: l.registerTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SignupForm(
            submitLabel: l.registerButton,
            onSubmit: (data) => _register(ref, data),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.haveAccountPrompt,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () => context.go(Routes.login),
                child: Text(l.signInLink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
