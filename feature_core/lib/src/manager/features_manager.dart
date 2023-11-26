import 'dart:async';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../models/_index.dart';
import '../usecases/_index.dart';
import '../utils/_index.dart';
import '_index.dart';

base class FeaturesManager implements IFeaturesManager {
  FeaturesManager({
    List<FeaturesProvider>? providers,
    void Function(MappedFeatures)? updateListener,
    IFeaturesContainer? featuresContainer,
    Logger? logger,
  })  : _providers = providers ?? [],
        _updateListener = updateListener,
        _featuresContainer = featuresContainer ?? FeaturesContainer(),
        _logger = logger ?? Logger('FeaturesManager'),
        _streamController = StreamController() {
    for (final provider in _providers) {
      if (provider._needUpdater) {
        provider._updater = _updater;
      }
    }
    _updater.addListener(_updateProviderByKey);
  }

  final Logger _logger;

  final List<FeaturesProvider> _providers;
  final IFeaturesContainer _featuresContainer;
  final _updater = _FeaturesProviderUpdater();

  final void Function(MappedFeatures)? _updateListener;

  final StreamController<MappedFeatures> _streamController;

  @override
  MappedFeatures get features => _featuresContainer.features;

  @override
  late final featuresStream = _streamController.stream.asBroadcastStream();

  @override
  FeatureAbstract? getFeature(String key) {
    return _featuresContainer.getFeature(key);
  }

  @override
  Future<void> forceReloadFeatures() async {
    final features = await PullFeaturesUseCase(_providers).run();
    _featuresContainer.replaceAllFeatures(features);
    _onUpdate(_featuresContainer.features);
  }

  @override
  @mustCallSuper
  void dispose() {
    _streamController.close();
    _updater.removeListener(_updateProviderByKey);
    _featuresContainer.replaceAllFeatures([]);
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
          _featuresContainer.addOrReplaceFeature(newFeature);
        } catch (error) {
          print(error.toString());
          _logger.warning(error.toString());
        }
      }
    }
    _onUpdate(_featuresContainer.features);
  }

  @protected
  void _onUpdate(MappedFeatures features) {
    _updateListener?.call(features);
    _streamController.sink.add(features);
  }
}

base class FeaturesProvider {
  final String key;
  final String name;
  final bool _needUpdater;
  _FeaturesProviderUpdater? _updater;

  FeaturesProvider({
    required this.key,
    String? name,
    bool? enableUpdater,
  })  : _needUpdater = enableUpdater ?? true,
        name = name ?? key;

  void requestPullFeatures() => _updater?._notifyNeedUpdate(key);

  @mustBeOverridden
  Future<Iterable<FeatureAbstract>> pullFeatures() async {
    return [];
  }
}

class _FeaturesProviderUpdater extends FeatureProviderChangeNotifier {
  void _notifyNeedUpdate(String key) {
    notifyListeners(key);
  }
}
