// import 'dart:async';
//
// import 'package:feature_core/feature_core.dart';
//
// class SearchFeature extends AbstractFeature<bool> {
//   SearchFeature() : super(value: true, enabled: true);
// }
//
// class OAuthFeature extends FeatureToggle {
//   OAuthFeature() : super(value: false);
// }
//
// class TestFeature extends AbstractFeature<bool> {
//   TestFeature(String key, bool value) : super(key: key, value: value);
// }
//
// class LocalFeatureSource extends FeatureSource {
//   LocalFeatureSource() {
//     Future<void>.delayed(const Duration(seconds: 4)).then((value) {
//       reset();
//     });
//   }
//
//   @override
//   FutureOr<List<AbstractFeature>> pullFeatures() => [
//         SearchFeature(),
//       ];
// }
//
// class TestFeatureSource extends FeatureSource {
//   bool _firstTestValue = false;
//   bool _secondTestValue = false;
//
//   @override
//   FutureOr<List<AbstractFeature>> pullFeatures() => [
//         TestFeature('test1', _firstTestValue),
//         TestFeature('test2', _secondTestValue),
//       ];
//
//   Future<void> toggleFirstTestFeature() async {
//     _firstTestValue = true;
//     await pull();
//   }
// }
