import 'dart:developer' as dev;

import 'package:logging/logging.dart';

import '../manager/_index.dart';
import '../models/_index.dart';

class PullFeaturesUseCase {
  final Iterable<FeaturesProvider> providers;

  const PullFeaturesUseCase(this.providers);

  Future<List<FeatureAbstract>> run() async {
    final newFeaturesPool = await Future.wait(
      providers.map((provider) async {
        try {
          return await provider.pullFeatures();
        } catch (e, stackTrace) {
          dev.log(
            'Cannot pull features from "${provider.key}" provider.',
            name: 'PullFeaturesUseCase',
            error: e,
            stackTrace: stackTrace,
            level: Level.SEVERE.value,
          );
          return <FeatureAbstract>[];
        }
      }),
    );

    final newFeatures = newFeaturesPool.fold<List<FeatureAbstract>>(
      [],
      (acc, e) => acc..addAll(e),
    );

    return newFeatures.toList();
  }
}
