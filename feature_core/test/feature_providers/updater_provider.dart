import 'dart:async';

import 'package:feature_core/feature_core.dart';

final class TestFeatureProviderWithUpdater extends FeaturesProvider {
  TestFeatureProviderWithUpdater({
    required super.key,
    super.enableUpdater,
  }) : super(name: 'Periodic updates');

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
