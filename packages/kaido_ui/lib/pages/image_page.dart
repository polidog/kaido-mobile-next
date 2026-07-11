import 'package:flutter/material.dart';

/// Image detail screen (`/info/:id/image`).
class ImagePage extends StatelessWidget {
  /// Creates an [ImagePage] for the point identified by [id].
  const ImagePage({required this.id, super.key});

  /// The point id.
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('画像')),
      body: const Center(child: Text('TODO: Phase 4B/4C')),
    );
  }
}
