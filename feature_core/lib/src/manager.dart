import 'dart:async';
import 'feature_source.dart';
import 'feature.dart';
import 'package:rxdart/rxdart.dart';

class FeaturesManager {
  StreamSubscription? _combinerSubscription;

  Stream<Map<String, Feature>> get stream => _features.stream;

  late final BehaviorSubject<Map<String, Feature>> _features =
      BehaviorSubject();

  Map<String, Feature> get data => Map.unmodifiable(_features.value);

  final List<FeatureSource> _sources;

  FeaturesManager({
    List<FeatureSource> sources = const [],
  }) : _sources = sources {
    _combinerSubscription = CombineLatestStream(
      sources.map((e) => e.featuresStream),
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
    if (get(key) == null) {
      return null;
    }

    return stream.expand((e) => e.values).where((e) => e.key == key);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        final feature = data[key];
        if (feature != null) {
          sink.add(feature);
        }
      },
    ));
  }

  bool check(String key, dynamic value) =>
      this.value(key) == value || get(key)?.value == value;

  dynamic value(String key) => get(key)?.dynamicValue;

  Feature? get(String key) => data[key];

  Future<void> init() async {
    await Future.forEach<FeatureSource>(
      _sources,
      (s) async => MapEntry(s.runtimeType, await s.pull()),
    );
  }

  void dispose() {
    _features.close();
    for (var source in _sources) {
      source.dispose();
    }
  }
}
