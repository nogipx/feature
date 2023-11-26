import '../models/_index.dart';

abstract interface class IFeaturesManager {
  MappedFeatures get features;

  Stream<MappedFeatures> get featuresStream;

  FeatureAbstract? getFeature(String key);

  Future<void> forceReloadFeatures();

  void dispose();
}

abstract interface class IFeaturesContainer {
  MappedFeatures get features;

  FeatureAbstract? getFeature(String key);

  bool containsFeature(String key);

  void replaceAllFeatures(Iterable<FeatureAbstract> newFeatures);

  void addOrReplaceFeature(FeatureAbstract newFeature);

  void updateFeature(FeatureAbstract newFeature);
}

typedef MappedFeatures = Map<String, FeatureAbstract>;
