import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/router/kaido_route_paths.dart';

/// Bottom navigation bar shown on the map screen with three buttons:
/// GPS, ポイント (marker visibility), and 設定 (settings).
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
    final activeColor = ref.watch(kaidoConfigProvider).themeColor;
    const defaultColor = Colors.grey;

    return BottomAppBar(
      // M3 デフォルト（高さ80 + 縦パディング12）は iOS で高くなりすぎるため縮小する
      height: 56,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          // GPS button
          Expanded(
            child: InkWell(
              onTap: () => _handleGpsTap(context, ref),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.navigation,
                    color:
                        mapState.isFollowingUser ? activeColor : defaultColor,
                  ),
                  Text(
                    'GPS',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          mapState.isFollowingUser ? activeColor : defaultColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ポイント button
          Expanded(
            child: InkWell(
              onTap: () => ref.read(markerVisibilityProvider.notifier).state =
                  !markersVisible,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: markersVisible ? activeColor : defaultColor,
                  ),
                  Text(
                    'ポイント',
                    style: TextStyle(
                      fontSize: 12,
                      color: markersVisible ? activeColor : defaultColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 設定 button
          Expanded(
            child: InkWell(
              onTap: () => context.push(KaidoRoutePaths.settings),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings,
                    color: defaultColor,
                  ),
                  Text(
                    '設定',
                    style: TextStyle(
                      fontSize: 12,
                      color: defaultColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
