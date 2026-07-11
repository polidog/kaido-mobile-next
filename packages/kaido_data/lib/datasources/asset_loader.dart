import 'package:flutter/services.dart';

/// Abstraction over asset bundle string loading, to allow faking in tests.
abstract class AssetLoader {
  /// Loads the string contents of the asset at [key].
  Future<String> loadString(String key);
}

/// [AssetLoader] backed by Flutter's [rootBundle].
class RootBundleAssetLoader implements AssetLoader {
  /// Creates a [RootBundleAssetLoader].
  const RootBundleAssetLoader();

  @override
  Future<String> loadString(String key) => rootBundle.loadString(key);
}
