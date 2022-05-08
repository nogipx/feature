import 'dart:async';
import 'dart:developer' as dev;

import 'package:feature_core/src/feature.dart';
import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';

abstract class FeatureSource {
  late final BehaviorSubject<Map<String, Feature>> _subject =
      BehaviorSubject.seeded({'': StubFeature()});

  late final StreamSubscription _listenNewState;

  Stream<Map<String, Feature>> get featuresStream => _subject.stream;

  Map<String, Feature> _features = {};
  Map<String, Feature> get features => Map.unmodifiable(_features);

  FeatureSource() {
    _listenNewState = featuresStream.listen((e) {
      _features = e;
    });
  }

  bool containsFeature(String key) => feature(key) != null;

  Feature? feature(String key) => _features[key];

  @protected
  FutureOr<void> addFeature(Feature feature) {
    _features[feature.key] = feature;
    _subject.add(_features);
  }

  @protected
  FutureOr<void> reset() {
    _subject.add({});
    _subject.drain();
  }

  @protected
  FutureOr<Iterable<Feature>> pullFeatures();

  FutureOr<void> pull() async {
    try {
      final features = await pullFeatures();
      _subject.add(_processNewFeatures(features));
    } on Exception catch (e, stackTrace) {
      print(e.toString());
      dev.log(
        e.toString(),
        stackTrace: stackTrace,
        name: runtimeType.toString(),
      );
    }
  }

  @mustCallSuper
  void dispose() {
    _listenNewState.cancel();
    _subject.close();
  }

  Map<String, Feature> _processNewFeatures(Iterable<Feature> data) {
    return Map.fromEntries(data.map((e) => MapEntry(e.key, e)));
  }
}
