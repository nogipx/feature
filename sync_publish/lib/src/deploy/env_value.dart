abstract class EnvProperty<T> {
  final String key;
  final T? defaultValue;
  final bool required;

  const EnvProperty(
    this.key, {
    this.defaultValue,
    this.required = false,
  });

  T? get value;
}

class StringEnvProperty extends EnvProperty<String> {
  const StringEnvProperty(super.key, {super.defaultValue});

  @override
  String? get value =>
      String.fromEnvironment(key, defaultValue: defaultValue ?? '');
}

class BoolEnvProperty extends EnvProperty<bool> {
  const BoolEnvProperty(super.key, {super.defaultValue});

  @override
  bool? get value =>
      bool.fromEnvironment(key, defaultValue: defaultValue ?? false);
}
