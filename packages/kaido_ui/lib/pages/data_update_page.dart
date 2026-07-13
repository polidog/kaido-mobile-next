import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/widgets/loading_indicator.dart';

/// Data update screen (`/settings/update`).
///
/// Watching [dataUpdateProvider] kicks off the update; the screen shows a
/// full-screen loading view while running, a completion view on success,
/// and an error view with a retry button on failure.
class DataUpdatePage extends ConsumerWidget {
  /// Creates a [DataUpdatePage].
  const DataUpdatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataUpdateProvider);
    return Scaffold(
      body: state.when(
        loading: () => const LoadingIndicator(
          message: 'データを更新しています...',
        ),
        data: (_) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text('データの更新が完了しました'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('設定画面に戻る'),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('データの更新に失敗しました'),
              const SizedBox(height: 8),
              const Text(
                '通信状況をご確認のうえ、再度お試しください',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(dataUpdateProvider),
                child: const Text('再試行'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('設定画面に戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
