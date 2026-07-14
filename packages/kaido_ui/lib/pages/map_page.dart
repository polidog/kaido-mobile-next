import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/widgets/bottom_bar.dart';
import 'package:kaido_ui/widgets/map_point_card.dart';

/// Fallback camera target when no persisted or initial location is
/// available (Tokyo Station).
const LatLng _fallbackTarget = LatLng(35.6812, 139.7671);

/// Fallback camera zoom level, paired with [_fallbackTarget].
const double _fallbackZoom = 14;

/// Debounce for persisting the camera position, so panning around does
/// not write to storage on every idle.
const Duration _cameraSaveDebounce = Duration(seconds: 1);

/// Minimum compass heading change (degrees) worth animating the camera
/// for. Smaller jitters from the sensor are ignored.
const double _headingThreshold = 1;

/// カメラ中心と現在地がこの距離(メートル)未満なら再センタリングしない。
/// フォローモード中の recenter → onCameraIdle → recenter の無限ループと、
/// GPSジッターによる無駄なカメラ移動を防ぐ。
const double _recenterThresholdMeters = 10;

/// 3Dヘディングモード(実験的機能)中のカメラのチルト角(度)。
const double _heading3dTilt = 60;

/// 3Dヘディングモード突入時のズームレベル。現在のズームがこれより
/// 手前(小さい)場合のみズームインする。
const double _heading3dZoom = 17;

/// Angular difference between two headings in degrees, accounting for
/// wrap-around at 360°.
double _headingDelta(double a, double b) {
  final diff = (a - b).abs() % 360;
  return diff > 180 ? 360 - diff : diff;
}

/// Map screen (`/`).
class MapPage extends ConsumerStatefulWidget {
  /// Creates a [MapPage].
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _controller;
  CameraPosition? _lastCameraPosition;
  Point? _selectedPoint;
  Timer? _cameraSaveTimer;
  double? _lastAppliedHeading;

  // ネイティブのコンパスは iOS ではセーフエリア外に描画され、Android では
  // 表示されないバグ(flutter/flutter#37588)があるため、自前のコンパス
  // ボタンを表示する。onCameraMove は高頻度で発火するので、ページ全体の
  // rebuild を避けるため ValueNotifier でボタンだけを更新する。
  final ValueNotifier<double> _bearing = ValueNotifier(0);

  /// 3Dヘディングモード突入前のズーム。解除時に元のズームへ戻すために保持する。
  double? _zoomBeforeHeading3d;

  /// 3Dヘディングモードの切替アニメーション中は true。コンパスの heading
  /// イベントが割り込むと切替アニメーションが途中で打ち切られ、ズームや
  /// チルトが中途半端な値で止まるため、この間は heading 追従を止める。
  bool _heading3dTransitioning = false;

  // BitmapDescriptor は同一性比較のため、build のたびに生成し直すと全
  // マーカーが「変更あり」と diff されてネイティブ側へ毎回再送される。
  // カテゴリごとに一度だけ生成してキャッシュする。
  final Map<String, BitmapDescriptor> _markerIcons = {};

  BitmapDescriptor _markerIconFor(String category, KaidoConfig config) {
    return _markerIcons.putIfAbsent(
      category,
      // カテゴリごとの色相付き標準マーカー(旧アプリと同じ方式)
      () => switch (config.markerHues[category]) {
        final hue? => BitmapDescriptor.defaultMarkerWithHue(hue),
        null => BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      },
    );
  }

  void _selectPoint(Point point) {
    setState(() => _selectedPoint = point);
    // カードに隠れないよう、タップしたマーカーを画面中央へ寄せる。
    unawaited(
      _controller?.animateCamera(
        CameraUpdate.newLatLng(LatLng(point.lat, point.lng)),
      ),
    );
  }

  void _clearSelectedPoint() {
    if (_selectedPoint == null) return;
    setState(() => _selectedPoint = null);
  }

  /// コンパスボタンのタップで地図を北向きに戻す。コンパスモード
  /// (3Dヘディングモード)中は heading の追従がすぐ回転を戻してしまう
  /// ため、モードも解除してチルトを平面に戻す。
  Future<void> _resetBearing() async {
    final controller = _controller;
    final position = _lastCameraPosition;
    if (controller == null || position == null) return;
    final wasHeading3d = ref.read(mapControllerProvider).isCompassMode;
    if (wasHeading3d) {
      ref.read(mapControllerProvider.notifier).toggleCompassMode();
    }
    final zoom = wasHeading3d
        ? _zoomBeforeHeading3d ?? position.zoom
        : position.zoom;
    _zoomBeforeHeading3d = null;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position.target,
          zoom: zoom,
          tilt: wasHeading3d ? 0 : position.tilt,
        ),
      ),
    );
  }

  /// 3Dヘディングモード(実験的機能)のトグル。
  ///
  /// ON: カメラをチルトさせて [_heading3dZoom] までズームインし、以降は
  /// compassHeadingProvider の listen が端末の向きへ回転を追従させる。
  /// OFF: チルトを平面に戻し、突入前のズームへ戻す(向きはコンパス
  /// ボタンで北へ戻せるので維持)。
  Future<void> _toggleHeading3dMode() async {
    final controller = _controller;
    final position = _lastCameraPosition;
    if (controller == null || position == null) return;
    final wasActive = ref.read(mapControllerProvider).isCompassMode;
    ref.read(mapControllerProvider.notifier).toggleCompassMode();
    final double zoom;
    if (wasActive) {
      zoom = _zoomBeforeHeading3d ?? position.zoom;
      _zoomBeforeHeading3d = null;
    } else {
      _zoomBeforeHeading3d = position.zoom;
      // すでに [_heading3dZoom] より寄っている場合はズームアウトしない。
      zoom = math.max(position.zoom, _heading3dZoom);
    }
    _heading3dTransitioning = true;
    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position.target,
            zoom: zoom,
            bearing: position.bearing,
            tilt: wasActive ? 0 : _heading3dTilt,
          ),
        ),
      );
    } finally {
      _heading3dTransitioning = false;
    }
  }

  /// 3Dヘディングモードを解除してチルトを平面に戻す。
  /// GPSフォロー解除でボタンが消えるときに、モードだけ残らないようにする。
  Future<void> _exitHeading3dMode() async {
    if (!ref.read(mapControllerProvider).isCompassMode) return;
    await _toggleHeading3dMode();
  }

  /// 現在地へカメラを移動する(旧アプリと同じ挙動)。
  ///
  /// GPSボタンのタップ時と、フォローモード中に地図を動かしたあとの
  /// onCameraIdle から呼ばれる。カメラ中心がすでに現在地付近
  /// ([_recenterThresholdMeters] 未満)の場合は移動しない。
  Future<void> _moveToCurrentLocation() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final position =
          await ref.read(locationServiceProvider).getCurrentPosition();
      if (!mounted) return;
      final target = _lastCameraPosition?.target;
      if (target != null &&
          Geolocator.distanceBetween(
                target.latitude,
                target.longitude,
                position.latitude,
                position.longitude,
              ) <
              _recenterThresholdMeters) {
        return;
      }
      await controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    } on Exception {
      // 位置情報が取得できない場合は移動しない(権限はタップ時に確認済み)。
    }
  }

  void _handleCameraIdle() {
    // フォローモード中はユーザーが地図を動かしても現在地へ戻す
    // (旧アプリと同じ挙動)。
    if (ref.read(mapControllerProvider).isFollowingUser) {
      unawaited(_moveToCurrentLocation());
    }

    _cameraSaveTimer?.cancel();
    _cameraSaveTimer = Timer(_cameraSaveDebounce, _saveCameraPosition);
  }

  void _saveCameraPosition() {
    final position = _lastCameraPosition;
    if (position == null) return;
    final config = ref.read(kaidoConfigProvider);
    final storage = ref.read(cameraPositionStorageProvider);
    unawaited(storage.write(config.apiContext, position));
  }

  @override
  void dispose() {
    _bearing.dispose();
    final saveTimer = _cameraSaveTimer;
    if (saveTimer != null && saveTimer.isActive) {
      saveTimer.cancel();
      _saveCameraPosition();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(kaidoConfigProvider);
    final pointsAsync = ref.watch(pointsProvider);
    final routesAsync = ref.watch(routesProvider);
    final detoursAsync = ref.watch(detoursProvider);
    final routePolylines = ref.watch(routePolylinesProvider);
    final detourPolylines = ref.watch(detourPolylinesProvider);
    final mapState = ref.watch(mapControllerProvider);
    final initialCameraAsync = ref.watch(initialCameraPositionProvider);
    final markersVisible = ref.watch(markerVisibilityProvider);
    final heading3dEnabled = ref.watch(heading3dFeatureEnabledProvider);

    ref
      ..listen(mapControllerProvider.select((state) => state.isFollowingUser), (
        previous,
        next,
      ) {
        // GPSフォロー解除で3Dヘディングボタンが消えるため、モードも解除する。
        if (!next) {
          unawaited(_exitHeading3dMode());
        }
        // GPSボタンのタップで必ずトグルされるため、変化のたびに現在地へ
        // カメラを移動する。
        unawaited(_moveToCurrentLocation());
      })
      ..listen(currentPositionProvider, (previous, next) {
        final position = next.value;
        final controller = _controller;
        if (position == null || controller == null) return;
        if (!ref.read(mapControllerProvider).isFollowingUser) return;
        unawaited(
          controller.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude),
            ),
          ),
        );
      })
      ..listen(compassHeadingProvider, (previous, next) {
        final heading = next.value;
        final controller = _controller;
        if (heading == null || controller == null) return;
        if (!ref.read(mapControllerProvider).isCompassMode) return;
        // モード切替アニメーション中の割り込みを避ける
        // (理由は [_heading3dTransitioning] のコメントを参照)。
        if (_heading3dTransitioning) return;
        final last = _lastAppliedHeading;
        if (last != null && _headingDelta(last, heading) < _headingThreshold) {
          return;
        }
        _lastAppliedHeading = heading;
        final current = _lastCameraPosition;
        unawaited(
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: current?.target ?? _fallbackTarget,
                zoom: current?.zoom ?? _fallbackZoom,
                bearing: heading,
                // モード切替のアニメーション中に heading イベントが割り込んで
                // チルトが平面へ戻らないよう、モード中は常に固定値を使う。
                tilt: _heading3dTilt,
              ),
            ),
          ),
        );
      });

    final polylines = {...routePolylines, ...detourPolylines};

    return Scaffold(
      body: initialCameraAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildMap(
          config: config,
          pointsAsync: pointsAsync,
          routesAsync: routesAsync,
          detoursAsync: detoursAsync,
          polylines: polylines,
          mapState: mapState,
          markersVisible: markersVisible,
          heading3dEnabled: heading3dEnabled,
          initialCameraPosition: const CameraPosition(
            target: _fallbackTarget,
            zoom: _fallbackZoom,
          ),
        ),
        data: (cameraPosition) => _buildMap(
          config: config,
          pointsAsync: pointsAsync,
          routesAsync: routesAsync,
          detoursAsync: detoursAsync,
          polylines: polylines,
          mapState: mapState,
          markersVisible: markersVisible,
          heading3dEnabled: heading3dEnabled,
          initialCameraPosition:
              cameraPosition ??
              const CameraPosition(
                target: _fallbackTarget,
                zoom: _fallbackZoom,
              ),
        ),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }

  Widget _buildMap({
    required KaidoConfig config,
    required AsyncValue<List<Point>> pointsAsync,
    required AsyncValue<List<RoutePoint>> routesAsync,
    required AsyncValue<List<Detour>> detoursAsync,
    required Set<Polyline> polylines,
    required MapState mapState,
    required bool markersVisible,
    required bool heading3dEnabled,
    required CameraPosition initialCameraPosition,
  }) {
    final points = pointsAsync.value ?? const <Point>[];
    final isLoading = pointsAsync.isLoading ||
        routesAsync.isLoading ||
        detoursAsync.isLoading;

    // マーカーは全ポイント分を一度だけネイティブ側へ登録し、ポイント表示の
    // トグルは visible フラグの切替のみで行う(旧アプリと同じ方式)。カメラが
    // 止まるたびに表示領域でマーカーを入れ替えると、その大量更新が直後の
    // ジェスチャー(特に二本指の回転)に割り込んで地図を操作できなくなる。
    final markers = points
        .map(
          (point) => Marker(
            markerId: MarkerId('point_${point.id}'),
            position: LatLng(point.lat, point.lng),
            icon: _markerIconFor(point.category, config),
            visible: markersVisible,
            onTap: () => _selectPoint(point),
          ),
        )
        .toSet();

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          polylines: polylines,
          onMapCreated: (controller) {
            _controller = controller;
            _lastCameraPosition ??= initialCameraPosition;
            _bearing.value = _lastCameraPosition!.bearing;
          },
          onCameraMove: (position) {
            _lastCameraPosition = position;
            _bearing.value = position.bearing;
          },
          onCameraIdle: _handleCameraIdle,
          onTap: (_) => _clearSelectedPoint(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: false,
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 12,
          child: _CompassButton(bearing: _bearing, onTap: _resetBearing),
        ),
        // 3Dヘディングモード(実験的機能)の切替ボタン。フィーチャーフラグが
        // 有効かつGPSフォロー中のみ、コンパスボタンの下に表示する。
        if (heading3dEnabled && mapState.isFollowingUser)
          Positioned(
            top: MediaQuery.of(context).padding.top + 68,
            right: 12,
            child: _Heading3dButton(
              isActive: mapState.isCompassMode,
              onTap: _toggleHeading3dMode,
            ),
          ),
        if (isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: switch (_selectedPoint) {
              null => const SizedBox.shrink(),
              final point => MapPointCard(
                key: ValueKey(point.id),
                point: point,
                assetPrefix: config.assetPrefix,
                accentHue: config.markerHues[point.category],
                onTap: () => context.push('/info/${point.id}'),
                onClose: _clearSelectedPoint,
              ),
            },
          ),
        ),
      ],
    );
  }
}

/// 3Dヘディングモード(実験的機能)の切替ボタン。
///
/// GPSフォロー中のみ表示される丸ボタン。タップでカメラをチルトさせ、
/// 端末の向きに地図の回転を追従させるモードを切り替える。
class _Heading3dButton extends StatelessWidget {
  const _Heading3dButton({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: isActive ? primary : Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          // 矢印を near_me と同じ北東向きにする(丸は回転しても見た目が
          // 変わらないため、アイコンごと回転させる)。
          child: Transform.rotate(
            angle: 45 * math.pi / 180,
            child: Icon(
              Icons.assistant_navigation,
              size: 24,
              color: isActive ? Colors.white : primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 地図が北向きでないときだけ表示されるコンパスボタン。
///
/// タップで北向きに戻る。ネイティブのコンパスの代替(理由は
/// [_MapPageState._bearing] のコメントを参照)。
class _CompassButton extends StatelessWidget {
  const _CompassButton({required this.bearing, required this.onTap});

  final ValueListenable<double> bearing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: bearing,
      builder: (context, value, _) {
        final visible = value != 0;
        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Transform.rotate(
                    // Icons.explore の針は北東(45°)を向いているため、
                    // bearing の打ち消しに加えて 45° 分補正する。
                    angle: (-value - 45) * math.pi / 180,
                    child: Icon(
                      Icons.explore,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
