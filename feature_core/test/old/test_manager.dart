// import 'package:feature_core/feature_core.dart';
//
// import 'package:test/test.dart';
//
// import 'test_data.dart';
//
// void main() {
//   group('t', () {
//     test('Test single feature stream', () async {
//       final testSource = TestFeatureSource();
//       final manager = FeaturesManager(
//         sources: {testSource},
//       );
//       manager.featureStream('test1')?.listen((event) {
//         print('Only Test1Feature stream: $event');
//       });
//
//       manager.stream.listen((event) {
//         print('All features update: $event');
//       });
//
//       await manager.init();
//       await Future.delayed(const Duration(seconds: 10));
//       testSource.toggleFirstTestFeature();
//     });
//   });
// }
