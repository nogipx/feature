import 'dart:async';

import 'package:feature_core/feature_core.dart';

class LocalFeatureSource extends FeatureSource {
  LocalFeatureSource({
    required List<Feature> features,
  }) {
    updateAllFeatures(features);
  }

  @override
  FutureOr<Iterable<Feature>> pullFeatures() {
    return features.values;
  }
}
