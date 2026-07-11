import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaido_data/kaido_data.dart';

/// Settings screen (`/settings`).
class SettingsPage extends ConsumerWidget {
  /// Creates a [SettingsPage].
  const SettingsPage({super.key});

  Future<void> _handleRefresh(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(pointsProvider.notifier).refresh();
    messenger.showSnackBar(
      const SnackBar(content: Text('データを更新しました')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('はじめに'),
            subtitle: const Text('アプリケーションの紹介'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/html/intro'),
          ),
          ListTile(
            title: const Text('ヘルプ'),
            subtitle: const Text('操作方法'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/html/help'),
          ),
          ListTile(
            title: const Text('お問い合わせ'),
            subtitle: const Text('位置情報・ご意見'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/contact'),
          ),
          ListTile(
            title: const Text('五街道'),
            subtitle: const Text('「五街道を歩く」シリーズの紹介'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/html/gokaido'),
          ),
          ListTile(
            title: const Text('データアップデート'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _handleRefresh(context, ref),
          ),
          ListTile(
            title: const Text('著作権情報'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/copyright'),
          ),
        ],
      ),
    );
  }
}
