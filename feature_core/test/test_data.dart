import 'dart:async';

import 'package:feature_core/feature_core.dart';

class SearchFeature extends Feature<bool> {
  @override
  String? get name => runtimeType.toString();

  @override
  String get key => 'search_feature';

  @override
  bool get value => true;

  @override
  bool get isEnabled => true;
}

class OAuthFeature extends Feature<bool> {
  @override
  String? get name => runtimeType.toString();

  @override
  String get key => 'oauth_feature';

  @override
  bool get value => false;

  @override
  bool get isEnabled => false;
}

class TestFeature extends Feature<bool> {
  @override
  final bool value;
  final String key;

  TestFeature(this.key, this.value);

  @override
  String? get name => runtimeType.toString();

  @override
  bool get isEnabled => true;
}

class LocalFeatureSource extends FeatureSource {
  LocalFeatureSource() {
    Future<void>.delayed(const Duration(seconds: 4)).then((value) {
      reset();
    });
  }

  @override
  FutureOr<List<Feature>> pullFeatures() => [
        SearchFeature(),
      ];
}

class TestFeatureSource extends FeatureSource {
  bool _firstTestValue = false;
  bool _secondTestValue = false;

  @override
  FutureOr<List<Feature>> pullFeatures() => [
        TestFeature('test1', _firstTestValue),
        TestFeature('test2', _secondTestValue),
      ];

  Future<void> toggleFirstTestFeature() async {
    _firstTestValue = true;
    await pull();
  }
}
