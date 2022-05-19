import 'package:feature_core/feature_core.dart';

mixin TogglingFeatureSourceMixin on FeatureSource {
  void toggle(String key) {
    final feature = getFeature(key);
    if (feature != null) {
      setEnable(key, !feature.enabled);
    }
  }

  void toggleByType<T extends Feature>() {
    final feature = getFeatureByType<T>();
    if (feature != null) {
      setEnable(feature.key, !feature.enabled);
    }
  }

  void setEnable(String key, bool value) {
    final feature = getFeature(key);
    if (feature != null) {
      final newFeature = feature.copyWith(enabled: value);
      updateFeature(newFeature);
    }
  }
}
