import 'package:flutter/material.dart';

/// Copyright / license screen (`/copyright`).
class CopyrightPage extends StatelessWidget {
  /// Creates a [CopyrightPage].
  const CopyrightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('著作権情報')),
      body: const Center(child: Text('TODO: Phase 4B/4C')),
    );
  }
}
