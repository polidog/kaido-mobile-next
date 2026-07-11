import 'package:flutter/material.dart';

/// Static HTML content screen (`/html/:page`).
class HtmlPage extends StatelessWidget {
  /// Creates an [HtmlPage] for the given [page] identifier.
  const HtmlPage({required this.page, super.key});

  /// The HTML page identifier (e.g. 'help', 'intro').
  final String page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ヘルプ')),
      body: const Center(child: Text('TODO: Phase 4B/4C')),
    );
  }
}
