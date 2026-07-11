import 'package:flutter/material.dart';

/// Splash screen (`/splash`).
class SplashPage extends StatelessWidget {
  /// Creates a [SplashPage].
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('起動中')),
      body: const Center(child: Text('TODO: Phase 4B/4C')),
    );
  }
}
