import 'package:kaido_data/models/detour.dart';
import 'package:kaido_data/providers/kaido_config_provider.dart';
import 'package:kaido_data/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detours_provider.g.dart';

/// Manages fetching and caching of [Detour] data for the current app.
@riverpod
class Detours extends _$Detours {
  // refresh() 経由の build() 実行だけリモートを強制するための一時フラグ。
  var _forceRemote = false;

  @override
  Future<List<Detour>> build() async {
    final config = ref.watch(kaidoConfigProvider);
    final repo = ref.watch(detourRepositoryProvider);
    final forceRemote = _forceRemote;
    _forceRemote = false;
    return repo.getDetours(config.apiContext, forceRemote: forceRemote);
  }

  /// Refreshes the detours data from the remote API, re-running [build].
  Future<void> refresh() async {
    _forceRemote = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
