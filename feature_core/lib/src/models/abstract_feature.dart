import 'dart:convert';

abstract class FeatureAbstract<V> {
  final String key;
  final V value;

  bool get isToggle => V == bool;

  const FeatureAbstract({
    required this.key,
    required this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureAbstract && key == other.key && value == other.value;

  @override
  int get hashCode => Object.hash(key, value);

  FeatureAbstract<V> copyWith({required V value}) => throw UnimplementedError();

  @override
  String toString() => 'Feature(key: $key, value: $value, type: $_valueType)';

  dynamic get dynamicValue {
    dynamic json(String data) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return null;
      }
    }

    switch (_valueType) {
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
        return null;
    }
  }

  Type get _valueType {
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
