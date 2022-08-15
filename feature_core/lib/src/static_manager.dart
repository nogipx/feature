import 'exception.dart';
import 'feature.dart';
import 'feature_source.dart';
import 'manager.dart';

abstract class Features {
  static FeaturesManager? _instance;

  static FeaturesManager get I {
    if (_instance != null) {
      return _instance!;
    } else {
      throw FeaturesNullException();
    }
  }

  static FeaturesManager connect({required FeaturesManager instance}) {
    _instance = instance;
    return I;
  }

  static Future<void> init() async {
    await I.init();
  }

  static Stream<Feature>? featureStream(String key) => I.featureStream(key);

  static bool check(String key, dynamic value) =>
      I.value(key) == value || I.getFeature(key)?.value == value;

  static dynamic value(String key) => I.getFeature(key)?.dynamicValue;

  static Feature? getFeature(String key) => I.getFeature(key);

  static T? getFeatureByType<T extends Feature>() => I.getFeatureByType<T>();

  static T? getSource<T extends FeatureSource>() => I.getSource<T>();

  static void dispose() => I.dispose();
}
