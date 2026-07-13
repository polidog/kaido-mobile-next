import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_data/kaido_data.dart';

/// Full-screen loading view styled like the splash screen (theme color
/// background with the app title image), with a message at the bottom.
class LoadingIndicator extends ConsumerWidget {
  /// Creates a [LoadingIndicator].
  const LoadingIndicator({this.message, super.key});

  /// Message shown at the bottom of the screen.
  final String? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(kaidoConfigProvider);
    return ColoredBox(
      color: config.themeColor,
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/splash/title.png',
              fit: BoxFit.contain,
              // タイトル画像を持たないアプリではアプリ名テキストで代替する。
              errorBuilder: (context, error, stackTrace) => Text(
                config.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                message ?? 'データを読み込んでいます',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
