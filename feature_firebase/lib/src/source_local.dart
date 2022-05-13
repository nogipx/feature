import 'dart:async';

import 'package:feature_core/feature_core.dart';

class LocalFeatureSource extends FeatureSource with TogglingSourceMixin {
  LocalFeatureSource({
    required List<FeatureToggle> features,
  }) {
    updateAllFeatures(features);
  }

  @override
  FutureOr<Iterable<Feature>> pullFeatures() {
    return data.values;
  }
}
