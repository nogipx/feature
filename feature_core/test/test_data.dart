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

class NewProfile extends Feature<bool> {
  @override
  String? get name => runtimeType.toString();

  @override
  String get key => 'new_profile_feature';

  @override
  bool get value => false;

  @override
  bool get isEnabled => false;
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

class ServerFeatureSource extends FeatureSource {
  ServerFeatureSource() {
    Future<void>.delayed(const Duration(seconds: 2)).then((value) {
      addFeature(NewProfile());
    });
    Future<void>.delayed(const Duration(seconds: 6)).then((value) {
      reset();
    });
  }

  @override
  FutureOr<List<Feature>> pullFeatures() => [
        OAuthFeature(),
      ];
}
