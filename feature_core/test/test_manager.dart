import 'package:feature_core/feature_core.dart';

import 'package:test/test.dart';

import 'test_data.dart';

void main() {
  group('t', () {
    late final Features manager;
    setUp(() async {
      manager = Features(
        sources: [
          LocalFeatureSource(),
          ServerFeatureSource(),
        ],
      );
      await manager.init();
    });

    test('Test firebase', () async {
      manager.featuresStream.listen((event) {
        print(event);
      });
      await Future<void>.delayed(const Duration(seconds: 1));
      print(manager.features);
      await Future<void>.delayed(const Duration(seconds: 8));
    });
  });
}
