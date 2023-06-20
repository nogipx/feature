// import 'dart:async';
// import 'dart:developer' as dev;
//
// import 'package:feature_core/src/feature.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:meta/meta.dart';
//
// abstract class FeatureSource {
//   late final String name;
//
//   late final BehaviorSubject<Map<String, AbstractFeature>> _subject =
//       BehaviorSubject.seeded({'': StubFeature()});
//
//   late final BehaviorSubject<bool> _needUpdate = BehaviorSubject.seeded(false);
//
//   late final StreamSubscription _listenNewState;
//   late final StreamSubscription _listenMarkUpdate;
//
//   Stream<Map<String, AbstractFeature>> get stream => _subject.stream;
//
//   Map<String, AbstractFeature> _features = {};
//   Map<String, AbstractFeature> get features => Map.unmodifiable(_features);
//
//   FeatureSource({this.name = ''}) {
//     _listenNewState = stream.listen((e) {
//       _features = e;
//       _features.remove('');
//     });
//     _listenMarkUpdate = _needUpdate.listen((flag) {
//       if (flag) {
//         onReceiveNeedUpdate();
//       }
//     });
//   }
//
//   @mustCallSuper
//   FutureOr<void> onReceiveNeedUpdate() {
//     _needUpdate.add(false);
//   }
//
//   void notifyNeedUpdate() => _needUpdate.add(true);
//
//   void _emitUpdate() => _subject.add(_features);
//
//   bool containsFeature(String key) => getFeature(key) != null;
//
//   AbstractFeature? getFeature(String key) => _features[key];
//
//   T? getFeatureByType<T extends AbstractFeature>() {
//     final feature = getFeature(T.toString());
//     return feature is T ? feature : null;
//   }
//
//   FutureOr<void> updateFeature(AbstractFeature feature) {
//     _features[feature.key] = feature;
//     _emitUpdate();
//   }
//
//   FutureOr<void> updateAllFeatures(Iterable<AbstractFeature> features) {
//     for (final feature in features) {
//       _features[feature.key] = feature;
//     }
//     _emitUpdate();
//   }
//
//   @protected
//   FutureOr<void> reset() {
//     _subject.add({});
//     _subject.drain();
//   }
//
//   @protected
//   FutureOr<Iterable<AbstractFeature>> pullFeatures();
//
//   FutureOr<void> pull() async {
//     try {
//       final features = await pullFeatures();
//       updateAllFeatures(features);
//     } on Exception catch (e, stackTrace) {
//       print(e.toString());
//       dev.log(
//         e.toString(),
//         stackTrace: stackTrace,
//         name: runtimeType.toString(),
//       );
//     }
//   }
//
//   @mustCallSuper
//   void dispose() {
//     _listenNewState.cancel();
//     _listenMarkUpdate.cancel();
//     _subject.close();
//     _needUpdate.close();
//   }
// }
