import 'package:flutter/material.dart';

import '../../core/errors/api_error.dart';
import '../../core/errors/error_messages.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/validation/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/form_error_banner.dart';
import '../../core/widgets/primary_button.dart';

/// Values entered in the [SignupForm]; everything but [password] is trimmed.
class SignupData {
  const SignupData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  final String firstName, lastName, email, password;
}

/// First name, last name, email and password fields with submit button and
/// error banner. [onSubmit] throws an [ApiError] on failure; field errors
/// (and `EMAIL_TAKEN`) are shown under their field, anything else in the
/// banner. The caller builds the request and handles success.
class SignupForm extends StatefulWidget {
  const SignupForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
  });

  final String submitLabel;
  final Future<void> Function(SignupData) onSubmit;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  static const _fields = ['firstName', 'lastName', 'email', 'password'];

  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final Map<String, TextEditingController> _controllers = {
    'firstName': _first,
    'lastName': _last,
    'email': _email,
    'password': _password,
  };
  final Map<String, String> _serverCodes = {};
  final Map<String, String> _textAtError = {};
  ApiError? _bannerError;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    for (final f in _fields) {
      _controllers[f]!.addListener(() => _onEdited(f));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onEdited(String field) {
    if (_serverCodes.containsKey(field) &&
        _controllers[field]!.text != _textAtError[field]) {
      setState(() => _serverCodes.remove(field));
    }
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _serverCodes.clear();
      _bannerError = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    ApiError? error;
    try {
      await widget.onSubmit(
        SignupData(
          firstName: _first.text.trim(),
          lastName: _last.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        ),
      );
    } on ApiError catch (e) {
      error = e;
    } catch (_) {
      error = const ApiError(code: 'UNKNOWN');
    }
    // On success the router guard disposes the page.
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (error != null) _applyError(error);
    });
  }

  void _applyError(ApiError error) {
    ApiError? rest;
    final leftover = <FieldError>[];
    for (final f in error.fieldErrors) {
      if (_fields.contains(f.field)) {
        _serverCodes.putIfAbsent(f.field, () => f.code);
      } else {
        leftover.add(f);
      }
    }
    if (error.code == 'EMAIL_TAKEN') {
      _serverCodes.putIfAbsent('email', () => 'EMAIL_TAKEN');
    } else if (error.fieldErrors.isEmpty) {
      rest = error;
    } else if (leftover.isNotEmpty) {
      rest = ApiError(
        status: error.status,
        code: leftover.first.code,
        retryAfter: error.retryAfter,
      );
    }
    for (final f in _serverCodes.keys) {
      _textAtError[f] = _controllers[f]!.text;
    }
    // Unhandled top-level codes (e.g. a bare VALIDATION_FAILED) with only
    // handled field errors need no banner.
    _bannerError = rest;
  }

  String? _serverError(AppLocalizations l, String field) {
    final code = _serverCodes[field];
    return code == null ? null : fieldErrorMessage(l, code);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final banner = _bannerError;
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (banner != null) ...[
              FormErrorBanner(errorMessage(l, banner)),
              const SizedBox(height: 16),
            ],
            AppTextField(
              label: l.firstNameLabel,
              controller: _first,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.givenName],
              errorText: _serverError(l, 'firstName'),
              validator: validateName,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l.lastNameLabel,
              controller: _last,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.familyName],
              errorText: _serverError(l, 'lastName'),
              validator: validateName,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l.emailLabel,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: _serverError(l, 'email'),
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l.passwordLabel,
              controller: _password,
              obscure: true,
              hint: l.passwordHint,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              errorText: _serverError(l, 'password'),
              validator: validateNewPassword,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: widget.submitLabel,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
