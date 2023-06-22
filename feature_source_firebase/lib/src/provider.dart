import 'package:feature_source_firebase/feature_source_firebase.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseFeaturesProvider extends FeaturesProvider {
  final FirebaseRemoteConfig _remoteConfig;

  FirebaseFeaturesProvider({
    required String key,
    required FirebaseRemoteConfig remoteConfig,
    String name = 'FirebaseRemoteConfig',
    Duration minimumFetchInterval = const Duration(hours: 12),
    Duration fetchTimeout = const Duration(minutes: 1),
  })  : _remoteConfig = remoteConfig,
        super(
          name: name,
          key: key,
          needUpdater: true,
        ) {
    _remoteConfig
      ..setConfigSettings(RemoteConfigSettings(
        fetchTimeout: fetchTimeout,
        minimumFetchInterval: minimumFetchInterval,
      ))
      ..fetchAndActivate();
    _remoteConfig.onConfigUpdated.listen((event) {
      requestPullFeatures();
    });
  }

  @override
  Future<Iterable<FeatureAbstract>> pullFeatures() async {
    await _remoteConfig.fetchAndActivate();
    final features = _remoteConfig.getAll().entries.map((e) {
      final raw = FeatureFirebase(
        key: e.key,
        value: e.value.asString(),
      );
      return raw;
    }).toList();

    return features;
  }
}
