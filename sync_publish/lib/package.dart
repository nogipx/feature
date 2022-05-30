import 'dart:io';

import 'version.dart';

class Package {
  final Directory directory;

  Package({
    required this.directory,
  });

  String get name {
    final lines = pubspec.readAsLinesSync();
    final nameLine = lines.singleWhere(
      (e) => e.startsWith('name'),
      orElse: () => '',
    );
    if (nameLine.isNotEmpty) {
      final name = nameLine.split(':')[1].trim();
      return name;
    }
    return '';
  }

  File get pubspec {
    final file = File('${directory.path}/pubspec.yaml');
    if (file.existsSync()) {
      return file;
    } else {
      final shortFile = File('${directory.path}/pubspec.yml');
      if (shortFile.existsSync()) {
        return shortFile;
      }
    }
    throw Exception('pubspec of "$name" package not found.');
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

  @override
  String toString() => '$name: $version';
}
