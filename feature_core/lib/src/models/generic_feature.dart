import '_index.dart';

base class FeatureGeneric<T> extends FeatureAbstract<T> {
  const FeatureGeneric({
    required String key,
    required T value,
  }) : super(key: key, value: value);

  @override
  FeatureAbstract<T> copyWith({required T value}) {
    return FeatureGeneric(key: key, value: value);
  }
}
