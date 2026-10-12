import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/export.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/pending_email_banner.dart';

/// Placeholder home for clients and admins: greeting, role,
/// email-confirmation banner, sign out. Coaches land on the client list.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(authControllerProvider);
    if (state is! SignedIn) return const Scaffold();
    final user = state.user;
    final role = switch (user.role) {
      UserResponseRole.coach => l.roleCoach,
      UserResponseRole.client => l.roleClient,
      UserResponseRole.admin => l.roleAdmin,
      _ => '',
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (user.status == UserResponseStatus.pending) ...[
                    PendingEmailBanner(email: user.email),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    l.homeGreeting(user.firstName),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).logout(),
                      child: Text(l.signOut),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
