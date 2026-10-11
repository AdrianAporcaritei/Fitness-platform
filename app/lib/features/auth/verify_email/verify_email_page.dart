import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/generated/export.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/errors/api_error.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/router.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/form_error_banner.dart';
import '../../../core/widgets/link_problem_view.dart';
import '../../../core/widgets/primary_button.dart';

enum _Phase { verifying, confirmed, invalid, failed }

/// Confirms the email address from the link `/verify-email?token=...`. The
/// token is single use, so the request is started once per page instance (in
/// [initState]); only a failure that did not consume the token can be retried.
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key, required this.token});

  final String? token;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  _Phase _phase = _Phase.verifying;
  ApiError? _error;
  bool _resending = false;
  bool _resent = false;
  ApiError? _resendError;

  @override
  void initState() {
    super.initState();
    final token = widget.token;
    if (token == null || token.isEmpty) {
      _phase = _Phase.invalid;
    } else {
      _verify(token);
    }
  }

  Future<void> _verify(String token) async {
    setState(() {
      _phase = _Phase.verifying;
      _error = null;
    });
    _Phase result = _Phase.confirmed;
    ApiError? error;
    try {
      await apiCall(
        () => ref
            .read(apiProvider)
            .openapi
            .verifyEmail(body: VerifyEmailRequest(token: token)),
      );
      if (ref.read(authControllerProvider) is SignedIn) {
        try {
          await ref.read(authControllerProvider.notifier).reloadUser();
        } catch (_) {
          // The email is confirmed regardless; the status refreshes later.
        }
      }
    } on ApiError catch (e) {
      if (e.code == 'INVALID_TOKEN') {
        result = _Phase.invalid;
      } else {
        result = _Phase.failed;
        error = e;
      }
    } catch (_) {
      result = _Phase.failed;
      error = const ApiError(code: 'INTERNAL_ERROR');
    }
    if (!mounted) return;
    setState(() {
      _phase = result;
      _error = error;
    });
  }

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
    final auth = ref.watch(authControllerProvider);
    final signedIn = auth is SignedIn;

    switch (_phase) {
      case _Phase.verifying:
        return AuthScaffold(
          title: l.verifyingEmail,
          child: const Center(child: CircularProgressIndicator()),
        );
      case _Phase.confirmed:
        return LinkProblemView(
          icon: Icons.check_circle_outline,
          title: l.emailConfirmedTitle,
          text: l.emailConfirmedText,
          actionLabel: signedIn ? l.goHome : l.goToLogin,
          onAction: () => context.go(signedIn ? Routes.home : Routes.login),
        );
      case _Phase.failed:
        return AuthScaffold(
          title: l.verifyingEmail,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormErrorBanner(errorMessage(l, _error!)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _verify(widget.token!),
                child: Text(l.retry, style: theme.textTheme.labelLarge),
              ),
            ],
          ),
        );
      case _Phase.invalid:
        if (auth is SignedIn) {
          if (auth.user.status == UserResponseStatus.pending) {
            final resendError = _resendError;
            return AuthScaffold(
              title: l.linkVerifyInvalidTitle,
              header: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.link_off,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (resendError != null)
                    FormErrorBanner(errorMessage(l, resendError))
                  else
                    Text(
                      l.linkVerifyResendText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _resent ? l.resent : l.resend,
                    loading: _resending,
                    onPressed: _resent ? null : _resend,
                  ),
                ],
              ),
            );
          }
          return LinkProblemView(
            icon: Icons.link_off,
            title: l.linkVerifyInvalidTitle,
            text: l.linkVerifyAlreadyConfirmed,
            actionLabel: l.goHome,
            onAction: () => context.go(Routes.home),
          );
        }
        return AuthScaffold(
          title: l.linkVerifyInvalidTitle,
          header: Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.link_off,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          child: PrimaryButton(
            label: l.goToLogin,
            onPressed: () => context.go(Routes.login),
          ),
        );
    }
  }
}
