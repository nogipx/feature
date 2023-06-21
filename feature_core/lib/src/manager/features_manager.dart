import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

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

  void requestPullFeatures() => _updater?.notifyNeedUpdate(key);

  Future<Iterable<FeatureAbstract>> pullFeatures();
}

class FeaturesManager {
  final _logger = Logger('FeaturesManager');

  final List<FeaturesProvider> _providers;
  final FeaturesContainer _featuresContainer;
  final _updater = WeakReference(FeaturesProviderUpdater());

  final void Function(MappedFeatures)? _updateListener;

  FeaturesManager({
    List<FeaturesProvider> providers = const [],
    void Function(MappedFeatures)? updateListener,
  })  : _providers = providers,
        _updateListener = updateListener,
        _featuresContainer = FeaturesContainer() {
    for (final provider in providers) {
      if (provider.needUpdater) {
        provider._updater = _updater.target;
      }
    }
    _updater.target?.addListener(_providerPullRequestListener);
  }

  void _providerPullRequestListener(String providerKey) async {
    _updateProviderByKey(providerKey);
  }

  Map<String, FeatureAbstract> get features => _featuresContainer.features;

  FeatureAbstract? getFeature(String key) {
    return _featuresContainer.getFeature(key);
  }

  Future<void> forceReloadFeatures() async {
    final features = await PullFeaturesUseCase(_providers).run();
    _featuresContainer.replaceAllFeatures(features);
    _onUpdate(_featuresContainer.features);
  }

  Future<void> _updateProviderByKey(String providerKey) async {
    if (providerKey.isEmpty) {
      return;
    }

    final provider = _providers.firstWhereOrNull((e) => e.key == providerKey);
    if (provider != null) {
      final features = await PullFeaturesUseCase([provider]).run();
      for (final newFeature in features) {
        try {
          _featuresContainer.replaceFeature(newFeature);
        } catch (e) {
          _logger.warning(e.toString());
        }
      }
    }
    _onUpdate(_featuresContainer.features);
  }

  @protected
  void _onUpdate(MappedFeatures features) {
    _updateListener?.call(features);
  }

  @mustCallSuper
  void dispose() {
    _updater.target?.removeListener(_providerPullRequestListener);
    _featuresContainer.replaceAllFeatures([]);
  }
}

class FeaturesManagerStreamed extends FeaturesManager {
  late final BehaviorSubject<MappedFeatures> _controller;

  Stream<MappedFeatures> get stream => _controller.stream;

  FeaturesManagerStreamed({
    List<FeaturesProvider> providers = const [],
  }) : super(providers: providers) {
    _controller = BehaviorSubject.seeded({});
  }

  @override
  void _onUpdate(MappedFeatures features) {
    _controller.sink.add(features);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }
}
