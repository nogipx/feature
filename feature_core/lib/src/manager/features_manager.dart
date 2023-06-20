import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

import '../models/_index.dart';
import '../usecases/_index.dart';
import '../utils/_index.dart';
import '_index.dart';

class FeaturesProviderUpdater extends ChangeNotifier {
  void notifyNeedUpdate(String key) {
    notifyListeners(key);
  }
}

abstract class FeaturesProvider {
  final String name;
  final String key;
  final bool needUpdater;
  FeaturesProviderUpdater? _updater;

  FeaturesProvider({
    required this.name,
    required this.key,
    this.needUpdater = false,
  });

  void notifyNeedUpdate() => _updater?.notifyNeedUpdate(key);

  Future<Iterable<FeatureAbstract>> pullFeatures();
}

class FeaturesManager {
  final _logger = Logger('FeaturesManager');

  final List<FeaturesProvider> providers;
  final FeaturesContainer _featuresContainer;
  final updater = WeakReference(FeaturesProviderUpdater());

  FeaturesManager({
    this.providers = const [],
  }) : _featuresContainer = FeaturesContainer() {
    for (final provider in providers) {
      if (provider.needUpdater) {
        provider._updater = updater.target;
      }
    }
    updater.target?.addListener((key) async {
      _updateProviderByKey(key);
    });
  }

  FeatureAbstract? getFeature(String key) {
    return _featuresContainer.getFeature(key);
  }

  Future<void> _updateProviderByKey(String providerKey) async {
    final provider = providers.firstWhereOrNull((e) => e.key == providerKey);
    if (provider != null) {
      final features = await provider.pullFeatures();
      for (final newFeature in features) {
        try {
          _featuresContainer.replaceFeature(newFeature);
        } catch (e) {
          _logger.warning(e.toString());
        }
      }
    }
  }

  Future<void> forceReloadFeatures() async {
    final features = await PullFeaturesUseCase(providers).run();
    _featuresContainer.replaceAllFeatures(features);
  }
}
