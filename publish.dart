import 'dart:io';

import 'version.dart';

Future<void> main() async {
  final packages = getPackages();

  print(packages.join('\n'));
  print(packages.allVersionsSynced);
}

Future<void> syncPackagesByMax() async {
  final packages = getPackages();
  final maxVersion = packages.maxVersion;
  if (maxVersion != null) {
    for (final package in packages) {
      await package.setVersion(version: maxVersion);
    }
  }
}

Future<void> incrementAllPatch() async {
  final packages = getPackages();
  for (final package in packages) {
    await package.incrementPatch();
  }
}

Future<void> incrementAllMinor() async {
  final packages = getPackages();
  for (final package in packages) {
    await package.incrementMinor();
  }
}

Future<void> incrementAllMajor() async {
  final packages = getPackages();
  for (final package in packages) {
    await package.incrementMajor();
  }
}

Future<void> publishPackage(Package package) async {}

Iterable<Directory> getUrisOfPackages() {
  final featurePackagesPath = Directory.current
      .listSync()
      .whereType<Directory>()
      .where((e) => !e.uri.lastPathSegment.contains('.'));
  return featurePackagesPath;
}

List<Package> getPackages() {
  final packagesDirs = getUrisOfPackages();
  final packages = packagesDirs.map((e) {
    return Package(
      directory: e,
    );
  }).toList();

  return packages;
}

extension on Iterable<Package> {
  List<Version> get versions => map((e) => e.version).toList();

  bool get allVersionsSynced {
    try {
      versions.reduce(
          (current, next) => current == next ? next : throw Exception());
      return true;
    } catch (_) {
      return false;
    }
  }

  Version? get maxVersion {
    final _versions = versions;
    if (_versions.isNotEmpty) {
      return _versions.fold<Version>(
        Version(0, 0, 0),
        (max, e) => e > max ? e : max,
      );
    }
    return null;
  }

  Version? get minVersion {
    final _versions = versions;
    if (_versions.isNotEmpty) {
      return _versions.fold<Version>(
        _versions.first,
        (min, e) => e < min ? e : min,
      );
    }
    return null;
  }

  Package? find({required String name}) {
    final match = getPackages().where((e) => e.name == name);
    return match.isNotEmpty ? match.first : null;
  }
}

extension on Uri {
  String get lastPathSegment {
    final segments = pathSegments;
    return pathSegments.length >= 2 ? segments[segments.length - 2] : '';
  }
}

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
