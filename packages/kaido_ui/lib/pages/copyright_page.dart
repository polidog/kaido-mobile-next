import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_data/kaido_data.dart';

/// Copyright / license screen (`/copyright`).
class CopyrightPage extends ConsumerWidget {
  /// Creates a [CopyrightPage].
  const CopyrightPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(kaidoConfigProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('著作権情報')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${config.appName}\n\n'
            '本アプリで使用しているデータ・画像の著作権は各権利者に帰属します。'
            '無断転載・複製を禁じます。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: config.appName,
            ),
            child: const Text('オープンソースライセンス'),
          ),
        ],
      ),
    );
  }
}
