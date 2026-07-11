import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kaido_ui/kaido_config.dart';
import 'package:kaido_ui/router/kaido_router.dart';
import 'package:kaido_ui/theme/kaido_theme.dart';

/// Root widget shared by all Kaido apps.
class KaidoApp extends ConsumerWidget {
  /// Creates a [KaidoApp].
  const KaidoApp({super.key, this.router});

  /// Optional router override, primarily for testing.
  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(kaidoConfigProvider);
    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: KaidoTheme.light(
        seedColor: config.themeColor,
        fontFamily: config.fontFamily,
      ),
      routerConfig: router ?? kaidoRouter,
    );
  }
}
