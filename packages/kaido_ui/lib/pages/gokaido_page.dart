import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/widgets/kaido_card.dart';
import 'package:kaido_ui/widgets/kaido_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// 五街道紹介画面（`/gokaido`）。
///
/// 五街道の紹介と各街道のアプリストアリンクを表示します。
class GokaidoPage extends ConsumerWidget {
  /// Creates a [GokaidoPage].
  const GokaidoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gokaidoAsync = ref.watch(gokaidoProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('五街道案内')),
      body: gokaidoAsync.when(
        data: (data) => _GokaidoContent(data: data),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '街道情報を読み込んでいます...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'エラーが発生しました: $error',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 五街道画面のコンテンツ。
class _GokaidoContent extends StatelessWidget {
  const _GokaidoContent({required this.data});

  final GokaidoData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Introduction(intro: data.introduction),
          const SizedBox(height: 24),
          ...data.routes.map((route) => _KaidoRouteCard(route: route)),
        ],
      ),
    );
  }
}

/// 紹介部分。
class _Introduction extends StatelessWidget {
  const _Introduction({required this.intro});

  final GokaidoIntroduction intro;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.history_edu,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    intro.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              intro.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      intro.note,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 街道カード。
class _KaidoRouteCard extends StatelessWidget {
  const _KaidoRouteCard({required this.route});

  final GokaidoRoute route;

  @override
  Widget build(BuildContext context) {
    final appLinks = route.appLinks;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: KaidoCard(
        title: route.title,
        icon: kaidoIconFromName(route.icon) ?? Icons.route,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 16),
            if (route.historicalNote.isNotEmpty)
              _HistoricalNote(noteText: route.historicalNote),
            // アプリストアへのリンクがある場合、表示する
            if (appLinks != null && appLinks.isNotEmpty)
              _AppStoreLinks(appLinks: appLinks),
          ],
        ),
      ),
    );
  }
}

/// 歴史メモ。
class _HistoricalNote extends StatelessWidget {
  const _HistoricalNote({required this.noteText});

  final String noteText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_stories,
            color: colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '歴史メモ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  noteText,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// アプリストアへのリンク（プラットフォーム別に表示）。
class _AppStoreLinks extends StatelessWidget {
  const _AppStoreLinks({required this.appLinks});

  final Map<String, String> appLinks;

  @override
  Widget build(BuildContext context) {
    final android = appLinks['android'];
    final ios = appLinks['ios'];
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Androidデバイスの場合はGoogle Playのリンクのみ表示
          if (Platform.isAndroid && android != null)
            _StoreButton(
              label: 'Google Play',
              icon: Icons.android,
              color: Colors.green.shade700,
              url: android,
            ),
          // iOSデバイスの場合はApp Storeのリンクのみ表示
          if (Platform.isIOS && ios != null)
            _StoreButton(
              label: 'App Store',
              icon: Icons.apple,
              color: Colors.black,
              url: ios,
            ),
          // Web, Desktopなど他のプラットフォームや、Flutter開発環境では両方表示
          if (!Platform.isAndroid && !Platform.isIOS) ...[
            if (android != null)
              _StoreButton(
                label: 'Google Play',
                icon: Icons.android,
                color: Colors.green.shade700,
                url: android,
              ),
            if (android != null && ios != null) const SizedBox(width: 16),
            if (ios != null)
              _StoreButton(
                label: 'App Store',
                icon: Icons.apple,
                color: Colors.black,
                url: ios,
              ),
          ],
        ],
      ),
    );
  }
}

/// ストアボタン。
class _StoreButton extends StatelessWidget {
  const _StoreButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.url,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String url;

  /// URLを開く。
  Future<void> _launchURL() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _launchURL,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: Colors.white,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
