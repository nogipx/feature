import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../_index.dart';

Map<String, Version> generateNewMap(YamlMap currentDependencies) {
  final dependenciesMap = <String, Version>{};

  for (final dependence in currentDependencies.keys) {
    if (currentDependencies[dependence] is! String || currentDependencies[dependence] == 'patch') continue;

    String valueVersion = currentDependencies[dependence];

    if (valueVersion.startsWith('^')) {
      valueVersion = valueVersion.substring(1);
    }
    final version = Version.parse(valueVersion);
    if (dependenciesMap[dependence] == null) {
      dependenciesMap[dependence] = version;
    } else {
      final currentVersion = dependenciesMap[dependence]!;
      if (version > currentVersion) {
        dependenciesMap[dependence] = version;
      }
    }
  }
  return dependenciesMap;
}

String newPubspec(String yamlFile, Map<String, Version> currentDependencies, bool isDev) {
  final yamlEditor = YamlEditor(yamlFile);
  final key = isDev ? 'dependencies' : 'dev_dependencies';
  final dependencies = yamlEditor.parseAt([key]);
  YamlMap dependenciesMap = dependencies.value;

  for (final dependence in dependenciesMap.keys) {
    if (currentDependencies[dependence] == null) continue;
    yamlEditor.update([key, dependence], '^${currentDependencies[dependence].toString()}');
  }
  return yamlEditor.toString();
}
