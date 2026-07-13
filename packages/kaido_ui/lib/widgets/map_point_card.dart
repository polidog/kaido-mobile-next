import 'package:flutter/material.dart';
import 'package:kaido_data/models/point.dart';

/// Thumbnail edge length (logical pixels) for the point image.
const double _thumbnailSize = 88;

/// Bottom card shown on the map when a [Point] marker is tapped.
///
/// Replaces the native map info window, which is too small to read and
/// hard to tap. The whole card is tappable and navigates to the point
/// detail page via [onTap].
class MapPointCard extends StatelessWidget {
  /// Creates a [MapPointCard] for [point].
  const MapPointCard({
    required this.point,
    required this.assetPrefix,
    required this.onTap,
    required this.onClose,
    this.accentHue,
    super.key,
  });

  /// The point to display.
  final Point point;

  /// The current app's asset prefix, used to resolve bundled images.
  final String assetPrefix;

  /// Called when the card body is tapped.
  final VoidCallback onTap;

  /// Called when the close button is tapped.
  final VoidCallback onClose;

  /// Marker hue for [point]'s category, used as the card accent color.
  final double? accentHue;

  ImageProvider? get _imageProvider {
    final image = point.image;
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return NetworkImage(image);
    }
    return AssetImage('$assetPrefix/images/$image');
  }

  Color get _accentColor =>
      HSVColor.fromAHSV(1, accentHue ?? 270, 0.65, 0.75).toColor();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawImageProvider = _imageProvider;
    // サムネイル表示なので原寸デコードを避け、表示サイズに合わせて縮小
    // デコードする(メモリとデコード時間の削減)。
    final imageProvider = rawImageProvider == null
        ? null
        : ResizeImage.resizeIfNeeded(
            (_thumbnailSize * MediaQuery.devicePixelRatioOf(context)).round(),
            null,
            rawImageProvider,
          );
    final accentColor = _accentColor;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: _thumbnailSize,
                  height: _thumbnailSize,
                  child: imageProvider != null
                      ? Image(image: imageProvider, fit: BoxFit.cover)
                      : ColoredBox(
                          color: accentColor.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.place,
                            size: 40,
                            color: accentColor,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  point.category,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                point.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          iconSize: 20,
                          onPressed: onClose,
                          icon: const Icon(Icons.close),
                          tooltip: '閉じる',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      point.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '詳細を見る',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: accentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
