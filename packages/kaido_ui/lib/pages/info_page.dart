import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/pages/contact_page.dart';
import 'package:kaido_ui/widgets/point_info_card.dart';

/// Point info screen (`/info/:id`).
class InfoPage extends ConsumerWidget {
  /// Creates an [InfoPage] for the point identified by [id].
  const InfoPage({required this.id, super.key});

  /// The point id.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsAsync = ref.watch(pointsProvider);
    final config = ref.watch(kaidoConfigProvider);

    return pointsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('詳細')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('詳細')),
        body: Center(child: Text('読み込みに失敗しました: $error')),
      ),
      data: (points) {
        final point = points.cast<Point?>().firstWhere(
          (p) => p?.id == id,
          orElse: () => null,
        );
        if (point == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('詳細')),
            body: const Center(child: Text('ポイントが見つかりません')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(point.category),
            actions: [
              TextButton(
                onPressed: () => context.push(
                  '/contact',
                  extra: ContactPageArgs(
                    subject: point.title,
                    location: LatLng(point.lat, point.lng),
                  ),
                ),
                child: const Text('問合せ'),
              ),
            ],
          ),
          body: PointInfoCard(
            point: point,
            assetPrefix: config.assetPrefix,
            onImageTap: () => context.push('/info/$id/image'),
          ),
        );
      },
    );
  }
}
