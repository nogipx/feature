import '_index.dart';

class FeaturesContainer {
  final Map<String, FeatureAbstract> _features;

  FeaturesContainer() : _features = {};

  FeatureAbstract? getFeature(String key) => _features[key];

  bool containsFeature(String key) => _features.containsKey(key);

  void replaceAllFeatures(Iterable<FeatureAbstract> newFeatures) {
    _guardAllFeaturesKeysUnique(newFeatures);
    _features.clear();
    for (final feature in newFeatures) {
      _features[feature.key] = feature;
    }
  }

  void replaceFeature(FeatureAbstract newFeature) {
    _features[newFeature.key] = newFeature;
  }

  void updateFeature(FeatureAbstract newFeature) {
    if (!containsFeature(newFeature.key)) {
      throw Exception('Feature key "${newFeature.key}" not found.');
    }
    replaceFeature(newFeature);
  }

  void _guardAllFeaturesKeysUnique(Iterable<FeatureAbstract> features) {
    final keys = <String, int>{};
    for (final feature in features) {
      final count = keys.putIfAbsent(feature.key, () => 0);
      keys[feature.key] = count + 1;
    }

    final duplicates = keys.entries.where((e) => e.value > 1).toList();

    if (duplicates.isNotEmpty) {
      final message = duplicates
          .map((e) => 'Key "${e.key}" appears ${e.value} times;')
          .join('\n');
      throw Exception(
        'There are duplicates in features keys. '
        'Updating aborted. '
        '\n$message',
      );
    }
  }
}
