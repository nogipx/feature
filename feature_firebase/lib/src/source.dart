import 'dart:async';

import 'package:feature_core/feature_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'feature.dart';

class FirebaseFeatureSource extends FeatureSource {
  final Duration minimumFetchInterval;
  final Duration fetchTimeout;

  final FirebaseRemoteConfig _remoteConfig;

  FirebaseFeatureSource({
    required FirebaseRemoteConfig remoteConfig,
    this.minimumFetchInterval = const Duration(hours: 12),
    this.fetchTimeout = const Duration(minutes: 1),
  }) : _remoteConfig = remoteConfig {
    _remoteConfig
      // ..addListener(_onUpdate)
      ..setConfigSettings(RemoteConfigSettings(
        fetchTimeout: fetchTimeout,
        minimumFetchInterval: minimumFetchInterval,
      ))
      ..fetchAndActivate();
  }

  @override
  void dispose() {
    super.dispose();
    // _remoteConfig.removeListener(_onUpdate);
  }

  @override
  @protected
  FutureOr<Iterable<Feature>> pullFeatures() async {
    final features = _remoteConfig.getAll().entries.map((e) {
      final raw = FirebaseFeature(
        key: e.key,
        value: e.value.asString(),
      );
      if (raw.dynamicValue is bool) {
        return FirebaseFeature<bool>(key: raw.key, value: raw.dynamicValue);
      }
      return raw;
    }).toList();

    return features;
  }

  Future<void> _onUpdate() async {
    await pull();
  }
}
