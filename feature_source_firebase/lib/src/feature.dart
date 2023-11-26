import 'package:feature_core/feature_core.dart';

final class FeatureFirebase<T extends dynamic> extends FeatureGeneric<T> {
  const FeatureFirebase({
    required String key,
    required T value,
  }) : super(key: key, value: value);

  @override
  FeatureFirebase<T> copyWith({required value}) {
    return FeatureFirebase(key: key, value: value);
  }
}
