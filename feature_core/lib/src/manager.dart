import 'dart:async';
import 'package:feature_core/src/feature_source.dart';
import 'package:rxdart/rxdart.dart';

import 'package:feature_core/src/feature.dart';

class Features {
  late final Stream<Map<String, Feature>> featuresStream;

  Map<String, Feature> _features = {};
  Map<String, Feature> get features => Map.unmodifiable(_features);

  final List<FeatureSource> _sources;

  static Features? _instance;

  factory Features({
    List<FeatureSource> sources = const [],
  }) {
    _instance ??= Features._(sources: sources);
    return _instance!;
  }

  Features._({
    List<FeatureSource> sources = const [],
  }) : _sources = sources {
    featuresStream = CombineLatestStream(
      sources.map((e) => e.featuresStream),
      (List<Map<String, Feature>> allFeaturesMaps) {
        final flatten =
            Map.fromEntries(allFeaturesMaps.expand((e) => e.entries));
        flatten.remove('');
        _features = flatten;
        return flatten;
      },
    );
  }

  Feature? get(String key) => _features[key];

  dynamic value(String key) => get(key)?.dynamicValue;

  Future<void> init() async {
    await Future.forEach<FeatureSource>(
      _sources,
      (s) async => MapEntry(s.runtimeType, await s.pull()),
    );
  }

  void dispose() {
    for (var source in _sources) {
      source.dispose();
    }
  }
}
