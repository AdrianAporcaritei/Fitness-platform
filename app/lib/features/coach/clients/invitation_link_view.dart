import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';

/// Shows a freshly issued invitation link once, with a copy button. The link
/// lives only in this widget: once it is closed, it cannot be shown again.
class InvitationLinkView extends StatefulWidget {
  const InvitationLinkView({
    super.key,
    required this.invitation,
    required this.onDone,
  });

  final InvitationLinkResponse invitation;
  final VoidCallback onDone;

  @override
  State<InvitationLinkView> createState() => _InvitationLinkViewState();
}

class _InvitationLinkViewState extends State<InvitationLinkView> {
  bool _copied = false;
  Timer? _resetCopied;

  @override
  void dispose() {
    _resetCopied?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.invitation.link));
    if (!mounted) return;
    setState(() => _copied = true);
    _resetCopied?.cancel();
    _resetCopied = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final invitation = widget.invitation;
    final locale = Localizations.localeOf(context).toString();
    final expires = DateFormat.yMMMd(locale)
        .add_Hm()
        .format(invitation.expiresAt.toLocal());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.invitationLinkTitle(invitation.name ?? l.clientsNoName),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.invitationLinkOnce,
          style: const TextStyle(color: AppTokens.textMuted),
        ),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppTokens.surface2,
            border: Border.all(color: AppTokens.borderStrong),
            borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    invitation.link,
                    key: const Key('invitation-link'),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _copy,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  icon: Icon(_copied ? Icons.check : Icons.copy, size: 18),
                  label: Text(_copied ? l.linkCopied : l.copyLink),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.invitationLinkExpires(expires),
          style: const TextStyle(color: AppTokens.textSubtle, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton(onPressed: widget.onDone, child: Text(l.done)),
        ),
      ],
    );
  }
}

/// [InvitationLinkView] in a dialog that closes only with Done.
Future<void> showInvitationLinkDialog(
  BuildContext context,
  InvitationLinkResponse invitation,
) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: InvitationLinkView(
          invitation: invitation,
          onDone: () => Navigator.of(context).pop(),
        ),
      ),
    ),
  ),
);
