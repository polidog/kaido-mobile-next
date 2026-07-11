import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Static HTML content screen (`/html/:page`).
class HtmlPage extends ConsumerStatefulWidget {
  /// Creates an [HtmlPage] for the given [page] identifier.
  const HtmlPage({required this.page, super.key});

  /// The HTML page identifier (e.g. 'help', 'intro', 'gokaido').
  final String page;

  @override
  ConsumerState<HtmlPage> createState() => _HtmlPageState();
}

class _HtmlPageState extends ConsumerState<HtmlPage> {
  late final WebViewController _controller;
  Future<void>? _loadFuture;

  static const Map<String, String> _titles = {
    'intro': 'はじめに',
    'help': 'ヘルプ',
    'gokaido': '五街道紹介',
  };

  String get _title => _titles[widget.page] ?? widget.page;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    unawaited(_controller.setJavaScriptMode(JavaScriptMode.disabled));
    _loadFuture = _load();
  }

  Future<void> _load() async {
    final config = ref.read(kaidoConfigProvider);
    final assetLoader = ref.read(assetLoaderProvider);
    final html = await assetLoader.loadString(
      '${config.assetPrefix}/html/${widget.page}.html',
    );
    await _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('読み込みに失敗しました'));
          }
          return WebViewWidget(controller: _controller);
        },
      ),
    );
  }
}
