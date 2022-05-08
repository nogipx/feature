import 'dart:convert';

enum FeatureType {
  string,
  boolean,
  number,
  json,
  unknown,
}

abstract class Feature<V> {
  String get key;
  String? get name;
  V get value;
  bool get isEnabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Feature &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value;

  @override
  int get hashCode => Object.hash(key, value);

  dynamic get dynamicValue {
    switch (type) {
      case FeatureType.string:
        return value.toString();
      case FeatureType.number:
        return num.parse(value.toString());
      case FeatureType.boolean:
        return _stringToBool(value.toString());
      case FeatureType.json:
        try {
          return jsonDecode(value.toString());
        } catch (_) {
          return null;
        }
      default:
        return FeatureType.unknown;
    }
  }

  late final FeatureType type = _type;
  FeatureType get _type {
    if (value is String) {
      try {
        if (_stringToBool(value as String) != null) {
          return FeatureType.boolean;
        }

        final num = int.tryParse(value as String);
        if (num != null) {
          return FeatureType.number;
        }

        final json = jsonDecode(value as String);
        if (json != null && (json is List || json is Map)) {
          return FeatureType.json;
        }
      } catch (_) {
        return FeatureType.string;
      }
    } else if (value is bool) {
      return FeatureType.boolean;
    } else if (value is num) {
      return FeatureType.number;
    }
    return FeatureType.unknown;
  }

  @override
  String toString() => 'Feature{key: $key, value: $value, type: $type}';

  bool? _stringToBool(String data) {
    if (const ['True', 'true', 'TRUE'].contains(data)) {
      return true;
    } else if (const ['False', 'false', 'FALSE'].contains(data)) {
      return false;
    } else {
      return null;
    }
  }
}

class StubFeature extends Feature<void> {
  @override
  String get key => '';

  @override
  String? get name {}

  @override
  void get value {}

  @override
  bool get isEnabled => false;
}
