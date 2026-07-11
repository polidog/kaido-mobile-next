import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_data/kaido_data.dart';

/// Image detail screen (`/info/:id/image`).
class ImagePage extends ConsumerWidget {
  /// Creates an [ImagePage] for the point identified by [id].
  const ImagePage({required this.id, super.key});

  /// The point id.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsAsync = ref.watch(pointsProvider);
    final config = ref.watch(kaidoConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('画像')),
      backgroundColor: Colors.black,
      body: pointsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            '読み込みに失敗しました: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (points) {
          final pointId = int.tryParse(id);
          final point = pointId == null
              ? null
              : points.cast<Point?>().firstWhere(
                  (p) => p?.id == pointId,
                  orElse: () => null,
                );
          final image = point?.image;
          if (point == null || image == null || image.isEmpty) {
            return const Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.white,
                size: 64,
              ),
            );
          }
          final imageProvider = image.startsWith('http://') ||
                  image.startsWith('https://')
              ? NetworkImage(image)
              : AssetImage('${config.assetPrefix}/images/$image')
                  as ImageProvider;
          return InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: Image(
                image: imageProvider,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
