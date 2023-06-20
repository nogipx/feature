import 'package:data_manage/data_manage.dart';

import '../manager/_index.dart';
import '../models/_index.dart';

class PullFeaturesUseCase extends UseCaseAsync<List<FeatureAbstract>> {
  final Iterable<FeaturesProvider> providers;

  const PullFeaturesUseCase(this.providers);

  @override
  Future<List<FeatureAbstract>> run() async {
    final newFeaturesPool =
        await Future.wait(providers.map((e) => e.pullFeatures()));

    final newFeatures = newFeaturesPool.fold<List<FeatureAbstract>>(
      [],
      (acc, e) => acc..addAll(e),
    );

    return newFeatures.toList();
  }
}
