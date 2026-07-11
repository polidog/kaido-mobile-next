import 'package:kaido_data/datasources/asset_loader.dart';

/// Fake [AssetLoader] backed by an in-memory map of asset key to contents.
class FakeAssetLoader implements AssetLoader {
  FakeAssetLoader(this._assets);

  final Map<String, String> _assets;

  @override
  Future<String> loadString(String key) async {
    final value = _assets[key];
    if (value == null) {
      throw ArgumentError('No fake asset registered for key: $key');
    }
    return value;
  }
}
