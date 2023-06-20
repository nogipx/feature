import '_index.dart';

class FeatureStub extends FeatureAbstract<void> {
  const FeatureStub() : super(key: '', value: '');
}

class FeatureGeneric<T> extends FeatureAbstract<T> {
  const FeatureGeneric({
    required String key,
    required T value,
  }) : super(key: key, value: value);

  @override
  FeatureAbstract<T> copyWith({required T value}) {
    return FeatureGeneric(key: key, value: value);
  }
}

class FeatureBool extends FeatureAbstract<bool> {
  const FeatureBool({
    required String key,
    required bool value,
  }) : super(key: key, value: value);
}
