import 'package:args/command_runner.dart';
import 'package:sync_publish/src/_index.dart';
import 'package:sync_publish/src/dependencies/dependencies.dart';
import 'package:yaml/yaml.dart';

class StartUpdateDependenciesCommand extends Command {
  @override
  final String name = "updateDependencies";
  @override
  final String description = "Update Dependencies";

  final Entrypoint entrypoint;

  StartUpdateDependenciesCommand(this.entrypoint) {
    argParser.addOption(
      'update',
      abbr: 'u',
      help: 'Update all packages in project',
    );
  }

  @override
  void run() async {
    final currentPackage = entrypoint.currentPackage!;
    final packages = entrypoint.getPackages();
    packages.add(currentPackage);

    var dependenciesMap = <String, Version>{};
    var devDependenciesMap = <String, Version>{};

    //Загрузка зависимостей
    for (Package package in packages) {
      final currentPubspec = package.pubspec;
      final text = currentPubspec.readAsStringSync();
      final doc = loadYaml(text);

      YamlMap dependencies = doc['dependencies'];
      YamlMap devDependencies = doc['dev_dependencies'];

      dependenciesMap = generateNewMap(dependencies);
      devDependenciesMap = generateNewMap(devDependencies);
    }

    //Обновление зависимостей
    for (Package package in packages) {
      final currentPubspec = package.pubspec;
      var yamlString = currentPubspec.readAsStringSync();

      yamlString = newPubspec(yamlString, dependenciesMap, true);
      yamlString = newPubspec(yamlString, devDependenciesMap, false);

      await package.pubspec.writeAsString(yamlString);
    }
  }
}
