import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/widgets/kaido_card.dart';
import 'package:kaido_ui/widgets/kaido_icons.dart';

/// はじめに画面（`/intro`）。
///
/// アプリの紹介・表示に関しての補足・用語を表示します。
class IntroductionPage extends ConsumerWidget {
  /// Creates an [IntroductionPage].
  const IntroductionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introductionAsync = ref.watch(introductionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('はじめに')),
      body: introductionAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // はじめにセクション
              KaidoCard(
                title: data.intro.title,
                icon: Icons.info_outline,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.intro.content,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const Divider(height: 32),
                    _UpdateNote(text: data.intro.updateNote),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 表示に関しての補足セクション
              KaidoCard(
                title: '表示に関しての補足',
                icon: Icons.visibility,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.supplementaryInfo
                      .map((info) => _InfoCardTile(info: info))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              // 用語セクション
              KaidoCard(
                title: '用語',
                icon: Icons.menu_book,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.terminology
                      .map((info) => _InfoCardTile(info: info))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }
}

/// アップデートに関する注意書き。
class _UpdateNote extends StatelessWidget {
  const _UpdateNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 強化された情報カード。
class _InfoCardTile extends StatelessWidget {
  const _InfoCardTile({required this.info});

  final InfoCard info;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final icon = kaidoIconFromName(info.icon);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      icon,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                Text(
                  info.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              info.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
