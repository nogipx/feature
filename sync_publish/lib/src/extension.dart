import '_index.dart';
import 'package.dart';
import 'version.dart';

extension UriExt on Uri {
  String get lastPathSegment {
    final segments = pathSegments;
    return pathSegments.length >= 2 ? segments[segments.length - 2] : '';
  }
}

extension PackagesIterable on Iterable<Package> {
  List<Version> get versions => map((e) => e.version).toList();

  List<Package> get excludeSync =>
      where((e) => !excludePackages.contains(e.name)).toList();

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
    final match = where((e) => e.name == name);
    return match.isNotEmpty ? match.first : null;
  }
}
