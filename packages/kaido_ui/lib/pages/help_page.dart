import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/widgets/kaido_card.dart';
import 'package:kaido_ui/widgets/kaido_icons.dart';

/// ヘルプ画面（`/help`）。
///
/// メイン画面の凡例・ツールバー・データアップデート・お問い合わせ・
/// 上手に使うコツを表示します。
class HelpPage extends ConsumerWidget {
  /// Creates a [HelpPage].
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helpTextsAsync = ref.watch(helpTextsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ヘルプ')),
      body: helpTextsAsync.when(
        data: (data) => _HelpContent(data: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('ヘルプテキストの読み込みに失敗しました: $error'),
        ),
      ),
    );
  }
}

/// ヘルプ画面のコンテンツ。
class _HelpContent extends ConsumerWidget {
  const _HelpContent({required this.data});

  final HelpTexts data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(kaidoConfigProvider);
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        KaidoCard(
          title: data.mainScreen.title,
          icon: Icons.map,
          contentPadding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMapLegendCard(context, data.mainScreen.sections),
              const SizedBox(height: 8),
              _buildMapIconsCard(
                context,
                data.mainScreen.sections,
                config.assetPrefix,
              ),
              const SizedBox(height: 8),
              _buildMapTipsCard(context, data.mainScreen.sections),
            ],
          ),
        ),
        const SizedBox(height: 8),
        KaidoCard(
          title: data.toolbar.title,
          icon: Icons.dashboard,
          contentPadding: const EdgeInsets.all(8),
          child: _buildToolbarCard(context),
        ),
        const SizedBox(height: 8),
        KaidoCard(
          title: data.dataUpdate.title,
          icon: Icons.system_update,
          contentPadding: const EdgeInsets.all(8),
          child: _buildDataUpdateCard(context),
        ),
        const SizedBox(height: 8),
        KaidoCard(
          title: data.inquiry.title,
          icon: Icons.contact_support,
          contentPadding: const EdgeInsets.all(8),
          child: _buildInquiryCard(context),
        ),
        const SizedBox(height: 8),
        KaidoCard(
          title: data.tips.title,
          icon: Icons.lightbulb,
          contentPadding: const EdgeInsets.all(8),
          child: _buildTipsCard(context),
        ),
      ],
    );
  }

  Widget _buildMapLegendCard(
    BuildContext context,
    HelpMainSections sections,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sections.routeDisplay.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...sections.routeDisplay.items.map(
          (item) => Column(
            children: [
              _MapLegendRow(
                color: Color(
                  int.parse(item.color.substring(1, 7), radix: 16) +
                      0xFF000000,
                ),
                title: item.title,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapIconsCard(
    BuildContext context,
    HelpMainSections sections,
    String assetPrefix,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sections.mapIcons.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...sections.mapIcons.items.map(
          (item) => Column(
            children: [
              _MapImageRow(
                title: item.title,
                assetPath: '$assetPrefix/map/${item.icon}',
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapTipsCard(
    BuildContext context,
    HelpMainSections sections,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sections.operations.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...sections.operations.items.map(
          (item) => Column(
            children: [
              _MapTipRow(
                title: item.title,
                description: item.description,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolbarCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...data.toolbar.items.map(
          (item) => Column(
            children: [
              _ToolbarRow(
                icon: kaidoIconFromName(item.icon) ?? Icons.error,
                description: item.description,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataUpdateCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dataUpdate = data.dataUpdate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dataUpdate.info.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(dataUpdate.info.description),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning,
                color: colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dataUpdate.warning,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInquiryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inquiry = data.inquiry;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.mail,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(inquiry.mainText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(inquiry.helpText),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...inquiry.requiredInfo.map(
                      (info) => _BulletPoint(text: info),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_camera,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        inquiry.screenshotNote.text,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...data.tips.items.map(
          (tip) => Column(
            children: [
              _TipRow(
                icon: kaidoIconFromName(tip.icon) ?? Icons.error,
                title: tip.title,
                description: tip.description,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

/// 白背景の小さなプレビュー枠。
class _LegendThumbnail extends StatelessWidget {
  const _LegendThumbnail({
    required this.child,
    this.padding = const EdgeInsets.all(8),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// ルート凡例の1行。
class _MapLegendRow extends StatelessWidget {
  const _MapLegendRow({required this.color, required this.title});

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _LegendThumbnail(
            child: CustomPaint(
              painter: LinePainter(color: color),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// マップアイコン凡例の1行。
class _MapImageRow extends StatelessWidget {
  const _MapImageRow({required this.title, required this.assetPath});

  final String title;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _LegendThumbnail(
            padding: const EdgeInsets.all(2),
            child: Image.asset(
              assetPath,
              width: 25,
              height: 35,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.place,
                size: 20,
                color: colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// 操作方法の1行。
class _MapTipRow extends StatelessWidget {
  const _MapTipRow({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _LegendThumbnail(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.info_outline,
              size: 20,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
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

/// 下部ツールバー説明の1行。
class _ToolbarRow extends StatelessWidget {
  const _ToolbarRow({required this.icon, required this.description});

  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _LegendThumbnail(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(icon),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
}

/// 上手に使うコツの1行。
class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.secondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 箇条書きの1行。
class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// ルート凡例用の直線を描画する [CustomPainter]。
class LinePainter extends CustomPainter {
  /// Creates a [LinePainter].
  LinePainter({required this.color});

  /// 線の色。
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
