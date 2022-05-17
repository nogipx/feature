import 'dart:async';
import 'dart:convert';

import 'package:feature_core/feature_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RetainFeatureSourceWrapper implements TogglingFeatureSourceWrapper {
  late final _key = 'retain_feature_source#$tag';

  @override
  final TogglingFeatureSourceWrapper source;
  final SharedPreferences preferences;
  final String tag;

  @override
  String name;

  RetainFeatureSourceWrapper({
    required this.source,
    required this.preferences,
    required this.tag,
    this.name = '',
  });

  @override
  bool containsFeature(String key) => source.containsFeature(key);

  @override
  void dispose() => source.dispose();

  @override
  Map<String, Feature> get features => source.features;

  @override
  Feature? getFeature(String key) => source.getFeature(key);

  @override
  T? getFeatureByType<T extends Feature>() => source.getFeatureByType<T>();

  @override
  FutureOr<void> pull() async => updateAllFeatures(await pullFeatures());

  @override
  Stream<Map<String, Feature>> get stream => source.stream;

  @override
  FutureOr<void> updateAllFeatures(Iterable<Feature> features) =>
      source.updateAllFeatures(features);

  @override
  FutureOr<void> updateFeature(Feature feature) =>
      source.updateFeature(feature);

  @override
  void setEnable(String key, bool value) => source.setEnable(key, value);

  @override
  void toggleByType<T extends Feature>() => source.toggleByType<T>();

  @override
  void toggle(String key) {
    source.toggle(key);
    final updatedFeature = getFeature(key);
    if (updatedFeature != null) {
      _persistFeature(updatedFeature);
    }
  }

  @override
  FutureOr<void> reset() async {
    source.reset();
    await Future.wait(features.values.map(
      (e) async {
        await preferences.remove(_serializeFeatureKey(e.key));
      },
    ));
  }

  @override
  void notifyNeedUpdate() => source.notifyNeedUpdate();

  @override
  FutureOr<void> onReceiveNeedUpdate() async {
    await pull();
  }

  @override
  FutureOr<Iterable<Feature>> pullFeatures() async {
    final pulled = await source.pullFeatures();
    final features = Map.fromEntries(pulled.map((e) => MapEntry(e.key, e)));
    final savedKeys = preferences.getKeys().where((e) => e.endsWith(_key));

    if (features.isEmpty) {
      for (final savedKey in savedKeys) {
        await preferences.remove(savedKey);
      }
    }

    for (final savedKey in savedKeys) {
      final featureKey = _deserializeFeatureKey(savedKey);

      if (!features.containsKey(featureKey)) {
        await preferences.remove(savedKey);
        continue;
      }

      final raw = preferences.get(savedKey);
      if (raw == null || raw is! String) {
        continue;
      }

      final featureData = _deserializeFeature(raw);
      if (!_checkPersistValid(featureData)) {
        await preferences.remove(savedKey);
        continue;
      }

      final jsonKey = featureData['key'] as String;
      if (jsonKey != featureKey) {
        await preferences.remove(savedKey);
        continue;
      }

      final dynamic jsonValue = featureData['value'];
      final jsonEnabled = featureData['enabled'] as bool;

      final originalFeature = features[jsonKey];
      if (originalFeature != null) {
        features[savedKey] = originalFeature.copyWith(
          value: jsonValue,
          enabled: jsonEnabled,
        );
      }
    }

    for (final feature in features.values) {
      final serializedKey = _serializeFeatureKey(feature.key);
      if (!preferences.containsKey(serializedKey)) {
        await _persistFeature(feature);
      }
    }

    return features.values;
  }

  Future<void> _persistFeature(Feature feature) async {
    final internalKey = _serializeFeatureKey(feature.key);
    final data = _serializeFeature(feature);
    await preferences.setString(internalKey, data);
  }

  bool _checkPersistValid(Map<String, dynamic> json) {
    final check = <dynamic>[
      json['key'] as String?,
      json['value'] as dynamic,
      json['enabled'] as bool?,
    ];
    return !check.contains(null);
  }

  String _serializeFeatureKey(String key) => '$key@$_key';

  String _deserializeFeatureKey(String key) => key.split('@')[0];

  String _serializeFeature(Feature feature) {
    final data = <String, dynamic>{
      'key': feature.key,
      'value': feature.value,
      'enabled': feature.enabled,
    };
    final json = jsonEncode(data);
    return json;
  }

  Map<String, dynamic> _deserializeFeature(String data) {
    final json = jsonDecode(data) as Map<String, dynamic>;
    return json;
  }
}
