import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/router/kaido_route_paths.dart';

/// Bottom navigation bar shown on the map screen: GPS follow toggle, compass
/// mode toggle, marker visibility toggle, and settings navigation.
class BottomBar extends ConsumerWidget {
  /// Creates a [BottomBar].
  const BottomBar({super.key});

  Future<void> _handleGpsTap(BuildContext context, WidgetRef ref) async {
    final permission =
        await ref.read(locationServiceProvider).ensurePermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('位置情報の権限が必要です'),
          action: permission == LocationPermission.deniedForever
              ? SnackBarAction(
                  label: '設定を開く',
                  onPressed: Geolocator.openAppSettings,
                )
              : null,
        ),
      );
      return;
    }
    ref.read(mapControllerProvider.notifier).toggleFollowUser();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapControllerProvider);
    final markersVisible = ref.watch(markerVisibilityProvider);
    final activeColor = Theme.of(context).colorScheme.primary;

    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            tooltip: '現在地',
            icon: Icon(
              Icons.my_location,
              color: mapState.isFollowingUser ? activeColor : null,
            ),
            onPressed: () => _handleGpsTap(context, ref),
          ),
          IconButton(
            tooltip: 'コンパス',
            icon: Icon(
              Icons.explore,
              color: mapState.isCompassMode ? activeColor : null,
            ),
            onPressed: () =>
                ref.read(mapControllerProvider.notifier).toggleCompassMode(),
          ),
          IconButton(
            tooltip: 'ポイント表示切替',
            icon: Icon(
              Icons.place,
              color: markersVisible ? activeColor : null,
            ),
            onPressed: () =>
                ref.read(markerVisibilityProvider.notifier).state =
                    !markersVisible,
          ),
          IconButton(
            tooltip: '設定',
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(KaidoRoutePaths.settings),
          ),
        ],
      ),
    );
  }
}
