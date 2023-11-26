import '../models/_index.dart';

abstract interface class IFeaturesManager {
  MappedFeatures get features;

  Stream<MappedFeatures> get featuresStream;

  FeatureAbstract? getFeature(String key);

  Future<void> forceReloadFeatures();

  bool isOverridden(String key);

  void overrideFeature(FeatureAbstract feature);

  void clearOverrides({String? key});

  void dispose();
}

abstract interface class IFeaturesContainer {
  MappedFeatures get features;

  FeatureAbstract? getFeature(String key);

  bool containsFeature(String key);

  void replaceAllFeatures(Iterable<FeatureAbstract> newFeatures);

  void addOrReplaceFeature(FeatureAbstract newFeature);

  void updateFeature(FeatureAbstract newFeature);

  void removeFeature(String key);

  void clearAllFeatures();
}

typedef MappedFeatures = Map<String, FeatureAbstract>;
