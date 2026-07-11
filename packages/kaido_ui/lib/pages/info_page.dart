import 'package:flutter/material.dart';

/// Point info screen (`/info/:id`).
class InfoPage extends StatelessWidget {
  /// Creates an [InfoPage] for the point identified by [id].
  const InfoPage({required this.id, super.key});

  /// The point id.
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('詳細')),
      body: const Center(child: Text('TODO: Phase 4B/4C')),
    );
  }
}
