import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../locale/locale_controller.dart';
import '../theme/tokens.dart';

class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeControllerProvider).languageCode;
    final controller = ref.read(localeControllerProvider.notifier);

    Widget button(String code) => TextButton(
      onPressed: () => controller.select(code),
      style: TextButton.styleFrom(
        minimumSize: const Size(40, 36),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        foregroundColor: current == code
            ? AppTokens.accent
            : AppTokens.textMuted,
      ),
      child: Text(
        code.toUpperCase(),
        style: TextStyle(
          fontWeight: current == code ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [button('en'), button('ro')],
    );
  }
}
