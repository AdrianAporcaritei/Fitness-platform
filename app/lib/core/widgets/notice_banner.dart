import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A neutral (non-error) notice, optionally with a trailing [action].
class NoticeBanner extends StatelessWidget {
  const NoticeBanner(this.message, {super.key, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTokens.surface2,
        border: Border.all(color: AppTokens.borderStrong),
        borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTokens.accent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: AppTokens.text),
                  ),
                ),
              ],
            ),
            if (action != null) ...[
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerRight, child: action),
            ],
          ],
        ),
      ),
    );
  }
}
