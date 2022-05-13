import 'package:feature_core/feature_core.dart';

mixin TogglingSourceMixin on FeatureSource {
  void toggle(String key) {
    final feature = getFeature(key);
    if (feature != null) {
      setEnable(key, !feature.enabled);
    }
  }

  void toggleByType<T>() {
    final key = T.toString();
    toggle(key);
  }

  void setEnable(String key, bool value) {
    final feature = getFeature(key);
    if (feature != null) {
      final newFeature = feature.copyWith(enabled: value);
      updateFeature(newFeature);
    }
  }
}
