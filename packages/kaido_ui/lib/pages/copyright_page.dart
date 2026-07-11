import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Copyright / license screen (`/copyright`).
class CopyrightPage extends ConsumerStatefulWidget {
  /// Creates a [CopyrightPage].
  const CopyrightPage({super.key});

  @override
  ConsumerState<CopyrightPage> createState() => _CopyrightPageState();
}

class _CopyrightPageState extends ConsumerState<CopyrightPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    unawaited(_loadVersion());
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
      });
    }
  }

  static const _companyUrl = 'http://www.ground-base.com/';

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(kaidoConfigProvider);
    final year = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(title: const Text('著作権情報')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/copyright/copyright.png',
                width: 200,
              ),
              const SizedBox(height: 24),
              Text(
                '【五街道を歩く】シリーズ\n'
                '「${config.appName}」 Version$_version',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Copyright ©2011 - $year GROUND-BASE INC.\n'
                'All right reserved.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(_companyUrl)),
                child: const Text(
                  _companyUrl,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
