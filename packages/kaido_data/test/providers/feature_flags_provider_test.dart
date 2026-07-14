import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_data/kaido_data.dart';

void main() {
  group('heading3dFeatureEnabledProvider', () {
    test('FEATURE_3D_HEADING 未設定時は無効になる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(heading3dFeatureEnabledProvider), isFalse);
    });

    test('テストからは override で有効化できる', () {
      final container = ProviderContainer(
        overrides: [heading3dFeatureEnabledProvider.overrideWithValue(true)],
      );
      addTearDown(container.dispose);

      expect(container.read(heading3dFeatureEnabledProvider), isTrue);
    });
  });
}
