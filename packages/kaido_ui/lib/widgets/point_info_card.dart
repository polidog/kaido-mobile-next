import 'package:flutter/material.dart';
import 'package:kaido_data/models/point.dart';

/// Displays a [Point]'s image, title, and description.
class PointInfoCard extends StatelessWidget {
  /// Creates a [PointInfoCard] for [point].
  ///
  /// [assetPrefix] is used to resolve bundled image assets when
  /// [Point.image] is not a network URL.
  const PointInfoCard({
    required this.point,
    required this.assetPrefix,
    this.onImageTap,
    super.key,
  });

  /// The point to display.
  final Point point;

  /// The current app's asset prefix, used to resolve bundled images.
  final String assetPrefix;

  /// Called when the image is tapped.
  final VoidCallback? onImageTap;

  ImageProvider? get _imageProvider {
    final image = point.image;
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return NetworkImage(image);
    }
    return AssetImage('$assetPrefix/images/$image');
  }

  /// Display height for the detail image (logical pixels).
  static const double _imageHeight = 220;

  @override
  Widget build(BuildContext context) {
    final rawImageProvider = _imageProvider;
    final imageProvider = rawImageProvider == null
        ? null
        : ResizeImage.resizeIfNeeded(
            null,
            (_imageHeight * MediaQuery.devicePixelRatioOf(context)).round(),
            rawImageProvider,
          );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageProvider != null)
            GestureDetector(
              onTap: onImageTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: imageProvider,
                  height: _imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            point.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            point.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
