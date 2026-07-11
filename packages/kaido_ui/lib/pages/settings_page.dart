import 'package:flutter/material.dart';

/// Settings screen (`/settings`).
class SettingsPage extends StatelessWidget {
  /// Creates a [SettingsPage].
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: const Center(child: Text('TODO: Phase 4B/4C')),
    );
  }
}
