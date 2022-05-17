import 'dart:convert';
import 'package:meta/meta.dart';

enum FeatureType {
  string,
  boolean,
  number,
  json,
  unknown,
}

abstract class FeatureToggle extends Feature<bool> {
  FeatureToggle({required bool value, bool? enabled})
      : super(value: value, enabled: enabled ?? value);
}

abstract class Feature<V> {
  late String _key;
  String get key => _key;

  late V _value;
  V get value => _value;

  late bool _enabled;
  bool get enabled => _enabled;

  bool get isToggle => V == bool;

  Feature({
    String? key,
    required V value,
    bool? enabled,
  }) : _value = value {
    _enabled = value is bool ? (enabled ?? value) : true;
    _key = key ?? runtimeType.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Feature &&
          _key == other._key &&
          value == other.value &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(key, value, enabled);

  dynamic get dynamicValue {
    dynamic json(String data) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return null;
      }
    }

    switch (valueType) {
      case String:
        return value.toString();
      case num:
        return num.parse(value.toString());
      case bool:
        return _stringToBool(value.toString());
      case Map:
        return json(value.toString());
      case List:
        return json(value.toString());
      default:
        return FeatureType.unknown;
    }
  }

  Feature<V> copyWith({V? value, bool? enabled}) {
    final obj = creator();
    obj._value = value ?? this.value;
    obj._enabled = enabled ?? this.enabled;
    return obj;
  }

  Feature<V> creator() {
    final typeString = runtimeType.toString();
    throw UnimplementedError(
      'Implement the creator() method in your $typeString class. \n'
      'It should return just new object of your class. \n'
      'Example: \n'
      '    Feature<$V> creator() => $typeString();\n',
    );
  }

  late final Type valueType = _type;
  Type get _type {
    if (value is String) {
      try {
        if (_stringToBool(value as String) != null) {
          return bool;
        }

        final number = num.tryParse(value as String);
        if (number != null) {
          return num;
        }

        final json = jsonDecode(value as String);
        if (json != null && (json is List || json is Map)) {
          return json.runtimeType;
        }
      } catch (_) {
        return String;
      }
    } else if (value is bool) {
      return bool;
    } else if (value is num) {
      return num;
    }
    return Null;
  }

  @override
  String toString() =>
      'Feature(key: $_key, value: $value, enabled: $_enabled, type: $valueType)';

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
  StubFeature() : super(value: '');
}
