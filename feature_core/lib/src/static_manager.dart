import 'exception.dart';
import 'feature.dart';
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

  static bool check(String key, dynamic value) =>
      I.value(key) == value || I.get(key)?.value == value;

  static dynamic value(String key) => I.get(key)?.dynamicValue;

  static Feature? get(String key) => I.data[key];

  static void dispose() => I.dispose();
}
