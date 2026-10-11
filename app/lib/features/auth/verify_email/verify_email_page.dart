import 'package:flutter/material.dart';

/// Placeholder until the real page lands (Tasks 9–13).
class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key, required this.token});

  final String? token;

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('verify-email')));
}
