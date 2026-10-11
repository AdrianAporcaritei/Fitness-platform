import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/generated/export.dart';
import '../../../core/errors/api_error.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/router.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/form_error_banner.dart';
import '../../../core/widgets/primary_button.dart';

/// Requests a password-reset email. The server answers 202 whether or not the
/// account exists, so the confirmation text is the same for any address.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  ApiError? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    ApiError? error;
    try {
      await apiCall(
        () => ref
            .read(apiProvider)
            .openapi
            .requestPasswordReset(
              body: PasswordResetRequest(email: _email.text.trim()),
            ),
      );
    } on ApiError catch (e) {
      error = e;
    } catch (_) {
      error = const ApiError(code: 'UNKNOWN');
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
      _sent = error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final error = _error;
    final toLogin = TextButton(
      onPressed: () => context.go(Routes.login),
      child: Text(l.goToLogin),
    );

    if (_sent) {
      return AuthScaffold(
        title: l.forgotTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.forgotSent,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            toLogin,
          ],
        ),
      );
    }

    return AuthScaffold(
      title: l.forgotTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.forgotText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (error != null) ...[
              FormErrorBanner(errorMessage(l, error)),
              const SizedBox(height: 16),
            ],
            AppTextField(
              label: l.emailLabel,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: validateEmail,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: l.forgotButton,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
            toLogin,
          ],
        ),
      ),
    );
  }
}
