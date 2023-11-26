import '../models/_index.dart';
import '_index.dart';

base class FeaturesContainer implements IFeaturesContainer {
  FeaturesContainer() : _features = {};

  @override
  MappedFeatures get features => Map.unmodifiable(_features);
  final MappedFeatures _features;

  @override
  FeatureAbstract? getFeature(String key) => _features[key];

  @override
  bool containsFeature(String key) => _features.containsKey(key);

  @override
  void replaceAllFeatures(Iterable<FeatureAbstract> newFeatures) {
    _guardAllFeaturesKeysUnique(newFeatures);
    _features.clear();
    for (final feature in newFeatures) {
      _features[feature.key] = feature;
    }
  }

  @override
  void addOrReplaceFeature(FeatureAbstract newFeature) {
    _features[newFeature.key] = newFeature;
  }

  @override
  void updateFeature(FeatureAbstract newFeature) {
    if (!containsFeature(newFeature.key)) {
      throw Exception('Feature key "${newFeature.key}" not found.');
    }
    addOrReplaceFeature(newFeature);
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
