import 'package:flutter_riverpod/legacy.dart';

/// Toggles whether point markers are shown on the map.
final StateProvider<bool> markerVisibilityProvider = StateProvider<bool>(
  (ref) => true,
);
