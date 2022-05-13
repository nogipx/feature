import 'dart:async';
import 'feature_source.dart';
import 'feature.dart';
import 'package:rxdart/rxdart.dart';

class FeaturesManager {
  late StreamSubscription _combinerSubscription;

  Stream<Map<String, Feature>> get stream => _features.stream;

  late final BehaviorSubject<Map<String, Feature>> _features =
      BehaviorSubject();

  Map<String, Feature> get data => Map.unmodifiable(_features.value);

  final Set<FeatureSource> _sources;

  FeaturesManager({
    Set<FeatureSource> sources = const {},
  }) : _sources = sources {
    _combinerSubscription = CombineLatestStream(
      sources.map((e) => e.stream),
      (List<Map<String, Feature>> allFeaturesMaps) {
        final flatten =
            Map.fromEntries(allFeaturesMaps.expand((e) => e.entries));
        flatten.remove('');
        return flatten;
      },
    ).listen((value) {
      _features.sink.add(value);
    });
  }

  Stream<Feature>? featureStream(String key) {
    if (getFeature(key) == null) {
      return null;
    }
    return stream.expand((e) => e.values).where((e) => e.key == key);
  }

  bool check(String key, dynamic value) =>
      this.value(key) == value || getFeature(key)?.value == value;

  dynamic value(String key) => getFeature(key)?.dynamicValue;

  Feature? getFeature(String key) => data[key];

  T? getSource<T extends FeatureSource>() {
    final match = _sources.whereType<T>();
    return match.isNotEmpty ? match.first : null;
  }

  Future<void> init() async {
    await Future.forEach<FeatureSource>(
      _sources,
      (s) async {
        await s.pull();
      },
    );
  }

  void dispose() {
    _features.close();
    _combinerSubscription.cancel();
    for (var source in _sources) {
      source.dispose();
    }
  }
}
