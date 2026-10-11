import 'package:flutter/material.dart';

import '../errors/error_messages.dart';
import '../l10n/app_localizations.dart';

/// Labelled form field. [validator] returns an error code (e.g. `REQUIRED`),
/// shown via [fieldErrorMessage]; [errorText] is an already-localized
/// (server) error. [hint] is shown under the field until an error replaces it. With [obscure], a show/hide toggle is added.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.obscure = false,
    this.autofillHints,
    this.keyboardType,
    this.validator,
    this.onSubmitted,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final bool obscure;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final validator = widget.validator;
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscure && _hidden,
      enableSuggestions: !widget.obscure,
      autocorrect: !widget.obscure,
      autofillHints: widget.autofillHints,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      validator: validator == null
          ? null
          : (value) {
              final code = validator(value);
              return code == null ? null : fieldErrorMessage(l, code);
            },
      decoration: InputDecoration(
        labelText: widget.label,
        // Always visible under the field (e.g. the password rule), unlike
        // hintText, which a label hides until focus.
        helperText: widget.hint,
        helperMaxLines: 2,
        errorText: widget.errorText,
        errorMaxLines: 3,
        suffixIcon: widget.obscure
            ? IconButton(
                tooltip: _hidden ? l.showPassword : l.hidePassword,
                icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}
