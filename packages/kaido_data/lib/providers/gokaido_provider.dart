import 'dart:convert';

import 'package:kaido_data/models/gokaido.dart';
import 'package:kaido_data/providers/datasource_providers.dart';
import 'package:kaido_data/providers/kaido_config_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gokaido_provider.g.dart';

/// Loads the [GokaidoData] bundled with the current app.
@riverpod
Future<GokaidoData> gokaido(Ref ref) async {
  final config = ref.watch(kaidoConfigProvider);
  final assetLoader = ref.watch(assetLoaderProvider);
  final raw = await assetLoader.loadString(
    '${config.assetPrefix}/data/gokaido_data.json',
  );
  return GokaidoData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
