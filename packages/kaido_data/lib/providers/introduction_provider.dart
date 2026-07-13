import 'dart:convert';

import 'package:kaido_data/models/introduction.dart';
import 'package:kaido_data/providers/datasource_providers.dart';
import 'package:kaido_data/providers/kaido_config_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'introduction_provider.g.dart';

/// Loads the [IntroductionData] bundled with the current app.
@riverpod
Future<IntroductionData> introduction(Ref ref) async {
  final config = ref.watch(kaidoConfigProvider);
  final assetLoader = ref.watch(assetLoaderProvider);
  final raw = await assetLoader.loadString(
    '${config.assetPrefix}/data/introduction.json',
  );
  return IntroductionData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
