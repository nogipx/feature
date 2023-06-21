import 'package:logging/logging.dart';

import '../manager/_index.dart';
import '../models/_index.dart';

final _logger = Logger('PullFeaturesUseCase');

class PullFeaturesUseCase {
  final Iterable<FeaturesProvider> providers;

  const PullFeaturesUseCase(this.providers);

  Future<List<FeatureAbstract>> run() async {
    final newFeaturesPool = await Future.wait(
      providers.map((provider) async {
        try {
          return await provider.pullFeatures();
        } catch (e, stackTrace) {
          _logger.severe(
            'Cannot pull features from "${provider.key}" provider. $e',
            e,
            stackTrace,
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
