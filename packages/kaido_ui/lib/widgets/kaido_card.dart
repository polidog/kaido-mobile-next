import 'package:flutter/material.dart';

/// 再利用可能な固定カードコンポーネント。
class KaidoCard extends StatelessWidget {
  /// Creates a [KaidoCard].
  const KaidoCard({
    required this.title,
    required this.icon,
    required this.child,
    super.key,
    this.iconBackgroundColor,
    this.iconColor,
    this.elevation = 2,
    this.contentPadding = const EdgeInsets.all(16),
    this.shape,
  });

  /// カードのタイトル。
  final String title;

  /// タイトル横に表示するアイコン。
  final IconData icon;

  /// カード本体のコンテンツ。
  final Widget child;

  /// アイコン背景色。省略時はテーマのプライマリカラーの淡色。
  final Color? iconBackgroundColor;

  /// アイコン色。省略時はテーマのプライマリカラー。
  final Color? iconColor;

  /// カードのエレベーション。
  final double elevation;

  /// コンテンツ部分のパディング。
  final EdgeInsets contentPadding;

  /// カードの形状。
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final defaultShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return Card(
      elevation: elevation,
      shape: shape ?? defaultShape,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ??
                        primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: contentPadding,
            child: child,
          ),
        ],
      ),
    );
  }
}
