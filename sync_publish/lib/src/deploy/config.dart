import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:sync_publish/sync_publish.dart';

enum BuildPlatform {
  appbundle,
  apk,
  ipa;

  static BuildPlatform getEnum(String name) => BuildPlatform.values.firstWhere((element) => element.name == name);
}

enum BuildType {
  debug,
  profile,
  release;

  static BuildType getEnum(String name) => BuildType.values.firstWhere((element) => element.name == name);
}

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
    String? outputDirPath,
    Set<EnvProperty> overrideProps = const {},
    bool includePlatformEnvironment = false,
    Map<String, EnvProperty> Function(Map<String, EnvProperty>)? transformProperties,
  }) async {
    final shell = FlutterShell(workingDirectory: appDirectory).open();
    shell.eventStream.listen(print);

    String dartDefineString = '';
    Map<String, EnvProperty> targetProps = {};

    if (envFilePath != null || overrideProps.isNotEmpty) {
      if (envFilePath != null && File(envFilePath).existsSync()) {
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

    targetProps.addAll(
      _mapProps(
        _loadPropsFromConfig(),
      ),
    );

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

    final cmd = 'build ${platform.name} --${type.name} $dartDefineString'.trim();

    await shell.run(cmd);

    await _copyBuildToCustomOutput(outputDirPath, type, shell);

    shell.close();
  }

  Future<void> _copyBuildToCustomOutput(String? outputDirPath, BuildType type, FlutterShell shell) async {
    if (outputDirPath != null) {
      late final String outputEndpoint;
      switch (type) {
        case BuildType.debug:
          outputEndpoint = '/debug';
          break;
        case BuildType.profile:
          outputEndpoint = '/profile';
          break;
        case BuildType.release:
          outputEndpoint = '/release';
          break;
      }

      final outputDir = Directory(outputDirPath);
      if (outputDir.existsSync()) {
        await shell.runWithoutFlutter('cp', '-a build/app/outputs/apk/$outputEndpoint ${outputDir.path}');
      }
    }
  }

  Iterable<EnvProperty> _loadPropertiesFromEnv(
      String envFilePath, {
        bool includePlatformEnvironment = false,
      }) {
    final env = DotEnv(
      includePlatformEnvironment: includePlatformEnvironment,
    );

    env.load([envFilePath]);

    final envEnvironments = env.map.keys.map((key) => EnvProperty(
      key,
      value: env.map[key]!,
      required: false,
      loadFromEnv: true,
    ));

    final loadedProps = environment.map((property) {
      if (property.loadFromEnv) {
        final envValue = env[property.key];
        return property.copyWith(value: envValue ?? property.defaultValue);
      }
      return property;
    }).toSet();

    for (var property in envEnvironments) {
      if (!environment.contains(property)) loadedProps.add(property);
    }

    return loadedProps;
  }

  Iterable<EnvProperty> _loadPropsFromConfig() {
    final loadedProps = environment.map((property) {
      return property.copyWith(value: property.value ?? property.defaultValue);
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

