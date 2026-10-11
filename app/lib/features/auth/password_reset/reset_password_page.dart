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
import '../../../core/widgets/link_problem_view.dart';
import '../../../core/widgets/primary_button.dart';

/// Sets a new password from the link `/reset-password?token=...`. Success
/// signs the user in (replacing any current session); this page navigates
/// itself because the route is reachable while signed in, so the router guard
/// would not move the user.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.token});

  final String? token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _invalid = false;
  ApiError? _error;
  String? _serverPasswordCode;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = widget.token;
    if (_loading || token == null || token.isEmpty) return;
    setState(() {
      _error = null;
      _serverPasswordCode = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    ApiError? error;
    try {
      await ref
          .read(authControllerProvider.notifier)
          .confirmPasswordReset(token, _password.text);
    } on ApiError catch (e) {
      error = e;
    } catch (_) {
      error = const ApiError(code: 'UNKNOWN');
    }
    if (!mounted) return;
    if (error == null) {
      context.go(Routes.home);
      return;
    }
    setState(() {
      _loading = false;
      if (error!.code == 'INVALID_TOKEN') {
        _invalid = true;
        return;
      }
      final fieldCode = error.fieldErrors
          .where((f) => f.field == 'newPassword')
          .map((f) => f.code)
          .firstOrNull;
      if (fieldCode != null) {
        _serverPasswordCode = fieldCode;
      } else {
        _error = error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final token = widget.token;
    if (_invalid || token == null || token.isEmpty) {
      return LinkProblemView(
        icon: Icons.link_off,
        title: l.linkResetInvalidTitle,
        text: errorMessage(l, const ApiError(code: 'INVALID_TOKEN')),
        actionLabel: l.linkResetAction,
        onAction: () => context.go(Routes.forgotPassword),
      );
    }

    final error = _error;
    final code = _serverPasswordCode;
    final serverError = code == null ? null : fieldErrorMessage(l, code);

    return AuthScaffold(
      title: l.resetTitle,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error != null) ...[
                FormErrorBanner(errorMessage(l, error)),
                const SizedBox(height: 16),
              ],
              AppTextField(
                label: l.newPasswordLabel,
                controller: _password,
                obscure: true,
                hint: l.passwordHint,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                errorText: serverError,
                validator: validateNewPassword,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l.confirmPasswordLabel,
                controller: _confirm,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) =>
                    validatePasswordConfirmation(v, _password.text),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l.resetButton,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
