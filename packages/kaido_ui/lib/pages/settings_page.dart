import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings screen (`/settings`).
class SettingsPage extends ConsumerWidget {
  /// Creates a [SettingsPage].
  const SettingsPage({super.key});

  Future<void> _handleDataUpdate(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('データを更新しますか？'),
        content: const Text('通信状況の良い場所で更新を行ってください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('更新する'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      await context.push('/settings/update');
    }
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
            onTap: () => context.push('/intro'),
          ),
          ListTile(
            title: const Text('ヘルプ'),
            subtitle: const Text('操作方法'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/help'),
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
            onTap: () => context.push('/gokaido'),
          ),
          ListTile(
            title: const Text('データアップデート'),
            subtitle: const Text('アプリケーションデータの更新'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _handleDataUpdate(context),
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
