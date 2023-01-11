import 'package:sync_publish/sync_publish.dart';

import 'env_value.dart';

enum BuildPlatform { appbundle, apk, ipa }

enum BuildType { debug, profile, release }

class BuildConfig {
  final Set<EnvProperty> props;

  const BuildConfig({
    this.props = const {},
  });

  Future<void> buildApp({
    required BuildPlatform platform,
    required BuildType type,
  }) async {}
}

Future buildApp(BuildConfig config) async {}
