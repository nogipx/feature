import 'package:feature_core/feature_core.dart';
import 'package:test/test.dart';

import 'updater_provider.dart';

void main() {
  group('Features manager', () {
    test('Feature provider can request pulling features', () async {
      final providerWithUpdater = TestFeatureProviderWithUpdater(
        key: 'with_updater',
        needUpdater: true,
      );
      final providerWithoutUpdater = TestFeatureProviderWithUpdater(
        key: 'without_updater',
        needUpdater: false,
      );

      final sut = FeaturesManager(
        providers: [
          providerWithUpdater,
          providerWithoutUpdater,
        ],
      );

      providerWithUpdater.notifyNeedUpdate();
      providerWithoutUpdater.notifyNeedUpdate();

      expect(sut.providers.first.needUpdater, isTrue);
      expect(sut.providers.last.needUpdater, isFalse);
      expect(providerWithUpdater.count, equals(1));
      expect(providerWithoutUpdater.count, equals(0));

      await Future.delayed(const Duration(milliseconds: 1));

      expect(
        sut.getFeature(providerWithUpdater.testFeatureKey)?.dynamicValue,
        equals(1),
      );
      expect(
        sut.getFeature(providerWithoutUpdater.testFeatureKey),
        isNull,
      );
    });
  });
}
