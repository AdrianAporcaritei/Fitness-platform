import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/generated/export.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/errors/api_error.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/locale/browser_time_zone.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/routing/router.dart';
import '../../../core/widgets/auth_scaffold.dart';
import '../../../core/widgets/form_error_banner.dart';
import '../../../core/widgets/link_problem_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../signup_form.dart';

const _linkProblemCodes = {
  'INVITE_EXPIRED',
  'INVITE_USED',
  'INVITE_REVOKED',
  'INVITE_NOT_FOUND',
  'COACH_UNAVAILABLE',
};

/// Client sign-up from a coach's invite link. The raw [code] from the URL is
/// sent unchanged (the backend normalizes it). Reachable while signed in:
/// then it offers to sign out first, and navigates to /home itself after a
/// successful sign-up.
class JoinPage extends ConsumerStatefulWidget {
  const JoinPage({super.key, required this.code});

  final String code;

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  InvitePreviewResponse? _preview;
  ApiError? _loadError;
  String? _problem;
  bool _loading = false;
  bool _submitting = false;
  int _loadId = 0;

  @override
  void initState() {
    super.initState();
    if (ref.read(authControllerProvider) is SignedOut) _loadPreview();
  }

  @override
  void didUpdateWidget(JoinPage old) {
    super.didUpdateWidget(old);
    if (old.code != widget.code) {
      _preview = null;
      _problem = null;
      _loadError = null;
      if (ref.read(authControllerProvider) is SignedOut) _loadPreview();
    }
  }

  Future<void> _loadPreview() async {
    final id = ++_loadId;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    InvitePreviewResponse? preview;
    ApiError? error;
    try {
      preview = await apiCall(
        () => ref.read(apiProvider).openapi.previewInvite(code: widget.code),
      );
    } on ApiError catch (e) {
      error = e;
    } catch (_) {
      error = const ApiError(code: 'INTERNAL_ERROR');
    }
    if (!mounted || id != _loadId) return;
    setState(() {
      _loading = false;
      if (error != null && _linkProblemCodes.contains(error.code)) {
        _problem = error.code;
      } else if (error != null) {
        _loadError = error;
      } else if (preview != null && !preview.valid) {
        _problem = 'INVITE_NOT_FOUND';
      } else {
        _preview = preview;
      }
    });
  }

  Future<void> _signOut() => ref.read(authControllerProvider.notifier).logout();

  Future<void> _register(SignupData data) async {
    final locale = ref.read(localeControllerProvider).languageCode == 'ro'
        ? RegisterClientRequestLocale.ro
        : RegisterClientRequestLocale.en;
    // Set before the call: the session is installed before it returns, and
    // the page must not swap the form for the signed-in notice meanwhile.
    setState(() => _submitting = true);
    var succeeded = false;
    try {
      await ref
          .read(authControllerProvider.notifier)
          .registerClient(
            RegisterClientRequest(
              code: widget.code,
              email: data.email,
              password: data.password,
              firstName: data.firstName,
              lastName: data.lastName,
              locale: locale,
              timezone: browserTimeZone(),
            ),
          );
      succeeded = true;
    } on ApiError catch (e) {
      if (_linkProblemCodes.contains(e.code)) {
        if (mounted) setState(() => _problem = e.code);
        return;
      }
      rethrow;
    } finally {
      if (!succeeded && mounted) setState(() => _submitting = false);
    }
    if (!mounted) return;
    context.go(Routes.home);
  }

  (IconData, String, String) _problemTexts(AppLocalizations l, String code) =>
      switch (code) {
        'INVITE_EXPIRED' => (
          Icons.schedule,
          l.linkInviteExpiredTitle,
          l.linkInviteExpiredText,
        ),
        'INVITE_USED' => (
          Icons.how_to_reg,
          l.linkInviteUsedTitle,
          l.linkInviteUsedText,
        ),
        'INVITE_REVOKED' => (
          Icons.link_off,
          l.linkInviteRevokedTitle,
          l.linkInviteRevokedText,
        ),
        'COACH_UNAVAILABLE' => (
          Icons.person_off,
          l.linkCoachUnavailableTitle,
          l.linkCoachUnavailableText,
        ),
        _ => (
          Icons.link_off,
          l.linkInviteNotFoundTitle,
          l.linkInviteNotFoundText,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (prev, next) {
      if (next is SignedOut && prev is! SignedOut && _preview == null) {
        _loadPreview();
      }
    });

    final problem = _problem;
    if (problem != null) {
      final (icon, title, text) = _problemTexts(l, problem);
      final used = problem == 'INVITE_USED';
      return LinkProblemView(
        icon: icon,
        title: title,
        text: text,
        actionLabel: used ? l.goToLogin : null,
        onAction: used ? () => context.go(Routes.login) : null,
      );
    }

    if (auth is SignedIn && !_submitting) {
      return AuthScaffold(
        title: l.joinSignedIn(auth.user.email),
        child: PrimaryButton(label: l.joinSignOut, onPressed: _signOut),
      );
    }

    final preview = _preview;
    if (preview != null) {
      return AuthScaffold(
        title: l.joinTitle(
          '${preview.coachFirstName} ${preview.coachLastName}',
        ),
        child: SignupForm(submitLabel: l.joinButton, onSubmit: _register),
      );
    }

    final error = _loadError;
    return AuthScaffold(
      title: '',
      child: error == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormErrorBanner(errorMessage(l, error)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loading ? null : _loadPreview,
                  child: Text(l.retry, style: theme.textTheme.labelLarge),
                ),
              ],
            ),
    );
  }
}
