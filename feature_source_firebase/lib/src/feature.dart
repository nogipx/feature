import 'package:feature_core/feature_core.dart';

class FeatureFirebase<T extends dynamic> extends FeatureGeneric<T> {
  const FeatureFirebase({
    required String key,
    required T value,
  }) : super(key: key, value: value);
}
