import 'dart:async';
import 'feature_source.dart';
import 'feature.dart';
import 'package:rxdart/rxdart.dart';

class FeaturesManager {
  late final Stream<Map<String, Feature>> stream;

  Map<String, Feature> _features = {};
  Map<String, Feature> get data => Map.unmodifiable(_features);

  final List<FeatureSource> _sources;

  FeaturesManager({
    List<FeatureSource> sources = const [],
  }) : _sources = sources {
    stream = CombineLatestStream(
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

  bool check(String key, dynamic value) =>
      this.value(key) == value || get(key)?.value == value;

  dynamic value(String key) => get(key)?.dynamicValue;

  Feature? get(String key) => _features[key];

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
