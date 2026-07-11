import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/providers/kaido_config_provider.dart';
import 'package:kaido_data/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detours_provider.g.dart';

/// Manages fetching and caching of [Detour] data for the current app.
@riverpod
class Detours extends _$Detours {
  @override
  Future<List<Detour>> build() async {
    final config = ref.watch(kaidoConfigProvider);
    final repo = ref.watch(detourRepositoryProvider);
    return repo.getDetours(config.apiContext);
  }

  /// Refreshes the detours data, re-running [build].
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
