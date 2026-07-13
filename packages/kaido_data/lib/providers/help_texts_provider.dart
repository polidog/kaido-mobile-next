import 'dart:convert';

import 'package:kaido_data/models/help_texts.dart';
import 'package:kaido_data/providers/datasource_providers.dart';
import 'package:kaido_data/providers/kaido_config_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'help_texts_provider.g.dart';

/// Loads the [HelpTexts] bundled with the current app.
@riverpod
Future<HelpTexts> helpTexts(Ref ref) async {
  final config = ref.watch(kaidoConfigProvider);
  final assetLoader = ref.watch(assetLoaderProvider);
  final raw = await assetLoader.loadString(
    '${config.assetPrefix}/data/help_texts.json',
  );
  return HelpTexts.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
