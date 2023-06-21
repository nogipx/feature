import 'dart:convert';

abstract class FeatureAbstract<V> {
  final String key;
  final V _value;

  bool get isToggle => V == bool;

  const FeatureAbstract({
    required this.key,
    required V value,
  }) : _value = value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureAbstract && key == other.key && _value == other._value;

  @override
  int get hashCode => Object.hash(key, _value);

  FeatureAbstract<V> copyWith({required V value}) => throw UnimplementedError();

  @override
  String toString() => 'Feature(key: $key, value: $_value, type: $_valueType)';

  dynamic get value {
    dynamic json(String data) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return null;
      }
    }

    switch (_valueType) {
      case String:
        return _value.toString();
      case num:
        return num.parse(_value.toString());
      case bool:
        return _stringToBool(_value.toString());
      case Map:
        return json(_value.toString());
      case List:
        return json(_value.toString());
      case Object:
        return _value;
      default:
        return null;
    }
  }

  Type get _valueType {
    if (_value is String) {
      try {
        if (_stringToBool(_value as String) != null) {
          return bool;
        }

        final number = num.tryParse(_value as String);
        if (number != null) {
          return num;
        }

        final json = jsonDecode(_value as String);
        if (json != null && (json is List || json is Map)) {
          return json.runtimeType;
        }
      } catch (_) {
        return String;
      }
    } else if (_value is bool) {
      return bool;
    } else if (_value is num) {
      return num;
    } else if (_value != null) {
      return Object;
    }
    return Null;
  }

  bool? _stringToBool(String data) {
    if (data.toLowerCase() == 'true') {
      return true;
    } else if (data.toLowerCase() == 'false') {
      return false;
    } else {
      return null;
    }
  }
}
