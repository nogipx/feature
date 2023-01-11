import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:process_run/shell.dart';
import 'package:sync_publish/sync_publish.dart';

class Package {
  final Directory directory;

  Package._({
    required this.directory,
  });

  static Package? of(Directory directory) {
    final pubspec = _getPubspec(directory);
    if (pubspec != null) {
      return Package._(directory: directory);
    } else {
      return null;
    }
  }

  String get name {
    final lines = pubspec.readAsLinesSync();
    final nameLine = lines.singleWhere(
      (e) => e.startsWith('name'),
      orElse: () => '',
    );
    if (nameLine.isNotEmpty) {
      final name = nameLine.split(':')[1].trim();
      return name;
    } else {
      return '';
    }
  }

  static File? _getPubspec(Directory directory) {
    final file = File('${directory.path}/pubspec.yaml');
    if (file.existsSync()) {
      return file;
    } else {
      final shortFile = File('${directory.path}/pubspec.yml');
      if (shortFile.existsSync()) {
        return shortFile;
      }
    }
    return null;
  }

  File get pubspec {
    final file = _getPubspec(directory);
    if (file != null) {
      return file;
    }
    throw Exception('pubspec not found at ${directory.path}.');
  }

  File get readme {
    final file = File('${directory.path}/README.md');
    if (file.existsSync()) {
      return file;
    }
    throw Exception('Readme of "$name" package not found.');
  }

  Version get version {
    final versionLine = pubspec.readAsLinesSync().singleWhere(
          (e) => e.startsWith('version'),
          orElse: () => '',
        );
    if (versionLine.isNotEmpty) {
      final versionString = versionLine.split(':')[1].trim();
      final version = Version.parse(versionString);
      return version;
    }
    throw Exception('cannot find version');
  }

  Future<void> incrementPatch() async =>
      setVersion(version: version.incrementPatch());

  Future<void> incrementMinor() async =>
      setVersion(version: version.incrementMinor());

  Future<void> incrementMajor() async =>
      setVersion(version: version.incrementMajor());

  Future<void> setVersion({
    required Version version,
  }) async {
    final pubspec = this.pubspec;
    final pubspecContent = await pubspec.readAsString();
    final edited = pubspecContent.replaceFirst(
      'version: ${this.version}',
      'version: $version',
    );
    await pubspec.writeAsString(edited);
  }

  bool containsDependency(String name) {
    final pubspec = this.pubspec;
    final text = pubspec.readAsStringSync();
    final result = text.contains(name);
    return result;
  }

  Future<void> startBuildRunner() async {
    final containsBuildRunner = containsDependency('build_runner:');
    if (!containsBuildRunner) {
      print('There is no build_runner dependency in pubspec.');
      exit(64);
    }

    final shell = FlutterShell(workingDirectory: directory).open();
    shell.eventStream.listen(print);

    print('Start build_runner for "$name" package.\n');

    try {
      await shell.run('pub get');
      await shell.run(
        'pub run build_runner build --delete-conflicting-outputs',
      );
    } on ShellException catch (_) {
      print('Exception while running build: $_');
    } finally {
      shell.close();
      print('End running build_runner.\n');
    }
  }

  @override
  String toString() => '$name: $version';
}
