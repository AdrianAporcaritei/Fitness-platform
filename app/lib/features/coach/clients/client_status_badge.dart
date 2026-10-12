import 'package:flutter/material.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';

String clientStatusLabel(AppLocalizations l, ClientListStatus status) =>
    switch (status) {
      ClientListStatus.invited => l.clientStatusInvited,
      ClientListStatus.active => l.clientStatusActive,
      ClientListStatus.paused => l.clientStatusPaused,
      ClientListStatus.ended => l.clientStatusEnded,
      ClientListStatus.$unknown => '—',
    };

class ClientStatusBadge extends StatelessWidget {
  const ClientStatusBadge(this.status, {super.key});

  final ClientListStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      ClientListStatus.active => (AppTokens.success, AppTokens.successSurface),
      ClientListStatus.invited => (AppTokens.accent, AppTokens.accentSurface),
      ClientListStatus.paused => (AppTokens.textMuted, AppTokens.surface3),
      _ => (AppTokens.textSubtle, AppTokens.surface2),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          clientStatusLabel(AppLocalizations.of(context), status),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
