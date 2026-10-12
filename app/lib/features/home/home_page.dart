import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/generated/export.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/errors/api_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/notice_banner.dart';

/// Placeholder home: greeting, role, email-confirmation banner, sign out.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _resending = false;
  bool _resent = false;
  ApiError? _resendError;

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _resendError = null;
    });
    ApiError? error;
    try {
      await apiCall(
        () => ref.read(apiProvider).openapi.resendVerificationEmail(),
      );
    } on ApiError catch (e) {
      error = e;
    } catch (_) {
      error = const ApiError(code: 'UNKNOWN');
    }
    if (!mounted) return;
    setState(() {
      _resending = false;
      _resent = error == null;
      _resendError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
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
    final resendError = _resendError;

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
                    NoticeBanner(
                      resendError != null
                          ? errorMessage(l, resendError)
                          : l.pendingBanner(user.email),
                      action: TextButton(
                        onPressed: (_resending || _resent) ? null : _resend,
                        child: Text(_resent ? l.resent : l.resend),
                      ),
                    ),
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
