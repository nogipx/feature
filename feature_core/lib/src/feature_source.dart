import 'dart:async';
import 'dart:developer' as dev;

import 'package:feature_core/src/feature.dart';
import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';

abstract class FeatureSource {
  late final BehaviorSubject<Map<String, Feature>> _subject =
      BehaviorSubject.seeded({'': StubFeature()});

  late final StreamSubscription _listenNewState;

  Stream<Map<String, Feature>> get stream => _subject.stream;

  Map<String, Feature> _features = {};
  Map<String, Feature> get data => Map.unmodifiable(_features);

  FeatureSource() {
    _listenNewState = stream.listen((e) {
      _features = e;
    });
  }

  void _emitUpdate() => _subject.add(_features);

  bool containsFeature(String key) => getFeature(key) != null;

  Feature? getFeature(String key) => _features[key];

  FutureOr<void> updateFeature(Feature feature) {
    _features[feature.key] = feature;
    _emitUpdate();
  }

  FutureOr<void> updateAllFeatures(Iterable<Feature> features) {
    for (final feature in features) {
      _features[feature.key] = feature;
    }
    _emitUpdate();
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
      updateAllFeatures(features);
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
}
