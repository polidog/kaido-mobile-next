import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaido_data/kaido_data.dart';

/// Splash screen (`/splash`).
///
/// Warms up the initial map data (points, routes, detours) while the
/// splash is visible, and navigates to the map as soon as the data is
/// ready — bounded by a minimum display time (branding) and a maximum
/// wait (slow network).
class SplashPage extends ConsumerStatefulWidget {
  /// Creates a [SplashPage].
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  /// Minimum time the splash stays visible.
  static const _minDisplay = Duration(seconds: 2);

  /// Maximum time to wait for the initial data before navigating anyway.
  static const _maxWait = Duration(seconds: 5);

  Timer? _minTimer;
  Timer? _maxTimer;
  var _minElapsed = false;
  var _navigated = false;

  @override
  void initState() {
    super.initState();
    _minTimer = Timer(_minDisplay, () {
      _minElapsed = true;
      _maybeNavigate();
    });
    _maxTimer = Timer(_maxWait, _navigate);
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _maxTimer?.cancel();
    super.dispose();
  }

  void _navigate() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go('/');
  }

  void _maybeNavigate() {
    if (!_minElapsed) return;
    final ready = !ref.read(pointsProvider).isLoading &&
        !ref.read(routesProvider).isLoading &&
        !ref.read(detoursProvider).isLoading;
    if (ready) _navigate();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(kaidoConfigProvider);

    // listen することで初期データの読み込みをスプラッシュ表示中に開始し、
    // 完了イベントで遷移判定を走らせる。
    ref
      ..listen(pointsProvider, (previous, next) => _maybeNavigate())
      ..listen(routesProvider, (previous, next) => _maybeNavigate())
      ..listen(detoursProvider, (previous, next) => _maybeNavigate());

    return Scaffold(
      backgroundColor: config.splashColor,
      body: Center(
        child: Image.asset(
          'assets/splash/title.png',
          // タイトル画像を持たないアプリではアプリ名テキストで代替する。
          errorBuilder: (context, error, stackTrace) => Text(
            config.appName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
