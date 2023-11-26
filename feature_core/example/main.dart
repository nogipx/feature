import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:feature_core/feature_core.dart';
import 'package:logging/logging.dart';

class SomeDependency {
  final _rnd = Random();

  Future<String> getFeatures() async {
    final feature2Value = _rnd.nextInt(20);
    final feature1Value = feature2Value > 10;

    return '[{"key": "feature1", "value": "$feature1Value"},{"key": "feature2", "value": $feature2Value}]';
  }
}

final class TestFeatureProvider extends FeaturesProvider {
  final SomeDependency dependency;

  TestFeatureProvider({
    required this.dependency,
  }) : super(
          name: 'Test provider',
          key: 'test_provider',
          enableUpdater: true,
        ) {
    Timer.periodic(
      const Duration(seconds: 4),
      (timer) {
        requestPullFeatures();
      },
    );
  }

  @override
  Future<Iterable<FeatureAbstract>> pullFeatures() async {
    final json = jsonDecode(await dependency.getFeatures()) as List<dynamic>;

    final features = json.map(
      (e) => FeatureGeneric(
        key: e['key'],
        value: e['value'],
      ),
    );

    return features;
  }
}

void main() {
  Logger.root.onRecord.listen((event) {
    print(event);
  });

  FeaturesManager(
    providers: [
      TestFeatureProvider(dependency: SomeDependency()),
    ],
    updateListener: (features) {
      print(
        'Features updated! '
        '\n${features.values.map((e) => e.toString()).join('\n')}',
      );
      print('');
    },
  );
}
