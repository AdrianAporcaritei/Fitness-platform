import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../errors/api_error.dart';
import '../errors/error_messages.dart';
import '../l10n/app_localizations.dart';
import 'notice_banner.dart';

/// "Confirm your email" notice for a PENDING user, with a resend action.
class PendingEmailBanner extends ConsumerStatefulWidget {
  const PendingEmailBanner({super.key, required this.email});

  final String email;

  @override
  ConsumerState<PendingEmailBanner> createState() => _PendingEmailBannerState();
}

class _PendingEmailBannerState extends ConsumerState<PendingEmailBanner> {
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
    final resendError = _resendError;
    return NoticeBanner(
      resendError != null
          ? errorMessage(l, resendError)
          : l.pendingBanner(widget.email),
      action: TextButton(
        onPressed: (_resending || _resent) ? null : _resend,
        child: Text(_resent ? l.resent : l.resend),
      ),
    );
  }
}
