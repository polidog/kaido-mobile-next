import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_data/kaido_data.dart';

/// Category name for ukiyo-e points, shared by all Kaido apps.
const String _ukiyoeCategory = '浮世絵ポイント';

/// Image detail screen (`/info/:id/image`).
///
/// Ukiyo-e point images are landscape artwork, so for the
/// [_ukiyoeCategory] category the image itself is rotated 90 degrees and
/// shown edge-to-edge, filling the portrait screen. The device
/// orientation is left untouched.
class ImagePage extends ConsumerWidget {
  /// Creates an [ImagePage] for the point identified by [id].
  const ImagePage({required this.id, super.key});

  /// The point id.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsAsync = ref.watch(pointsProvider);
    final config = ref.watch(kaidoConfigProvider);

    return pointsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('画像')),
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            '読み込みに失敗しました: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      data: (points) {
        final point = points.cast<Point?>().firstWhere(
          (p) => p?.id == id,
          orElse: () => null,
        );
        final image = point?.image;
        if (point == null || image == null || image.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('画像')),
            backgroundColor: Colors.black,
            body: const Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.white,
                size: 64,
              ),
            ),
          );
        }

        final imageProvider = image.startsWith('http://') ||
                image.startsWith('https://')
            ? NetworkImage(image)
            : AssetImage('${config.assetPrefix}/images/$image')
                as ImageProvider;
        final isUkiyoe = point.category == _ukiyoeCategory;

        Widget picture = Image(
          image: imageProvider,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            color: Colors.white,
            size: 64,
          ),
        );
        if (isUkiyoe) {
          picture = RotatedBox(quarterTurns: 1, child: picture);
        }
        final viewer = InteractiveViewer(
          minScale: 1,
          maxScale: 8,
          child: Center(child: picture),
        );

        if (!isUkiyoe) {
          return Scaffold(
            appBar: AppBar(title: const Text('画像')),
            backgroundColor: Colors.black,
            body: viewer,
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(child: viewer),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.4),
                      ),
                      tooltip: '閉じる',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
