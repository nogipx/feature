import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:sync_publish/sync_publish.dart';

enum BuildPlatform { appbundle, apk, ipa }

enum BuildType { debug, profile, release }

class BuildConfig {
  final Set<EnvProperty> environment;

  const BuildConfig({
    this.environment = const {},
  });

  Future<void> buildApp({
    required Directory appDirectory,
    required BuildPlatform platform,
    required BuildType type,
    String? envFilePath,
    Set<EnvProperty> overrideProps = const {},
    bool includePlatformEnvironment = false,
    Map<String, EnvProperty> Function(Map<String, EnvProperty>)?
        transformProperties,
  }) async {
    final shell = FlutterShell(workingDirectory: appDirectory).open();
    shell.eventStream.listen(print);

    String dartDefineString = '';
    Map<String, EnvProperty> targetProps = {};

    if (envFilePath != null || overrideProps.isNotEmpty) {
      if (envFilePath != null) {
        _guardEnvFileAvailable(envFilePath);
        targetProps.addAll(
          _mapProps(
            _loadPropertiesFromEnv(
              envFilePath,
              includePlatformEnvironment: includePlatformEnvironment,
            ),
          ),
        );
      }
    }

    targetProps.addAll(_mapProps(overrideProps));

    if (transformProperties != null) {
      targetProps = transformProperties(targetProps);
    }

    final wrongProps = _checkWrongProperties(targetProps);

    if (wrongProps.isNotEmpty) {
      final propsKeys = wrongProps.map((e) => e.key).join(', ');

      throw Exception('Missing required properties: $propsKeys');
    } else {
      dartDefineString = targetProps.values.map((e) => e.dartDefine).join(' ');
    }

    final cmd =
        'build ${platform.name} --${type.name} $dartDefineString'.trim();

    await shell.run(cmd);
    shell.close();
  }

  Iterable<EnvProperty> _loadPropertiesFromEnv(
    String envFilePath, {
    bool includePlatformEnvironment = false,
  }) {
    final env = DotEnv(
      includePlatformEnvironment: includePlatformEnvironment,
    );

    env.load([envFilePath]);
    final loadedProps = environment.map((property) {
      if (property.loadFromEnv) {
        final envValue = env[property.key];
        return property.copyWith(value: envValue ?? property.defaultValue);
      }
      return property;
    });

    return loadedProps;
  }

  Iterable<EnvProperty> _checkWrongProperties(
    Map<String, EnvProperty> targetPropsMap,
  ) {
    return environment.where((property) {
      final targetProperty = targetPropsMap[property.key];

      if (property.required && targetProperty?.value == null) {
        return true;
      }
      return false;
    });
  }

  void _guardEnvFileAvailable(String envFile) {
    if (!File(envFile).existsSync()) {
      throw 'Cannot read file from path: $envFile';
    }
  }

  Map<String, EnvProperty> _mapProps(Iterable<EnvProperty> props) {
    final targetPropsMap = <String, EnvProperty>{};
    for (final prop in props) {
      targetPropsMap[prop.key] = prop;
    }
    return targetPropsMap;
  }
}
