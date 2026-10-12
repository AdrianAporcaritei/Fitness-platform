import 'package:flutter/material.dart';

import 'auth_scaffold.dart';
import 'primary_button.dart';

/// The shared "link problem" page (spec §6): icon, title, explanation and an
/// optional primary action. Rendered by the page whose link failed.
class LinkProblemView extends StatelessWidget {
  const LinkProblemView({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuthScaffold(
      title: title,
      header: Align(
        alignment: Alignment.centerLeft,
        child: Icon(icon, size: 40, color: theme.colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 24),
            PrimaryButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
