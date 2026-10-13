import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/errors/api_error.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_error_banner.dart';
import 'clients_repository.dart';
import 'invitation_link_view.dart';

/// "Add client": name and email, then the invitation link, shown once.
/// Closes only with Cancel (before creating) or Done (after).
Future<void> showAddClientDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => const AddClientDialog(),
);

class AddClientDialog extends ConsumerStatefulWidget {
  const AddClientDialog({super.key});

  @override
  ConsumerState<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends ConsumerState<AddClientDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  bool _submitting = false;
  ApiError? _error;
  InvitationLinkResponse? _created;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_form.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final created = await ref
          .read(clientsRepositoryProvider)
          .add(name: _name.text, email: _email.text);
      if (!mounted) return;
      setState(() => _created = created);
    } on ApiError catch (e) {
      if (mounted) setState(() => _error = e);
    } catch (_) {
      if (mounted) setState(() => _error = const ApiError(code: 'UNKNOWN'));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _fieldError(AppLocalizations l, String field) {
    final match = _error?.fieldErrors.where((e) => e.field == field);
    return match == null || match.isEmpty
        ? null
        : fieldErrorMessage(l, match.first.code);
  }

  @override
  Widget build(BuildContext context) {
    final created = _created;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: created != null
              ? InvitationLinkView(
                  invitation: created,
                  onDone: () => Navigator.of(context).pop(),
                )
              : _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final error = _error;
    final formError = error != null && error.fieldErrors.isEmpty
        ? errorMessage(l, error)
        : null;

    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.addClientTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.addClientIntro,
            style: const TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: 20),
          if (formError != null) ...[
            FormErrorBanner(formError),
            const SizedBox(height: 16),
          ],
          AppTextField(
            label: l.fullNameLabel,
            controller: _name,
            validator: validateName,
            errorText: _fieldError(l, 'name'),
            autofillHints: const [AutofillHints.name],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l.emailLabel,
            controller: _email,
            validator: validateEmail,
            errorText: _fieldError(l, 'email'),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppTokens.textMuted,
                ),
                child: Text(l.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.createInvitation),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
