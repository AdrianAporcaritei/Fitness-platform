import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/errors/api_error.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/router.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/form_error_banner.dart';
import '../../../core/widgets/notice_banner.dart';
import '../../../core/widgets/primary_button.dart';

/// Sign-in form. [from]: where to go after sign-in; the router's guard does
/// the navigation (validated by `safeFrom`), so this page never navigates
/// after a successful login.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.from});

  final String? from;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  ApiError? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    ApiError? error;
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(_email.text.trim(), _password.text);
    } on ApiError catch (e) {
      error = e;
    } catch (_) {
      error = const ApiError(code: 'UNKNOWN');
    }
    // On success the guard moves us to `from` / home and disposes this page.
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final reason = switch (ref.watch(authControllerProvider)) {
      SignedOut(:final reason) => reason,
      _ => null,
    };
    final error = _error;

    return AuthScaffold(
      title: l.loginTitle,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (reason == SignedOutReason.sessionEnded) ...[
                NoticeBanner(l.sessionEndedNotice),
                const SizedBox(height: 16),
              ],
              if (reason == SignedOutReason.suspended) ...[
                FormErrorBanner(l.accountSuspendedNotice),
                const SizedBox(height: 16),
              ],
              if (error != null) ...[
                FormErrorBanner(errorMessage(l, error)),
                const SizedBox(height: 16),
              ],
              AppTextField(
                label: l.emailLabel,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                validator: (v) => validateRequired(v?.trim()),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l.passwordLabel,
                controller: _password,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: validateRequired,
                onSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(Routes.forgotPassword),
                  child: Text(l.forgotPasswordLink),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: l.loginButton,
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l.newCoachPrompt,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(Routes.register),
                    child: Text(l.createAccountLink),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
