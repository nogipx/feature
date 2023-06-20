import 'dart:async';

import 'package:feature_core/feature_core.dart';

class TestFeatureProviderWithUpdater extends FeaturesProvider {
  TestFeatureProviderWithUpdater({
    required String key,
    bool needUpdater = false,
  }) : super(
          name: 'Periodic updates',
          key: key,
          needUpdater: needUpdater,
        );

  int count = 0;
  String get testFeatureKey => 'test_flag@$key';

  @override
  Future<Iterable<FeatureAbstract>> pullFeatures() async {
    count++;

    return [
      FeatureGeneric<int>(key: testFeatureKey, value: count),
    ];
  }
}
