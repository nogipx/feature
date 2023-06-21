import 'dart:developer' as dev;

import 'package:data_manage/data_manage.dart';
import 'package:logging/logging.dart';

import '../manager/_index.dart';
import '../models/_index.dart';

class PullFeaturesUseCase extends UseCaseAsync<List<FeatureAbstract>> {
  final Iterable<FeaturesProvider> providers;

  const PullFeaturesUseCase(this.providers);

  @override
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
