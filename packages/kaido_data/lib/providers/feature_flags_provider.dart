import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feature flag for the experimental 3D heading mode, injected via
/// `--dart-define-from-file` as `FEATURE_3D_HEADING`.
///
/// When enabled, a round button is shown on the map while GPS follow mode
/// is active. Tapping it tilts the camera and rotates the map to face the
/// direction the device is heading. Defaults to `false` (feature hidden).
final heading3dFeatureEnabledProvider = Provider<bool>(
  (ref) => const bool.fromEnvironment('FEATURE_3D_HEADING'),
);
