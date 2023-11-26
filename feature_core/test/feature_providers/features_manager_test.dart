import 'package:feature_core/feature_core.dart';
import 'package:test/test.dart';

import 'updater_provider.dart';

void main() {
  test('Feature provider can request pulling features', () async {
    final providerWithUpdater = TestFeatureProviderWithUpdater(
      key: 'with_updater',
    );
    final providerWithoutUpdater = TestFeatureProviderWithUpdater(
      key: 'without_updater',
      enableUpdater: false,
    );

    final sut = FeaturesManager(
      providers: [
        providerWithUpdater,
        providerWithoutUpdater,
      ],
    );

    providerWithUpdater.requestPullFeatures();
    providerWithoutUpdater.requestPullFeatures();

    expect(providerWithUpdater.count, equals(1));
    expect(providerWithoutUpdater.count, equals(0));

    await Future.delayed(const Duration(milliseconds: 1));

    expect(
      sut.getFeature(providerWithUpdater.testFeatureKey)?.value,
      equals(1),
    );
    expect(
      sut.getFeature(providerWithoutUpdater.testFeatureKey),
      isNull,
    );
  });
}
